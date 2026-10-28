"use strict";

const {logText} = require("./logtext.js");
const accounts = require("./accounts.js");
const limits = require("./limits.js");
const net = require("net");

// what bans keep beside the account's own `bannedUntil`: banned addresses,
// each account's one appeal, and a record of every ban given and lifted.
//
// an address ban is for good, and is of the address alone: the accounts
// that were used from it are not banned with it (a VPN's address is many
// people's). it keeps that address out of the game and out of signing up;
// the account page still opens there, where a player can ask about it or
// delete their account. this machine's own address cannot be banned, which
// is also the address of everyone when a proxy or a tunnel stands in front
// and the server has not been told (AJ_TRUSTED_PROXY).

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS ban_log (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    at         INTEGER NOT NULL,
    account_id INTEGER,
    username   TEXT NOT NULL DEFAULT '',
    address    TEXT NOT NULL DEFAULT '',
    action     TEXT NOT NULL,
    seconds    INTEGER NOT NULL DEFAULT 0,
    reason     TEXT NOT NULL DEFAULT '',
    by         TEXT NOT NULL DEFAULT ''
  );
  CREATE TABLE IF NOT EXISTS address_bans (
    address_key TEXT PRIMARY KEY,
    address     TEXT NOT NULL,
    reason      TEXT NOT NULL,
    by          TEXT NOT NULL,
    created_at  INTEGER NOT NULL
  );
  CREATE TABLE IF NOT EXISTS appeals (
    account_id  INTEGER PRIMARY KEY,
    created_at  INTEGER NOT NULL,
    username    TEXT NOT NULL,
    text        TEXT NOT NULL,
    address_key TEXT NOT NULL DEFAULT '',
    status      TEXT NOT NULL DEFAULT 'waiting',
    reply       TEXT NOT NULL DEFAULT '',
    handled_at  INTEGER
  );
