"use strict";

const fs = require("fs");
const path = require("path");
const accounts = require("./accounts.js");
const config = require("../config.js");

// the game's numbers over time, for the graphs on the admin and moderator
// panels: how many were playing (a sample a minute, written as one row per
// five minutes with its average and its most), every login to the game, and
// every stretch of play when it ends. the logins and the stretches name the
// account, so they go after a year (as the privacy policy says of the
// records kept about players); the head-counts name nobody and stay.

const DAY_SECONDS = 86400;
const SAMPLE_MS = 60000;
const ROW_SECONDS = 300;
const KEPT_DAYS = 365;
const RANGES = [1, 7, 30, 90, 365]; // days a graph can cover
const TOP_PLAYERS = 10;

const SCHEMA = `
  CREATE TABLE IF NOT EXISTS stats_online (at INTEGER PRIMARY KEY, average REAL NOT NULL, most INTEGER NOT NULL);
  CREATE TABLE IF NOT EXISTS stats_logins (at INTEGER NOT NULL, account_id INTEGER NOT NULL, first INTEGER NOT NULL);
  CREATE INDEX IF NOT EXISTS stats_logins_at ON stats_logins (at);
  CREATE TABLE IF NOT EXISTS stats_sessions (ended INTEGER NOT NULL, account_id INTEGER NOT NULL, seconds INTEGER NOT NULL);
  CREATE INDEX IF NOT EXISTS stats_sessions_ended ON stats_sessions (ended);
`;

const now = () => Math.floor(Date.now() / 1000);
const db = () => accounts.database();

let countOnline = () => 0;
let row = null; // the five minutes being counted: {at, sum, samples, most}

const writeRow = () => {
  if (row && row.samples > 0) {
    db().prepare("INSERT INTO stats_online (at, average, most) VALUES (?, ?, ?) ON CONFLICT(at) DO UPDATE SET average = excluded.average, most = excluded.most")
      .run(row.at, row.sum / row.samples, row.most);
  }
};

const sample = () => {
  const count = countOnline();
  const at = Math.floor(now() / ROW_SECONDS) * ROW_SECONDS;
  if (row && row.at !== at) {
    writeRow();
    row = null;
  }
  row = row || {at, sum: 0, samples: 0, most: 0};
  row.sum += count;
  row.samples++;
  row.most = Math.max(row.most, count);
};

const prune = () => {
  const before = now() - KEPT_DAYS * DAY_SECONDS;
  db().prepare("DELETE FROM stats_logins WHERE at < ?").run(before);
  db().prepare("DELETE FROM stats_sessions WHERE ended < ?").run(before);
};

// `online` counts the players in the game now (lib/world.js).
const load = online => {
  db().exec(SCHEMA);
  countOnline = online;
  prune();
  sample();
  setInterval(() => {
    try {
      sample();
    }
    catch (err) {
      console.error(`[stats] could not count: ${err.message}`);
    }
  }, SAMPLE_MS).unref();
  setInterval(prune, DAY_SECONDS * 1000).unref();
};

// the row being counted is written before the server stops (server.js).
const flush = () => {
  try {
    writeRow();
  }
  catch (err) {
    // the database is closing
  }
};

const login = (account, first) => {
  db().prepare("INSERT INTO stats_logins (at, account_id, first) VALUES (?, ?, ?)").run(now(), account.id, first ? 1 : 0);
};

const session = (account, seconds) => {
  if (seconds > 0) {
    db().prepare("INSERT INTO stats_sessions (ended, account_id, seconds) VALUES (?, ?, ?)").run(now(), account.id, Math.round(seconds));
  }
};

