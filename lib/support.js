"use strict";

const {logText} = require("./logtext.js");
const accounts = require("./accounts.js");

// what players send from the account page (/account, lib/manage.js) for
// whoever runs the server to answer in the admin panel: requests for a new
// username, and feedback and bug reports.

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS name_requests (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    old_name   TEXT NOT NULL,
    new_name   TEXT NOT NULL,
    reason     TEXT NOT NULL,
    status     TEXT NOT NULL DEFAULT 'waiting',
    handled_at INTEGER
  );
  CREATE TABLE IF NOT EXISTS feedback (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at INTEGER NOT NULL,
    account_id INTEGER NOT NULL,
    username   TEXT NOT NULL,
    kind       TEXT NOT NULL,
    text       TEXT NOT NULL,
    handled_at INTEGER
  );
`;

const WAITING = "waiting";
const APPROVED = "approved";
const DENIED = "denied";
const WITHDRAWN = "withdrawn";
const KINDS = ["feedback", "bug"];
const MAX_REASON = 300;
const MAX_TEXT = 4000;
const MAX_OPEN_FEEDBACK = 5000; // waiting to be read; further ones are refused
const FEEDBACK_PER_DAY = 10; // per account
const DAY_SECONDS = 86400;

const now = () => Math.floor(Date.now() / 1000);
const db = () => accounts.database();
const clean = (text, max) => String(text === undefined ? "" : text).replace(/[\u0000-\u0008\u000b-\u001f\u007f]/g, " ").trim().slice(0, max);

const load = () => db().exec(SCHEMA);

const nameRow = row => ({
  id: row.id,
  createdAt: row.created_at,
  accountId: row.account_id,
  oldName: row.old_name,
  newName: row.new_name,
  reason: row.reason,
  status: row.status,
  handledAt: row.handled_at,
});

const waitingNameRequest = account => {
  const row = db().prepare("SELECT * FROM name_requests WHERE account_id = ? AND status = ? ORDER BY id DESC LIMIT 1").get(account.id, WAITING);
  return row ? nameRow(row) : null;
};

const nameRequestsOf = account =>
  db().prepare("SELECT * FROM name_requests WHERE account_id = ? ORDER BY id DESC LIMIT 10").all(account.id).map(nameRow);

// asks for a new username. one request waits at a time: a new one replaces
// it. returns {request} or {error: "invalid_username" | "username_taken" | "same_name"}.
const requestName = (account, newName, reason) => {
  newName = typeof newName === "string" ? newName.trim() : "";
  if (newName === account.username) {
    return {error: "same_name"};
  }
  // changing only the capitals of one's own name is not "taken".
  const problem = newName.toLowerCase() === account.username.toLowerCase() ? null : accounts.usernameProblem(newName);
  if (problem) {
    return {error: problem};
  }
  db().prepare("UPDATE name_requests SET status = ?, handled_at = ? WHERE account_id = ? AND status = ?").run(WITHDRAWN, now(), account.id, WAITING);
  db().prepare("INSERT INTO name_requests (created_at, account_id, old_name, new_name, reason) VALUES (?, ?, ?, ?, ?)")
    .run(now(), account.id, account.username, newName, clean(reason, MAX_REASON));
  console.log(`[support] "${logText(account.username)}" asked to be called "${logText(newName)}"`);
  return {request: waitingNameRequest(account)};
};

const withdrawNameRequest = account =>
  db().prepare("UPDATE name_requests SET status = ?, handled_at = ? WHERE account_id = ? AND status = ?").run(WITHDRAWN, now(), account.id, WAITING).changes > 0;

// requests waiting, oldest first; or with `handled`, the latest answered.
const nameRequests = (handled = false) => db()
  .prepare(handled
    ? "SELECT * FROM name_requests WHERE status IN (?, ?) ORDER BY handled_at DESC LIMIT 200"
    : "SELECT * FROM name_requests WHERE status = ? ORDER BY id LIMIT 500")
  .all(...(handled ? [APPROVED, DENIED] : [WAITING])).map(nameRow);

const nameRequestById = id => {
  const row = db().prepare("SELECT * FROM name_requests WHERE id = ? AND status = ?").get(Number(id), WAITING);
  return row ? nameRow(row) : null;
};

const answerNameRequest = (id, approved) =>
  db().prepare("UPDATE name_requests SET status = ?, handled_at = ? WHERE id = ? AND status = ?")
    .run(approved ? APPROVED : DENIED, now(), Number(id), WAITING).changes > 0;

const feedbackRow = row => ({
  id: row.id,
  createdAt: row.created_at,
  username: row.username,
  kind: row.kind,
  text: row.text,
  handledAt: row.handled_at,
});

const openFeedbackCount = () => db().prepare("SELECT COUNT(*) AS count FROM feedback WHERE handled_at IS NULL").get().count;

// returns {ok: true} or {error: "empty" | "unknown_kind" | "too_many"}.
const sendFeedback = (account, kind, text) => {
  const body = clean(text, MAX_TEXT);
  if (!KINDS.includes(kind)) {
    return {error: "unknown_kind"};
  }
  if (!body) {
    return {error: "empty"};
  }
  const today = db().prepare("SELECT COUNT(*) AS count FROM feedback WHERE account_id = ? AND created_at > ?").get(account.id, now() - DAY_SECONDS).count;
  if (today >= FEEDBACK_PER_DAY || openFeedbackCount() >= MAX_OPEN_FEEDBACK) {
    return {error: "too_many"};
  }
  db().prepare("INSERT INTO feedback (created_at, account_id, username, kind, text) VALUES (?, ?, ?, ?, ?)").run(now(), account.id, account.username, kind, body);
  console.log(`[support] ${logText(kind === "bug" ? "bug report" : "feedback")} from "${logText(account.username)}"`);
  return {ok: true};
};

const feedbackOf = account =>
  db().prepare("SELECT * FROM feedback WHERE account_id = ? ORDER BY id DESC LIMIT 20").all(account.id).map(feedbackRow);

const feedback = (handled = false) => db()
  .prepare(handled
    ? "SELECT * FROM feedback WHERE handled_at IS NOT NULL ORDER BY handled_at DESC LIMIT 200"
    : "SELECT * FROM feedback WHERE handled_at IS NULL ORDER BY id LIMIT 500")
  .all().map(feedbackRow);

const markFeedbackRead = id => db().prepare("UPDATE feedback SET handled_at = ? WHERE id = ? AND handled_at IS NULL").run(now(), Number(id)).changes > 0;

// an account being deleted: what it sent goes with it.
const forget = account => {
  db().prepare("DELETE FROM feedback WHERE account_id = ?").run(account.id);
  db().prepare("DELETE FROM name_requests WHERE account_id = ?").run(account.id);
};

const openCount = () => openFeedbackCount() + db().prepare("SELECT COUNT(*) AS count FROM name_requests WHERE status = ?").get(WAITING).count;

module.exports = {
  load, requestName, withdrawNameRequest, waitingNameRequest, nameRequestsOf, nameRequests, nameRequestById, answerNameRequest,
  forget, sendFeedback, feedbackOf, feedback, markFeedbackRead, openCount, MAX_REASON, MAX_TEXT, KINDS,
};
