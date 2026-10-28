"use strict";

const defpacks = require("./defpacks.js");
const sales = require("./sales.js");
const {DIAMOND_TYPES} = require("./player.js");
const wiki = require("./shop-stock.json");

// what stands on each shop's shelves. no file of the game says: the official
// server sent a shop's list when it was opened. lib/shop-stock.json has it
// from the AJ Classic Wiki, per generic list (tools/shop-stock.py makes the
// file and says which shop was taken for which list, and where that was a
// guess): "now", what the wiki has on sale there, and "former", what was
// sold there once. A shop stocks all of the first, and of the second what
// is in its season today (lib/sales.js): a shop's seasonal things come back
// to it each year, and what left for good stays away.

const DEF_ITEM = 1000;
const DEF_DEN_ITEM = 1030;
const DEF_DIAMOND = 1054;
const DEF_COMBINED_LIST = 1060;

// "kind:refId" -> diamond def id, for what a diamond shop sells.
let diamondIds = null;
const diamondId = (type, refId) => {
  if (!diamondIds) {
    diamondIds = new Map();
    for (const id of defpacks.diamondIds()) {
      const def = defpacks.diamondDef(id);
      // an item with two defs keeps the later one.
      diamondIds.set(`${def.type}:${def.refId}`, id);
    }
  }
  return diamondIds.get(`${type}:${refId}`);
};

const KINDS = {
  clothing: {salesKind: "clothing", sold: () => defpacks.clothingIds(), diamondType: DIAMOND_TYPES.clothing},
  den: {salesKind: "denItems", sold: () => defpacks.denItemIds(), diamondType: DIAMOND_TYPES.denItem},
};

// the ids of one kind a list stocks. with `asDiamonds` they are diamond def
// ids, and what has no diamond price is left out.
const shelf = (stock, kind, asDiamonds) => {
  const {salesKind, sold, diamondType} = KINDS[kind];
  const sellable = new Set(sold());
  const music = kind === "den" && stock.music !== undefined ? new Set(defpacks.musicIds()) : null;
  const fits = id => sellable.has(id) && (!music || music.has(id) === stock.music);
  const ids = [];
  for (const [items, onlySeasonal] of [[stock.now[kind], false], [stock.former[kind], true]]) {
    for (const id of items.filter(fits)) {
      const entry = asDiamonds ? diamondId(diamondType, id) : id;
      if (entry !== undefined && (!onlySeasonal || sales.inSeason(asDiamonds ? "diamond" : salesKind, entry))) {
        ids.push(entry);
      }
    }
  }
  return ids;
};

const make = (listId, type) => {
  const stock = wiki.lists[listId];
  if (!stock) {
    return null;
  }
  if (type === DEF_ITEM) {
    return {entries: shelf(stock, "clothing", false)};
  }
  if (type === DEF_DEN_ITEM) {
    return {entries: shelf(stock, "den", false)};
  }
  if (type === DEF_DIAMOND) {
    return {entries: [...shelf(stock, "clothing", true), ...shelf(stock, "den", true)]};
  }
  if (type === DEF_COMBINED_LIST) {
    // [kinds, count per kind, entries of each kind in turn]
    // (ItemXtCommManager.setupShopItemObject).
    const parts = [[DEF_ITEM, shelf(stock, "clothing", false)], [DEF_DEN_ITEM, shelf(stock, "den", false)]]
      .filter(([, ids]) => ids.length > 0);
    const count = parts.reduce((sum, [, ids]) => sum + ids.length, 0);
    return count === 0 ? null : {
      count,
      entries: [parts.map(([kind]) => kind).join(","), parts.map(([, ids]) => ids.length).join(","), ...parts.flatMap(([, ids]) => ids)],
    };
  }
  return null;
};

// what the wiki has for this list, as the entries of a `gl` reply (and their
// count, where that is not their number); null when it has nothing, and the
// shop is stocked some other way. made once a day, as the seasons are.
const made = new Map(); // list id -> {day, allOnSale, stock}
const list = (listId, type) => {
  const key = Number(listId);
  const kept = made.get(key);
  if (kept && kept.day === sales.today() && kept.allOnSale === sales.everythingOnSale()) {
    return kept.stock;
  }
  const stock = make(key, type);
  made.set(key, {day: sales.today(), allOnSale: sales.everythingOnSale(), stock: stock && stock.entries.length > 0 ? stock : null});
  return made.get(key).stock;
};

module.exports = {list};
