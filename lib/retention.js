"use strict";

const accounts = require("./accounts.js");
const config = require("../config.js");
const fs = require("fs");
const path = require("path");

// how long the records about players are kept, as the privacy policy says
// (public/privacy.html): change one and change the other. run at start and
// once a day. chat has its own, shorter time (lib/chatlog.js), and sign-in
// histories are trimmed as they are written (lib/accounts.js).

const DAY_SECONDS = 86400;
const YEAR_DAYS = 365;
// the game clients' error reports (data/client-errors.log, lib/http.js) are
// emptied this often, so nothing in the file is older.
const ERROR_REPORT_DAYS = 30;
const ERRORS_CLEARED = "client_errors_cleared";

const sweep = () => {
  const db = accounts.database();
  const before = Math.floor(Date.now() / 1000) - YEAR_DAYS * DAY_SECONDS;
  // reports, feedback and username requests, a year after they were dealt with.
  db.prepare("DELETE FROM reports WHERE handled_at IS NOT NULL AND handled_at < ?").run(before);
  db.prepare("DELETE FROM feedback WHERE handled_at IS NOT NULL AND handled_at < ?").run(before);
  db.prepare("DELETE FROM name_requests WHERE handled_at IS NOT NULL AND handled_at < ?").run(before);
  // what moderators did, after a year.
  db.prepare("DELETE FROM mod_log WHERE at < ?").run(before);
  // the record of bans: while the account exists, and a year past it (or
  // for a line about an address, a year).
  db.prepare("DELETE FROM ban_log WHERE at < ? AND (account_id IS NULL OR account_id NOT IN (SELECT id FROM accounts))").run(before);
  const now = Math.floor(Date.now() / 1000);
  const cleared = Number(accounts.setting(ERRORS_CLEARED)) || 0;
  if (cleared === 0) {
    accounts.setSetting(ERRORS_CLEARED, String(now));
  }
  else if (now - cleared > ERROR_REPORT_DAYS * DAY_SECONDS) {
    try {
      fs.truncateSync(path.join(config.dataDir, "client-errors.log"));
    }
    catch (err) {
    }
    accounts.setSetting(ERRORS_CLEARED, String(now));
  }
};

const load = () => {
  sweep();
  setInterval(sweep, DAY_SECONDS * 1000).unref();
};

module.exports = {load, sweep, YEAR_DAYS};
