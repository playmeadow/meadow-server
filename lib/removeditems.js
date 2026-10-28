"use strict";

// the game's own items taken out of Meadow (lib/removed-items.json). their
// rows are left out of the item tables as they load (lib/defpacks.js), so
// the server and the game alike no longer know them: no item finder, shop
// or list has them, and nothing gives them. what players already had is
// taken from every inventory when the server starts (sweep).

const list = require("./removed-items.json");

const ids = {
  clothing: new Set(list.clothing.map(entry => Number(entry.id))),
  den: new Set(list.den.map(entry => Number(entry.id))),
};

const isRemoved = (kind, id) => ids[kind].has(Number(id));

// a pack of item rows without the removed ones of `kind`
const without = kind => pack => {
  for (const [key, def] of Object.entries(pack)) {
    if (def && ids[kind].has(Number(def.id))) {
      delete pack[key];
    }
  }
  return pack;
};

// out of every account: the items, anything up for trade, and what is
// worn or placed with them, which goes with its entry. returns how many.
const sweep = accounts => {
  let count = 0;
  for (const account of accounts.all()) {
    let changed = false;
    for (const [kind, collection] of [["clothing", "items"], ["den", "denItems"]]) {
      const gone = new Set((account[collection] || []).filter(entry => ids[kind].has(Number(entry.def))).map(entry => entry.inv));
      if (gone.size) {
        account[collection] = account[collection].filter(entry => !gone.has(entry.inv));
        account.tradeList = (account.tradeList || []).filter(entry => !gone.has(entry.inv));
        count += gone.size;
        changed = true;
      }
    }
    if (changed) {
      accounts.save(account);
    }
  }
  if (count) {
    console.log(`[items] took ${count} removed item${count === 1 ? "" : "s"} from inventories`);
  }
  return count;
};

module.exports = {isRemoved, without, sweep};
