"use strict";

// Earth Crystals (currency 2, "orbs" in the code): Meadow's own currency,
// earned and never topped up (lib/world.js). what this file keeps:
// - what comes in: 50 to a new account, 10 to 50 at random each week
//   to an account that played at least half an hour the week before, and
//   the daily spin's (dailySpin).
// - what players risk with each other: a stake on an arena duel
//   (lib/arena.js) and "!coinflip AMOUNT PLAYER". the winner takes both,
//   minus a 5% fee, which is how crystals leave the game.
// - who may risk them, so that new accounts made to lose on purpose are of
//   no use: an established account (14 days old, unless it boosts the
//   Discord server; 10 hours played; 10 arena matches finished), on the
//   Meadow client (not the browser version, which has no hardware ids),
//   up to an amount that grows with its adventure level. never between
//   accounts on the same computer or address, at most three times a week
//   between the same two, and not while crystals have flowed one way
//   between them. matches that look thrown are written down for the staff.
//   moderators and admins need not be established nor on the client, and
//   two of them may play each other whatever their computers, so the staff
//   can try it all at once; their games are in the ledger like anyone's.
// - every crystal that moves, in crystal_ledger, which the admin panel
//   reads, and from which a staked game can be undone.

const crypto = require("crypto");
const path = require("path");
const accounts = require("./accounts.js");
const cdn = require("./cdn.js");
const devices = require("./devices.js");
const limits = require("./limits.js");
const roles = require("./roles.js");
const {logText} = require("./logtext.js");
const {arenaLevelOf} = require("./questlevels.js");

const CURRENCY = 2; // ItemXtCommManager.currencyUpdateResponse
const NAME = "orbs"; // its name in account.currency
const REASON_ANNOUNCE = 3; // the game says "You have been granted ..."

const START = /^\d{1,6}$/.test(process.env.AJ_CRYSTALS_START || "") ? Number(process.env.AJ_CRYSTALS_START) : 50; // AJ_CRYSTALS_START: for the tests
const WEEKLY_MIN = 10;
const WEEKLY_MAX = 50;
const WEEKLY_PLAYED = 30 * 60; // seconds played in the week before, for the next week's crystals
const WEEK = 7 * 86400;
const MONDAY = 4 * 86400; // 1970-01-05, a Monday: weeks start Monday 00:00 UTC

const MAX_STAKE = 10000;
const FEE_PERCENT = 5;
// AJ_CRYSTALS_EASY=1: every account counts as established, for the tests
const EASY = process.env.AJ_CRYSTALS_EASY === "1";
const ESTABLISHED_SECONDS = 14 * 86400; // account age; boosters need not wait
const ESTABLISHED_PLAYED = 10 * 3600;
const ESTABLISHED_MATCHES = 10;
const BOOSTER = "booster"; // the badge lib/discord.js gives while one boosts
// the most an account may stake at once, by its arena level
const STAKE_CAPS = [[50, 10000], [25, 5000], [10, 1000], [0, 250]];
const PAIR_PER_WEEK = 3; // staked games between the same two, a week
const FLOW_SECONDS = 30 * 86400; // ... and the crystals that went one way between them
const FLOW_LIMIT = 1000;
const ADDRESS_SECONDS = 30 * 86400; // a shared sign-in address counts this long
const FLIP_WAIT_MS = 60000; // a coinflip not answered by then is off

const NOT_WITH = "You can't play for Earth Crystals with this player.";

const now = () => Math.floor(Date.now() / 1000);
const weekOf = at => Math.floor((at - MONDAY) / WEEK);
const weekStart = week => MONDAY + week * WEEK;
const db = () => accounts.database();

let findOnline = () => null;
let tables = false;
const ensureTables = () => {
  if (tables) {
    return;
  }
  db().exec(`
    CREATE TABLE IF NOT EXISTS crystal_ledger (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      at         INTEGER NOT NULL,
      account_id INTEGER NOT NULL,
      username   TEXT NOT NULL,
      change     INTEGER NOT NULL,
      balance    INTEGER NOT NULL,
      kind       TEXT NOT NULL,
      game       TEXT NOT NULL DEFAULT '',
      other      TEXT NOT NULL DEFAULT '',
      detail     TEXT NOT NULL DEFAULT ''
    );
    CREATE INDEX IF NOT EXISTS crystal_ledger_account ON crystal_ledger (account_id, at);
    CREATE INDEX IF NOT EXISTS crystal_ledger_game ON crystal_ledger (game);
    CREATE TABLE IF NOT EXISTS crystal_flags (
      id     INTEGER PRIMARY KEY AUTOINCREMENT,
      at     INTEGER NOT NULL,
      game   TEXT NOT NULL,
      who    TEXT NOT NULL,
      reason TEXT NOT NULL
    );
  `);
  tables = true;
};

