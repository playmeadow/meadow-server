"use strict";

const accounts = require("./accounts.js");
const achievements = require("./achievements.js");
const defpacks = require("./defpacks.js");
const dens = require("./dens.js");
const {CURRENCIES, hasRoom, addClothing, sendClothingAdded} = require("./player.js");

// gifts lying about in the lands (client side: WorldItemsManager): a room
// has up to three spots, a world-item def says which spot it sits in, what
// it gives and which bit of a user var records that the player took it.
// the real game put a few out at a time. here each spot shows the first
// gift the player has not taken yet, so all of them come round in turn.

// WorldItemDef.giftType
const GIFT_DEN_ITEM = "0";
const GIFT_GEMS = "1";
const GIFT_DIAMONDS = "2";
const GIFT_CLOTHING = "3";
const CURRENCY_OF = {[GIFT_GEMS]: 0, [GIFT_DIAMONDS]: 3};
const NO_CURRENCY = -1;

const taken = (account, def) => ((Number(account.userVars[def.userVarRefId]) || 0) >>> Number(def.uvIndex)) & 1;

// the defs on show for this player, one per spot: generic list 583.
const usable = account => {
  const bySpot = new Map();
  for (const id of defpacks.worldItemIds()) {
    const def = defpacks.worldItemDef(id);
    if (!bySpot.has(def.position) && !taken(account, def)) {
      bySpot.set(def.position, id);
    }
  }
  return [...bySpot.values()];
};

const handlers = {
  // WorldItemsXtCommManager.sendAcceptGift: [defId, denItemVersion,
  // clothingColourIndex]. the reply (WorldItemsManager.onGiftResponse) is
  // [success, new currency amount or -1].
  wig(session, roomId, [defId, version, colorIndex]) {
    const {account} = session;
    const def = defpacks.worldItemDef(defId);
    if (!def || !usable(account).includes(Number(def.id))
      || (def.giftType === GIFT_DEN_ITEM && !hasRoom(account, "denItems")) || (def.giftType === GIFT_CLOTHING && !hasRoom(account, "items"))) {
      session.sendXt("wig", -1, 0, NO_CURRENCY);
      return;
    }
    let amount = NO_CURRENCY;
    if (def.giftType === GIFT_DEN_ITEM && defpacks.denItemDef(def.giftRefId)) {
      dens.giveDenItem(account, def.giftRefId, version);
      dens.sendDenItems(session);
    }
    else if (def.giftType === GIFT_CLOTHING && defpacks.itemDef(def.giftRefId)) {
      const colors = String(defpacks.itemDef(def.giftRefId).colors).split(",");
      sendClothingAdded(session, addClothing(account, def.giftRefId, colors[Number(colorIndex)] || colors[0]));
    }
    else if (Object.hasOwn(CURRENCY_OF, def.giftType)) {
      const currency = CURRENCIES[CURRENCY_OF[def.giftType]];
      account.currency[currency] = (account.currency[currency] || 0) + Number(def.amount);
      achievements.currencyChanged(account, currency, Number(def.amount));
      amount = account.currency[currency];
    }
    else {
      session.sendXt("wig", -1, 0, NO_CURRENCY);
      return;
    }
    // the client reads the bit straight from its copy of the user var.
    achievements.set(account, def.userVarRefId, ((Number(account.userVars[def.userVarRefId]) || 0) | (1 << Number(def.uvIndex))) >>> 0);
    accounts.save(account);
    session.sendXt("wig", -1, 1, amount);
  },
};

module.exports = {handlers, usable};
