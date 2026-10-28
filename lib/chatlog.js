"use strict";

const accounts = require("./accounts.js");
const config = require("../config.js");

// what players typed: chat in a room, whispers, Jam-a-Grams and posts on
// each other's Jammer Walls. kept for the moderator
// panel (lib/modpanel.js), which is where a moderator reads what was said
// before deciding anything; nothing else reads it. lines older than
// config.chatLogDays are deleted, and an account's lines go when the
// account is deleted. with chatLogDays 0 nothing is kept at all.

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS chat_log (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    at         INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    username   TEXT NOT NULL,
    room       TEXT NOT NULL,
    kind       TEXT NOT NULL,
    to_name    TEXT NOT NULL DEFAULT '',
    text       TEXT NOT NULL
  );
  CREATE INDEX IF NOT EXISTS chat_log_account ON chat_log (account_id, id);
  CREATE INDEX IF NOT EXISTS chat_log_room ON chat_log (room, id);
`;

const CHAT = "chat";
const WHISPER = "whisper";
const JAMAGRAM = "jamagram";
const WALL = "wall";
const KINDS = [CHAT, WHISPER, JAMAGRAM, WALL];
// what the server's filter kept from being sent is kept with this in front.
const NOT_SENT = "(not sent) ";
const DAY_SECONDS = 86400;
const MAX_TEXT = 600;
const PAGE = 100;
const AROUND = 25; // lines before and after the one asked about

const now = () => Math.floor(Date.now() / 1000);
const db = () => accounts.database();

const prune = () => {
  db().prepare("DELETE FROM chat_log WHERE at < ?").run(now() - config.chatLogDays * DAY_SECONDS);
};

const load = () => {
  db().exec(SCHEMA);
  // lines the filter stopped are marked, and found by a small index of their own.
  if (!db().prepare("PRAGMA table_info(chat_log)").all().some(column => column.name === "stopped")) {
    db().exec("ALTER TABLE chat_log ADD COLUMN stopped INTEGER NOT NULL DEFAULT 0");
    db().prepare("UPDATE chat_log SET stopped = 1 WHERE substr(text, 1, ?) = ?").run(NOT_SENT.length, NOT_SENT);
  }
  db().exec("CREATE INDEX IF NOT EXISTS chat_log_stopped ON chat_log (at) WHERE stopped = 1");
  prune();
  setInterval(prune, DAY_SECONDS * 1000 / 4).unref();
};

const stoppedFlag = text => (String(text).startsWith(NOT_SENT) ? 1 : 0);

// A line said in `room` (its name as the world knows it), or with `to` a
// whisper to that player.
const record = (account, room, text, to = "") => {
  if (config.chatLogDays <= 0) {
    return;
  }
  db().prepare("INSERT INTO chat_log (at, account_id, username, room, kind, to_name, text, stopped) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
    .run(now(), account.id, account.username, String(room || ""), to ? WHISPER : CHAT, to, String(text).slice(0, MAX_TEXT), stoppedFlag(text));
};

// A Jam-a-Gram's words (`kind` JAMAGRAM), or a post on a Jammer Wall
// (WALL): `to` is who it was sent to, or whose wall it is.
const recordTo = (account, kind, to, text) => {
  if (config.chatLogDays <= 0 || !KINDS.includes(kind)) {
    return;
  }
  db().prepare("INSERT INTO chat_log (at, account_id, username, room, kind, to_name, text, stopped) VALUES (?, ?, ?, ?, ?, ?, ?, ?)")
    .run(now(), account.id, account.username, "", kind, String(to || ""), String(text).slice(0, MAX_TEXT), stoppedFlag(text));
};

const row = line => ({id: line.id, at: line.at, username: line.username, room: line.room, kind: line.kind, to: line.to_name,
  whisperTo: line.kind === WHISPER ? line.to_name : "", text: line.text});

// lines newest first, a page at a time: by who said them (or was whispered
// to, or sent to), by room, by words in them, by kind (one of KINDS, or
// "notsent" for what the filter stopped), from `until` (seconds) back, and
// `before` an id for the next page. `direction` narrows the username to
// what they sent ("sent") or what was sent to them ("received").
const search = ({username = "", room = "", text = "", kind = "", direction = "", until = 0, before = 0}) => {
  const where = [];
  const values = [];
  if (KINDS.includes(kind)) {
    where.push("kind = ?");
    values.push(kind);
  }
  else if (kind === "notsent") {
    where.push("stopped = 1");
  }
  if (until > 0) {
    where.push("at <= ?");
    values.push(Math.floor(until));
  }
  if (username && direction === "sent") {
    where.push("username = ? COLLATE NOCASE");
    values.push(username);
  }
  else if (username && direction === "received") {
    where.push("to_name = ? COLLATE NOCASE");
    values.push(username);
  }
  else if (username) {
    where.push("(username = ? COLLATE NOCASE OR to_name = ? COLLATE NOCASE)");
    values.push(username, username);
  }
  if (room) {
    where.push("room LIKE ? ESCAPE '\\'");
    values.push(`%${room.replace(/[\\%_]/g, "\\$&")}%`);
  }
  if (text) {
    where.push("text LIKE ? ESCAPE '\\'");
    values.push(`%${text.replace(/[\\%_]/g, "\\$&")}%`);
  }
  if (before > 0) {
    where.push("id < ?");
    values.push(before);
  }
  return db().prepare(`SELECT * FROM chat_log ${where.length ? `WHERE ${where.join(" AND ")}` : ""} ORDER BY id DESC LIMIT ?`).all(...values, PAGE).map(row);
};

// what was said around one line, oldest first: in its room, or for a
// whisper between its two players.
const around = id => {
  const line = db().prepare("SELECT * FROM chat_log WHERE id = ?").get(Number(id));
  if (!line) {
    return null;
  }
  const [same, values] = line.kind === CHAT
    ? ["kind = ? AND room = ?", [CHAT, line.room]]
    : ["kind = ? AND ((username = ? AND to_name = ?) OR (username = ? AND to_name = ?))", [line.kind, line.username, line.to_name, line.to_name, line.username]];
  const earlier = db().prepare(`SELECT * FROM chat_log WHERE ${same} AND id < ? ORDER BY id DESC LIMIT ?`).all(...values, line.id, AROUND).reverse();
  const later = db().prepare(`SELECT * FROM chat_log WHERE ${same} AND id > ? ORDER BY id LIMIT ?`).all(...values, line.id, AROUND);
  return {line: row(line), lines: [...earlier, line, ...later].map(row)};
};

// everything an account said that is still kept, oldest first, for the copy
// of their data a player may ask for (lib/manage.js).
const saidBy = account => db().prepare("SELECT * FROM chat_log WHERE account_id = ? ORDER BY id").all(account.id).map(row);

// how many of an account's lines the server's filter stopped, in the last
// `days` days.
const notSentCount = (account, days) => db().prepare("SELECT COUNT(*) AS n FROM chat_log WHERE account_id = ? AND at > ? AND stopped = 1")
  .get(account.id, now() - days * DAY_SECONDS).n;

// those the filter stopped most often in the last `days` days: [{username, count, last}].
const mostStopped = (days, limit) => db().prepare(`SELECT username, COUNT(*) AS count, MAX(at) AS last FROM chat_log
  WHERE stopped = 1 AND at > ? GROUP BY account_id ORDER BY count DESC LIMIT ?`)
  .all(now() - days * DAY_SECONDS, limit).map(entry => ({username: entry.username, count: entry.count, last: entry.last}));

// an account being deleted: what it said goes with it.
const forget = account => {
  db().prepare("DELETE FROM chat_log WHERE account_id = ?").run(account.id);
};

module.exports = {load, record, recordTo, search, around, saidBy, notSentCount, mostStopped, forget, PAGE, JAMAGRAM, WALL, NOT_SENT};