// the numbers for the last `days` days, in buckets of an hour (a day or
// two) or of a day, the days as the viewer's clock has them: `offset` is
// their minutes ahead of UTC. the hours of the day and the days of the week
// are theirs too.
const report = (days, offset) => {
  days = RANGES.includes(days) ? days : 7;
  offset = Number.isInteger(offset) && Math.abs(offset) <= 14 * 60 ? offset * 60 : 0;
  const end = now();
  const start = end - days * DAY_SECONDS;
  const size = days <= 2 ? 3600 : DAY_SECONDS;
  // the bucket a moment falls in, by the viewer's clock.
  const bucketOf = at => Math.floor((at + offset) / size) * size - offset;
  const first = bucketOf(start);
  const buckets = new Map();
  for (let at = first; at <= end; at += size) {
    buckets.set(at, {at, average: 0, most: 0, logins: 0, players: 0, newAccounts: 0, samples: 0, sum: 0, who: new Set()});
  }
  const hours = Array.from({length: 24}, () => ({sum: 0, samples: 0, logins: 0}));
  const week = Array.from({length: 7}, () => Array.from({length: 24}, () => ({sum: 0, samples: 0})));
  const local = at => new Date((at + offset) * 1000);

  let most = {count: 0, at: null};
  for (const sampled of db().prepare("SELECT at, average, most FROM stats_online WHERE at >= ? ORDER BY at").all(start)) {
    const bucket = buckets.get(bucketOf(sampled.at));
    if (bucket) {
      bucket.sum += sampled.average;
      bucket.samples++;
      bucket.most = Math.max(bucket.most, sampled.most);
    }
    const when = local(sampled.at);
    hours[when.getUTCHours()].sum += sampled.average;
    hours[when.getUTCHours()].samples++;
    week[when.getUTCDay()][when.getUTCHours()].sum += sampled.average;
    week[when.getUTCDay()][when.getUTCHours()].samples++;
    if (sampled.most > most.count) {
      most = {count: sampled.most, at: sampled.at};
    }
  }
  if (row && row.at >= start && row.most > most.count) {
    most = {count: row.most, at: row.at};
  }

  const everyone = new Set();
  let logins = 0;
  let firstLogins = 0;
  for (const entry of db().prepare("SELECT at, account_id, first FROM stats_logins WHERE at >= ?").all(start)) {
    const bucket = buckets.get(bucketOf(entry.at));
    if (bucket) {
      bucket.logins++;
      bucket.who.add(entry.account_id);
    }
    hours[local(entry.at).getUTCHours()].logins++;
    everyone.add(entry.account_id);
    logins++;
    firstLogins += entry.first;
  }

  const all = accounts.all();
  let newAccounts = 0;
  for (const account of all) {
    if (account.createdAt >= start) {
      newAccounts++;
      const bucket = buckets.get(bucketOf(account.createdAt));
      if (bucket) {
        bucket.newAccounts++;
      }
    }
  }

  const played = db().prepare("SELECT COUNT(*) AS count, COALESCE(SUM(seconds), 0) AS total FROM stats_sessions WHERE ended >= ?").get(start);
  const ever = db().prepare("SELECT at, most FROM stats_online ORDER BY most DESC, at DESC LIMIT 1").get();

  return {
    days,
    bucketSeconds: size,
    summary: {
      online: countOnline(),
      accounts: all.length,
      newAccounts,
      logins,
      players: everyone.size,
      firstLogins,
      peak: most,
      peakEver: ever && (!row || ever.most >= row.most) ? {count: ever.most, at: ever.at} : row ? {count: row.most, at: row.at} : {count: 0, at: null},
      sessions: played.count,
      averageSessionSeconds: played.count ? Math.round(played.total / played.count) : 0,
      playedSeconds: played.total,
    },
    series: [...buckets.values()].map(bucket => ({
      at: bucket.at,
      average: bucket.samples ? Math.round(bucket.sum / bucket.samples * 10) / 10 : null,
      most: bucket.samples ? bucket.most : null,
      logins: bucket.logins,
      players: bucket.who.size,
      newAccounts: bucket.newAccounts,
    })),
    hours: hours.map(hour => ({average: hour.samples ? Math.round(hour.sum / hour.samples * 10) / 10 : null, logins: hour.logins})),
    week: week.map(day => day.map(hour => (hour.samples ? Math.round(hour.sum / hour.samples * 10) / 10 : null))),
    topPlaytime: all.filter(account => account.playtime > 0).sort((one, other) => other.playtime - one.playtime).slice(0, TOP_PLAYERS)
      .map(account => ({username: account.username, seconds: account.playtime})),
  };
};

// A panel's page with the Stats tab (public/stats-view.html) where it says
// <!--stats-view-->: the admin and the moderator panels show the same one.
const withView = async page => {
  const view = await fs.promises.readFile(path.join(config.publicDir, "stats-view.html"), "utf8");
  return Buffer.from(String(page).replace("<!--stats-view-->", () => view));
};

module.exports = {load, flush, login, session, report, withView, RANGES};