// what an account keeps of all this: the week its last weekly crystals were
// for, the time it played this week and the week before, the arena matches
// it has finished, and a stake held for a game (given back if the server
// stopped before the game was settled).
const stateOf = account => {
  if (!account.crystals || typeof account.crystals !== "object") {
    account.crystals = {week: weekOf(now()), playWeek: weekOf(now()), played: 0, playedBefore: 0, matches: 0, escrow: null};
  }
  return account.crystals;
};

const balance = account => account.currency[NAME] || 0;

// crystals in or out of an account, written down. the game is told the new
// amount; `announce` has it say so in a popup.
const change = (account, amount, kind, {game = "", other = "", detail = "", announce = false} = {}) => {
  ensureTables();
  account.currency[NAME] = Math.max(0, balance(account) + amount);
  accounts.save(account);
  db().prepare("INSERT INTO crystal_ledger (at, account_id, username, change, balance, kind, game, other, detail) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")
    .run(now(), account.id, account.username, amount, balance(account), kind, game, other, String(detail).slice(0, 200));
  const session = findOnline(account.username);
  if (session) {
    // ItemXtCommManager.currencyUpdateResponse: [currencyType, newAmount, reason]
    session.sendXt("cu", -1, CURRENCY, balance(account), announce ? REASON_ANNOUNCE : 0);
  }
};

const flag = (game, who, reason) => {
  ensureTables();
  db().prepare("INSERT INTO crystal_flags (at, game, who, reason) VALUES (?, ?, ?, ?)").run(now(), game, who.join(", "), reason);
  console.log(`[crystals] flagged ${logText(game)} (${logText(who.join(", "))}): ${logText(reason)}`);
};

// ---- what comes in ----

// a new account's first crystals (lib/accounts.js calls this as it is made)
const starter = account => {
  stateOf(account);
  change(account, START, "start");
};

// the daily spin: the game's members' wheel (GemBonusSpinWheel), for every
// player, in Earth Crystals. its art is swf/crystal-wheel.swf
// (tools/make-crystal-art.py), the game's wheel with its diamonds in the
// crystals' amber and the HUD's Earth Crystal in its prize display, served
// as a media id of its own: the original is sent
// from the cache by nginx, which never asks this server.
const SPIN_WHEEL_MEDIA = 990001;
cdn.serveLocal(cdn.hashedPath(`media/${SPIN_WHEEL_MEDIA}`), path.join(__dirname, "..", "swf", "crystal-wheel.swf"));
// a spin a day: one crystal (its wheel's single slots) or two (its four
// double ones of sixteen: the two gift wedges are doubles here), times the
// days in a row spun, up to three. user var 214 (lib/world.js) is where the
// game reads it: the slot's code in the top byte (convertToGemsValue: 5 one
// diamond, 7 two), the days in a row in the next, the day spun (days since
// 1970) below.
const SPIN_ONE = 5;
const SPIN_TWO = 7;
const SPIN_TWO_CHANCE = 4 / 16;
const SPIN_DAYS_MAX = 3;
const today = () => Math.floor(Date.now() / 86400000);

// var 214 as the game should see it: 0 (never spun) opens the wheel at once
const spinVar = account => (stateOf(account).spin || {}).value || 0;

// a spin asked for: {value: var 214, amount: the crystals it won}, amount 0
// for a second spin the same day (the game is shown the first again). the
// caller tells the game the value, then pays (change), so that the HUD does
// not show the prize before the wheel stops.
const dailySpin = account => {
  const state = stateOf(account);
  const last = state.spin || {day: 0, days: 0, value: 0};
  const day = today();
  if (last.day === day) {
    return {value: last.value, amount: 0};
  }
  const days = last.day === day - 1 ? Math.min(last.days + 1, SPIN_DAYS_MAX) : 1;
  const two = Math.random() < SPIN_TWO_CHANCE;
  const value = (((two ? SPIN_TWO : SPIN_ONE) << 24) | (days << 16) | day) >>> 0;
  state.spin = {day, days, value};
  accounts.save(account);
  return {value, amount: (two ? 2 : 1) * days};
};

