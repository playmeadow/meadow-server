"use strict";

const accounts = require("./accounts.js");
const achievements = require("./achievements.js");
const defpacks = require("./defpacks.js");

// the Adopt-A-Pet checklist (client side: AdoptAPetManager, CheckListPopup):
// the collectable toy pets a player has "found". the real game handed them
// out through codes packed with the toys. here every day's first login finds
// one the player does not have yet, and the admin panel can give any.
//
// account.adoptAPets holds {inv, def, ts, seen}.

const jamaaDate = () => Math.floor(Date.now() / 86400000);

// adds one to the account's checklist; null if unknown or already there.
// the caller saves.
const give = (account, defId) => {
  if (!defpacks.adoptAPetDef(defId) || account.adoptAPets.some(have => have.def === Number(defId))) {
    return null;
  }
  const found = {inv: account.nextInv++, def: Number(defId), ts: Math.floor(Date.now() / 1000), seen: false};
  account.adoptAPets.push(found);
  achievements.set(account, achievements.VARS.adoptAPets, account.adoptAPets.length);
  return found;
};

// the day's find, at login. the caller saves.
const dailyFind = account => {
  if (account.adoptAPetDay === jamaaDate()) {
    return null;
  }
  account.adoptAPetDay = jamaaDate();
  const missing = defpacks.adoptAPetIds().filter(id =>
    defpacks.adoptAPetDef(id).hidden !== "1" && !account.adoptAPets.some(have => have.def === id));
  return missing.length ? give(account, missing[Math.floor(Math.random() * missing.length)]) : null;
};

// GamePlay.onWorldLogIn -> AdoptAPetData: what the login message lists.
const loginList = account => account.adoptAPets.map(found => ({invId: found.inv, defId: found.def, ts: found.ts, hasSeen: found.seen}));

const handlers = {
  // CheckListPopup.onOtherUserUsableAdoptAPetData: [success, count, (defId, invId)...]
  pad(session, roomId, [username]) {
    const account = accounts.byName(username);
    const list = account ? account.adoptAPets : [];
    session.sendXt("pad", -1, account ? 1 : 0, list.length, ...list.flatMap(found => [found.def, found.inv]));
  },

  // BuddyCard.onAdoptAPetCount: how many that player has (0 hides the button).
  padc(session, roomId, [username]) {
    const account = accounts.byName(username);
    session.sendXt("padc", -1, account ? account.adoptAPets.length : 0);
  },

  // CheckListPopup: the ones the player has now looked at, [defId, ...].
  pads(session, roomId, defIds) {
    const seen = new Set(defIds.map(Number));
    for (const found of session.account.adoptAPets) {
      found.seen = found.seen || seen.has(found.def);
    }
    accounts.save(session.account);
  },
};

module.exports = {handlers, give, dailyFind, loginList};
