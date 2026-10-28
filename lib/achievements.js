"use strict";

const accounts = require("./accounts.js");
const defpacks = require("./defpacks.js");

// achievements (client side: AchievementManager, AchievementXtCommManager).
// an achievement def names a user var and the value it has to reach. most
// user vars are counters the official servers kept ("gems earned", "buddies
// added"); the ones this server can count itself are kept here, and the rest
// are whatever the client last set them to (see "zs" in world.js).
//
// A player's achievements are {inv, def} pairs in account.achievements. the
// client learns about a new one from the reply to a user var change.

// counters only the server changes; a client's own "zs" for one is ignored.
const VARS = {
  gemsEarned: 1,
  gemsSpent: 2,
  denItemsBought: 3,
  clothesBought: 4,
  jamAGramsSent: 38,
  giftsSent: 39,
  buddiesAdded: 40,
  animals: 51,
  pets: 212,
  adoptAPets: 426,
  worldItemsTaken: 439, // one bit per gift found in the lands (lib/worlditems.js)
};
const SERVER_VARS = new Set(Object.values(VARS));
const CURRENCY_GEMS = "gems";

let findOnline = () => null;

let byVar = null;
const defsFor = varId => {
  if (!byVar) {
    byVar = new Map();
    for (const def of defpacks.achievementDefs()) {
      byVar.set(def.userVarRef, [...(byVar.get(def.userVarRef) || []), def]);
    }
  }
  return byVar.get(Number(varId)) || [];
};

// gives the account every achievement its value of `varId` has earned and
// returns the new ones. the caller saves.
const award = (account, varId) => {
  const value = Number(account.userVars[varId]) || 0;
  const earned = [];
  for (const def of defsFor(varId)) {
    if (value >= def.triggerAmount && !account.achievements.some(have => have.def === def.id)) {
      const achievement = {inv: account.nextInv++, def: def.id};
      account.achievements.push(achievement);
      earned.push(achievement);
    }
  }
  return earned;
};

// AchievementXtCommManager.setUserVarResponse: [varId, value, newCount,
// (invId, defId)...]. sent unasked it still updates the client's copy of the
// var and pops up the new achievements.
const sendVar = (session, varId, earned = []) => {
  session.sendXt("zs", -1, varId, session.account.userVars[varId], earned.length,
    ...earned.flatMap(achievement => [achievement.inv, achievement.def]));
};

// sets a user var, hands out what that earns and tells the player if they
// are online. the caller saves.
const set = (account, varId, value) => {
  if (account.userVars[varId] === value) {
    return;
  }
  account.userVars[varId] = value;
  const earned = award(account, varId);
  const session = findOnline(account.username);
  if (session) {
    sendVar(session, varId, earned);
  }
};

const add = (account, varId, amount = 1) => set(account, varId, (Number(account.userVars[varId]) || 0) + amount);

// counts a change of some currency towards "gems earned" / "gems spent".
const currencyChanged = (account, currencyName, delta) => {
  if (currencyName === CURRENCY_GEMS && delta !== 0) {
    add(account, delta > 0 ? VARS.gemsEarned : VARS.gemsSpent, Math.abs(delta));
  }
};

// brings the counters that mirror what an account owns up to date (accounts
// from before achievements existed, gifts from the admin panel, ...).
const refresh = account => {
  set(account, VARS.animals, Math.max(Number(account.userVars[VARS.animals]) || 0, account.avatars.length));
  set(account, VARS.pets, Math.max(Number(account.userVars[VARS.pets]) || 0, account.pets.length));
  set(account, VARS.buddiesAdded, Math.max(Number(account.userVars[VARS.buddiesAdded]) || 0, account.buddies.length));
  set(account, VARS.adoptAPets, account.adoptAPets.length);
};

// gives one achievement outright (the admin panel). false if unknown or owned.
const grant = (account, defId) => {
  const def = defpacks.achievementDefs().find(candidate => candidate.id === Number(defId));
  if (!def || account.achievements.some(have => have.def === def.id)) {
    return false;
  }
  const achievement = {inv: account.nextInv++, def: def.id};
  account.achievements.push(achievement);
  accounts.save(account);
  const session = findOnline(account.username);
  if (session) {
    if (account.userVars[def.userVarRef] === undefined) {
      account.userVars[def.userVarRef] = 0;
    }
    sendVar(session, def.userVarRef, [achievement]);
  }
  return true;
};

// for the account page: how many achievements the account has, and for
// each thing the game counts, how far along it is. the defs carry no
// readable title, only an internal name like "2_Gems_10000_Gems_Earned".
const label = def => String(def.name).split("_").filter(word => word && !/^\d+$/.test(word))
  .filter((word, index, words) => word !== words[index - 1]).join(" ");
const progress = account => {
  const all = defpacks.achievementDefs();
  const have = new Set(account.achievements.map(achievement => achievement.def));
  const groups = new Map();
  for (const def of all) {
    groups.set(def.userVarRef, [...(groups.get(def.userVarRef) || []), def]);
  }
  const counted = [...groups].map(([varId, defs]) => {
    const steps = defs.map(def => def.triggerAmount).sort((one, other) => one - other);
    const value = Number(account.userVars[varId]) || 0;
    const next = steps.find(step => step > value);
    return {name: label(defs[defs.length - 1]), value, next: next === undefined ? null : next, earned: defs.filter(def => have.has(def.id)).length, of: defs.length};
  });
  return {earned: have.size, of: all.length, counted: counted.sort((one, other) => one.name.localeCompare(other.name))};
};

const handlers = {
  // AchievementXtCommManager.getAchievementsResponse: [username, count,
  // (invId, defId)...]; a count of -1 says "nothing new since you last asked".
  za(session, roomId, [username]) {
    const account = accounts.byName(username);
    const list = account ? account.achievements : [];
    session.sendXt("za", -1, account ? account.username : username, list.length, ...list.flatMap(achievement => [achievement.inv, achievement.def]));
  },
};

module.exports = {
  // is this a user var some achievement watches, and not one of the server's own?
  counts: varId => !SERVER_VARS.has(Number(varId)) && defsFor(varId).length > 0,
  VARS,
  SERVER_VARS,
  handlers,
  award,
  sendVar,
  set,
  add,
  currencyChanged,
  refresh,
  grant,
  progress,
  setFinder(finder) {
    findOnline = finder;
  },
};