// time played, for the weekly crystals (lib/world.js counts it)
const notePlayed = (account, seconds) => {
  const state = stateOf(account);
  const week = weekOf(now());
  if (state.playWeek !== week) {
    state.playedBefore = state.playWeek === week - 1 ? state.played : 0;
    state.playWeek = week;
    state.played = 0;
  }
  state.played += seconds;
};

// is a week's crystals due, for an account's state in week `week`? null:
// not yet (they were given this week). false: none, too little was played
// the week before. true: some.
const weeklyDue = (state, week) => {
  if (state.week >= week) {
    return null;
  }
  const lastWeek = state.playWeek === week ? state.playedBefore : state.playWeek === week - 1 ? state.played : 0;
  return lastWeek >= WEEKLY_PLAYED;
};

// the weekly crystals, once a week, at the first look after Monday: at
// login and every minute for those playing.
const weekly = account => {
  const state = stateOf(account);
  const week = weekOf(now());
  const due = weeklyDue(state, week);
  if (due === null) {
    return;
  }
  notePlayed(account, 0);
  state.week = week;
  if (due) {
    change(account, crypto.randomInt(WEEKLY_MIN, WEEKLY_MAX + 1), "weekly", {announce: true});
  }
  else {
    accounts.save(account);
  }
};

// ---- who may risk them ----

const isBooster = account => account.badges.includes(BOOSTER);
const isModerator = account => roles.rankOf(account) >= roles.ROLES.moderator.rank;
const levelOf = account => arenaLevelOf(account);
const LEVEL_GAP = 10; // players further apart in arena level than this may not play for crystals (lib/arena.js too)
const stakeCap = account => STAKE_CAPS.find(([level]) => levelOf(account) >= level)[1];

// why this account may not stake yet, or null
const notEstablished = account => {
  if (EASY || isModerator(account)) {
    return null;
  }
  const state = stateOf(account);
  if (!isBooster(account) && now() - account.createdAt < ESTABLISHED_SECONDS) {
    const days = Math.ceil((account.createdAt + ESTABLISHED_SECONDS - now()) / 86400);
    return `Your account can play for Earth Crystals in ${days} day${days === 1 ? "" : "s"} (or now, if you boost the Discord server).`;
  }
  if (account.playtime < ESTABLISHED_PLAYED) {
    const hours = Math.ceil((ESTABLISHED_PLAYED - account.playtime) / 3600);
    return `Play ${hours} more hour${hours === 1 ? "" : "s"} before playing for Earth Crystals.`;
  }
  if (state.matches < ESTABLISHED_MATCHES) {
    const left = ESTABLISHED_MATCHES - state.matches;
    return `Finish ${left} more arena match${left === 1 ? "" : "es"} before playing for Earth Crystals.`;
  }
  return null;
};

// may this player stake `amount` now? null, or the reason not.
const stakeProblem = (session, amount) => {
  if (!Number.isInteger(amount) || amount < 0 || amount > MAX_STAKE) {
    return `A stake is a whole number of Earth Crystals from 0 to ${MAX_STAKE.toLocaleString()}.`;
  }
  if (amount === 0) {
    return null;
  }
  const {account} = session;
  if (session.browser && !isModerator(account)) {
    return "Earth Crystals can only be played for in the Meadow client, not the browser version.";
  }
  if (session.noDevice && !EASY && !isModerator(account)) {
    return "Earth Crystals can only be played for in the latest Meadow client.";
  }
  const why = notEstablished(account);
  if (why) {
    return why;
  }
  if (amount > stakeCap(account)) {
    return `You can stake up to ${stakeCap(account).toLocaleString()} Earth Crystals at your arena level.`;
  }
  if (balance(account) < amount) {
    return `You have ${balance(account).toLocaleString()} Earth Crystals.`;
  }
  if (stateOf(account).escrow) {
    return "You already have Earth Crystals in a game.";
  }
  return null;
};

// sign-in addresses an account used in the last month, but this machine's
const addressesOf = account => new Set(account.logins
  .filter(login => login.ok && login.address && login.at > now() - ADDRESS_SECONDS && !limits.isLoopback(login.address))
  .map(login => login.address));