`;

const WAITING = "waiting";
const APPROVED = "approved";
const DENIED = "denied";
const MAX_REASON = 300;
const MAX_APPEAL = 1000;
const MAX_REPLY = 500;
const MAX_ADDRESS_BANS = 10000;
const HISTORY_SHOWN = 50;

const now = () => Math.floor(Date.now() / 1000);
const db = () => accounts.database();
// A line break is kept; the other control characters are not.
const clean = (text, max) => String(text === undefined || text === null ? "" : text).replace(/[\u0000-\u0009\u000b-\u001f\u007f]/g, " ").trim().slice(0, max);

// A ban's reason as it is kept and shown: something is always said.
const NO_REASON = "Not provided";
const reasonText = text => clean(text, MAX_REASON) || NO_REASON;

const banned = new Map(); // address as limits count it -> {key, address, reason, by, createdAt}

const addressRow = row => ({key: row.address_key, address: row.address, reason: row.reason, by: row.by, createdAt: row.created_at});

const load = () => {
  db().exec(SCHEMA);
  for (const row of db().prepare("SELECT * FROM address_bans").all()) {
    banned.set(row.address_key, addressRow(row));
  }
};

// `entry`: {account, address, action, seconds, reason, by}. actions: "ban",
// "unban", "reason", "address_ban", "address_unban", "appeal",
// "appeal_approved", "appeal_denied". A ban that runs out leaves no line.
const record = entry => {
  db().prepare("INSERT INTO ban_log (at, account_id, username, address, action, seconds, reason, by) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
    .run(now(), entry.account ? entry.account.id : null, entry.account ? entry.account.username : "", entry.address || "",
      entry.action, entry.seconds || 0, entry.reason || "", entry.by || "");
};

const logRow = row => ({at: row.at, username: row.username, address: row.address, action: row.action, seconds: row.seconds, reason: row.reason, by: row.by});

const historyOf = account =>
  db().prepare("SELECT * FROM ban_log WHERE account_id = ? ORDER BY id DESC LIMIT ?").all(account.id, HISTORY_SHOWN).map(logRow);

const addressBan = address => banned.get(limits.key(address)) || null;

// returns {ban} or {error: "not_an_address" | "own_address" | "already" | "too_many"}.
const banAddress = (address, reason, by) => {
  const text = String(address || "").trim().replace(/^::ffff:(?=\d+\.\d+\.\d+\.\d+$)/i, "");
  if (!net.isIP(text)) {
    return {error: "not_an_address"};
  }
  // this machine: the owner at home, and with a proxy or a tunnel in front
  // everybody else as well.
  if (limits.isLoopback(text) || /^(0\.0\.0\.0|::|0:0:0:0:0:0:0:[01])$/.test(text)) {
    return {error: "own_address"};
  }
  const key = limits.key(text);
  if (banned.has(key)) {
    return {error: "already"};
  }
  if (banned.size >= MAX_ADDRESS_BANS) {
    return {error: "too_many"};
  }
  const ban = {key, address: text, reason: reasonText(reason), by, createdAt: now()};
  db().prepare("INSERT INTO address_bans (address_key, address, reason, by, created_at) VALUES (?, ?, ?, ?, ?)").run(key, ban.address, ban.reason, by, ban.createdAt);
  banned.set(key, ban);
  record({address: key, action: "address_ban", seconds: -1, reason: ban.reason, by});
  return {ban};
};

// `key` as a listing gave it, or any address the ban covers.
const unbanAddress = (key, by) => {
  const ban = banned.get(String(key)) || addressBan(key);
  if (!ban) {
    return false;
  }
  db().prepare("DELETE FROM address_bans WHERE address_key = ?").run(ban.key);
  banned.delete(ban.key);
  record({address: ban.key, action: "address_unban", by});
  return true;
};

const addressBans = () => [...banned.values()].sort((one, other) => other.createdAt - one.createdAt);

const appealRow = row => ({
  accountId: row.account_id,
  createdAt: row.created_at,
  username: row.username,
  text: row.text,
  addressKey: row.address_key,
  status: row.status,
  reply: row.reply,
  handledAt: row.handled_at,
});

const appealOf = account => {
  const row = db().prepare("SELECT * FROM appeals WHERE account_id = ?").get(account.id);
  return row ? appealRow(row) : null;
};

// `addressKey` when it is (also) about the address they wrote from.
// returns {appeal} or {error: "empty" | "already"}.
const appeal = (account, text, addressKey = "") => {
  const body = clean(text, MAX_APPEAL);
  if (!body) {
    return {error: "empty"};
  }
  if (appealOf(account)) {
    return {error: "already"};
  }
  db().prepare("INSERT INTO appeals (account_id, created_at, username, text, address_key) VALUES (?, ?, ?, ?, ?)").run(account.id, now(), account.username, body, addressKey);
  record({account, address: addressKey, action: "appeal"});
  console.log(`[bans] "${logText(account.username)}" appealed`);
  return {appeal: appealOf(account)};
};

// appeals waiting, oldest first; or with `handled`, the latest answered.
const appeals = (handled = false) => db()
  .prepare(handled
    ? "SELECT * FROM appeals WHERE status <> ? ORDER BY handled_at DESC LIMIT 200"
    : "SELECT * FROM appeals WHERE status = ? ORDER BY created_at LIMIT 500")
  .all(WAITING).map(appealRow);

const waitingAppeal = accountId => {
  const row = db().prepare("SELECT * FROM appeals WHERE account_id = ? AND status = ?").get(Number(accountId), WAITING);
  return row ? appealRow(row) : null;
};

// the caller lifts the bans when it approves.
const answerAppeal = (accountId, approved, reply, by) => {
  const answered = db().prepare("UPDATE appeals SET status = ?, reply = ?, handled_at = ? WHERE account_id = ? AND status = ?")
    .run(approved ? APPROVED : DENIED, clean(reply, MAX_REPLY), now(), Number(accountId), WAITING).changes > 0;
  if (answered) {
    const account = accounts.byId(Number(accountId));
    record({account, action: approved ? "appeal_approved" : "appeal_denied", reason: clean(reply, MAX_REPLY), by});
  }
  return answered;
};

const openAppeals = () => db().prepare("SELECT COUNT(*) AS count FROM appeals WHERE status = ?").get(WAITING).count;

// an account being deleted: what it wrote goes with it. the record of what
// was done about it stays, under the name it had.
const forget = account => {
  db().prepare("DELETE FROM appeals WHERE account_id = ?").run(account.id);
};

module.exports = {
  load, record, historyOf, addressBan, banAddress, unbanAddress, addressBans, appealOf, appeal, appeals, waitingAppeal, answerAppeal,
  openAppeals, forget, clean, reasonText, NO_REASON, MAX_REASON, MAX_APPEAL, MAX_REPLY,
};