// may these two play for crystals together? null, or the reason not (the
// same words whatever the reason: the rest is for the staff).
const pairProblem = (one, other) => {
  if (one === other) {
    return NOT_WITH;
  }
  // not between players far apart in arena level: for anyone
  if (Math.abs(levelOf(one) - levelOf(other)) > LEVEL_GAP) {
    return `You and ${other.username} are more than ${LEVEL_GAP} arena levels apart: you can't play for Earth Crystals together.`;
  }
  if (isModerator(one) && isModerator(other)) {
    return null;
  }
  if (!EASY) {
    if (devices.alts(one).some(alt => alt.username === other.username)) {
      return NOT_WITH;
    }
    const mine = addressesOf(one);
    if ([...addressesOf(other)].some(address => mine.has(address))) {
      return NOT_WITH;
    }
  }
  ensureTables();
  const games = db().prepare("SELECT COUNT(DISTINCT game) AS count FROM crystal_ledger WHERE account_id = ? AND other = ? AND kind = 'stake' AND at >= ?")
    .get(one.id, other.username, weekStart(weekOf(now()))).count;
  if (games >= PAIR_PER_WEEK) {
    return `You have played for Earth Crystals with ${other.username} ${PAIR_PER_WEEK} times this week. Try again next week.`;
  }
  const net = db().prepare("SELECT COALESCE(SUM(change), 0) AS net FROM crystal_ledger WHERE account_id = ? AND other = ? AND kind IN ('stake', 'win', 'refund', 'reversed') AND at >= ?")
    .get(one.id, other.username, now() - FLOW_SECONDS).net;
  if (Math.abs(net) > FLOW_LIMIT) {
    flag(`pair:${one.username}:${other.username}`, [one.username, other.username], `${Math.abs(net)} crystals went one way between them in 30 days`);
    return NOT_WITH;
  }
  return null;
};

// ---- a game played for crystals ----

const games = new Set(); // games whose stakes are held now
let nextGame = 1;
const newGame = kind => `${kind}-${Date.now().toString(36)}-${nextGame++}`;

// both stakes taken and held. false if either cannot pay any more.
const hold = (game, players, amount) => {
  if (players.some(account => balance(account) < amount || stateOf(account).escrow)) {
    return false;
  }
  games.add(game);
  for (const account of players) {
    const other = players.find(one => one !== account);
    change(account, -amount, "stake", {game, other: other.username});
    stateOf(account).escrow = {game, amount};
    accounts.save(account);
  }
  return true;
};

const release = account => {
  stateOf(account).escrow = null;
  accounts.save(account);
};

// the winner takes both stakes, less the fee; what they got
const settle = (game, winner, loser, amount, detail = "") => {
  const pot = amount * 2;
  const fee = Math.ceil(pot * FEE_PERCENT / 100);
  change(winner, pot - fee, "win", {game, other: loser.username, detail: detail || `fee ${fee}`});
  release(winner);
  release(loser);
  games.delete(game);
  return pot - fee;
};

// each gets their stake back
const refund = (game, players, detail) => {
  for (const account of players) {
    const held = stateOf(account).escrow;
    if (held && held.game === game) {
      change(account, held.amount, "refund", {game, detail});
      release(account);
    }
  }
  games.delete(game);
};

// a stake held for a game that is no longer being played (the server
// stopped in the middle of it): back to its owner, at their next login.
const recover = account => {
  const held = stateOf(account).escrow;
  if (held && !games.has(held.game)) {
    change(account, held.amount, "refund", {game: held.game, detail: "the game did not finish"});
    release(account);
  }
};

const finishedMatch = account => {
  stateOf(account).matches++;
  accounts.save(account);
};

// ---- "!coinflip AMOUNT PLAYER" ----

const flips = new Map(); // the asked player's account id -> {from, amount, until}

const coinflip = (session, words, {ask, tell}) => {
  const [amountText, targetName] = words;
  const amount = Number(amountText);
  if (!amountText || !targetName || !/^\d{1,5}$/.test(amountText) || amount < 1) {
    tell(session, `Use: !coinflip AMOUNT PLAYER. Winner takes both stakes, ${FEE_PERCENT}% fee.`);
    return;
  }
  const target = findOnline(targetName);
  if (!target || target === session) {
    tell(session, `${targetName} isn't playing right now.`);
    return;
  }
  const problem = stakeProblem(session, amount) || pairProblem(session.account, target.account);
  if (problem) {
    tell(session, problem);
    return;
  }
  if (stakeProblem(target, amount)) {
    tell(session, `${target.account.username} can't play for ${amount.toLocaleString()} Earth Crystals right now.`);
    return;
  }
  const pot = amount * 2;
  const take = pot - Math.ceil(pot * FEE_PERCENT / 100);
  const offer = {from: session, amount, until: Date.now() + FLIP_WAIT_MS};
  flips.set(target.account.id, offer);
  tell(session, `You asked ${target.account.username} to coinflip for ${amount.toLocaleString()} Earth Crystals.`);
  ask(target, `${session.account.username} wants to coinflip for ${amount.toLocaleString()} Earth Crystals each. The winner takes ${take.toLocaleString()}. Flip?`, () => {
    if (flips.get(target.account.id) !== offer || Date.now() > offer.until || findOnline(session.account.username) !== session) {
      tell(target, "That coinflip is off.");
      return;
    }
    flips.delete(target.account.id);
    // asked again now: either may have spent their crystals meanwhile
    const again = stakeProblem(session, amount) || stakeProblem(target, amount) || pairProblem(session.account, target.account);
    if (again) {
      tell(session, "The coinflip didn't happen: one of you can't play for that many Earth Crystals now.");
      tell(target, "The coinflip didn't happen: one of you can't play for that many Earth Crystals now.");
      return;
    }
    const game = newGame("flip");
    if (!hold(game, [session.account, target.account], amount)) {
      return;
    }
    const [winner, loser] = crypto.randomInt(2) === 0 ? [session, target] : [target, session];
    const got = settle(game, winner.account, loser.account, amount, "coinflip");
    tell(winner, `Heads! You won the coinflip with ${loser.account.username}: +${got.toLocaleString()} Earth Crystals.`);
    tell(loser, `Tails. ${winner.account.username} won the coinflip: -${amount.toLocaleString()} Earth Crystals.`);
    console.log(`[crystals] coinflip ${game}: ${logText(winner.account.username)} beat ${logText(loser.account.username)} for ${amount}`);
  });
};

// ---- for the staff ----

const history = (username, max = 200) => {
  ensureTables();
  const account = accounts.byName(username);
  const rows = account ? db().prepare("SELECT * FROM crystal_ledger WHERE account_id = ? ORDER BY id DESC LIMIT ?").all(account.id, max) : [];
  return {username: account ? account.username : null, balance: account ? balance(account) : 0, rows};
};

const recentFlags = (max = 100) => {
  ensureTables();
  return db().prepare("SELECT * FROM crystal_flags ORDER BY id DESC LIMIT ?").all(max);
};

// a game undone: every crystal it moved, moved back. false if there is no
// such game, or it was undone already.
const reverse = (game, by) => {
  ensureTables();
  const rows = db().prepare("SELECT * FROM crystal_ledger WHERE game = ? AND kind IN ('stake', 'win', 'refund')").all(game);
  if (!rows.length || db().prepare("SELECT 1 FROM crystal_ledger WHERE game = ? AND kind = 'reversed'").get(game) || games.has(game)) {
    return false;
  }
  for (const row of rows) {
    const account = accounts.byId(row.account_id);
    if (account) {
      change(account, -row.change, "reversed", {game, other: row.other, detail: `by ${by}`});
    }
  }
  return true;
};

// for the account page
const summary = account => {
  ensureTables();
  const state = stateOf(account);
  return {
    balance: balance(account),
    canStake: notEstablished(account) === null,
    why: notEstablished(account),
    stakeCap: stakeCap(account),
    arenaLevel: levelOf(account),
    booster: isBooster(account),
    matches: state.matches,
    nextWeek: weekStart(weekOf(now()) + 1),
    recent: db().prepare("SELECT at, change, balance, kind, other, detail FROM crystal_ledger WHERE account_id = ? ORDER BY id DESC LIMIT 20").all(account.id),
  };
};

module.exports = {
  CURRENCY, FEE_PERCENT, MAX_STAKE,
  setFinder(finder) {
    findOnline = finder;
  },
  balance, change, starter, notePlayed, weekly, recover, SPIN_WHEEL_MEDIA, spinVar, dailySpin,
  // for the tests
  weekOf, weeklyDue, notEstablished,
  stakeProblem, pairProblem, newGame, hold, settle, refund, finishedMatch, flag,
  coinflip, history, recentFlags, reverse, summary,
};
