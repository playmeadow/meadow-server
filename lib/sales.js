"use strict";

const history = require("./sale-dates.json");

// when shop items are on sale. the client decides that by itself: a shop
// drops whatever its def's availabilityStartTime..availabilityEndTime does
// not cover today (GenericListXtCommManager.filterIitems), tags what
// started in the last ten days as new and counts down to the end. so the
// defs are what to change, and they are re-stamped here before a client
// gets them.
//
// the official game rewrote an item's window each time the item came back,
// and lib/sale-dates.json has every window found in the builds the CDN
// still serves (tools/sale-history.js). here each window comes round again
// every year on the same dates: an item whose window, moved to this year,
// covers today is stamped with it; any other gets the next one coming, and
// stays hidden until then. items with no window in the file are left as
// their def has them.

const DAY = 86400;
// sold for most of a year at a stretch: not seasonal, so always in stock.
const ALWAYS_DAYS = 330;

// [start, end] in seconds for the def to carry at `now`, or null to leave it.
const windowFor = (windows, now) => {
  if (!windows || windows.length === 0) {
    return null;
  }
  if (windows.some(([startDay, endDay]) => endDay - startDay >= ALWAYS_DAYS)) {
    return [0, 0];
  }
  const year = new Date(now * 1000).getUTCFullYear();
  let current = null;
  let next = null;
  for (const [startDay, endDay] of windows) {
    const first = new Date(startDay * DAY * 1000);
    for (const candidate of [year - 1, year, year + 1]) {
      const start = Date.UTC(candidate, first.getUTCMonth(), first.getUTCDate()) / 1000;
      const end = start + (endDay - startDay) * DAY;
      if (start <= now && now <= end) {
        current = !current || end > current[1] ? [start, end] : current;
      }
      else if (start > now) {
        next = !next || start < next[0] ? [start, end] : next;
      }
    }
  }
  return current || next;
};

// A testing switch (the admin panel's Debug page): with it on, nothing has
// sale dates at all, so every item shows wherever it is listed. kept in memory; a restart turns it off.
let everythingOnSale = false;

// whether a seasonal item is in its season at `now`: it has sale dates, none
// of them makes it a year-round one, and one of them, moved to this year,
// covers today. (With the switch above on, any seasonal item is.)
const inSeason = (kind, id, now = Date.now() / 1000) => {
  const windows = (history[kind] || {})[String(id)];
  if (!windows || windows.length === 0 || windows.some(([startDay, endDay]) => endDay - startDay >= ALWAYS_DAYS)) {
    return false;
  }
  const [start, end] = windowFor(windows, now);
  return everythingOnSale || (start <= now && now <= end);
};

// re-stamps the rows of a defPack (`kind`: clothing, denItems or diamond) in
// place. returns how many are on sale at `now` thanks to it.
const stamp = (kind, pack, now = Date.now() / 1000) => {
  const windows = history[kind] || {};
  let onSale = 0;
  for (const def of Object.values(pack)) {
    const window = everythingOnSale ? [0, 0] : windowFor(windows[String(def.id)], now);
    if (window) {
      def.availabilityStartTime = String(window[0]);
      def.availabilityEndTime = String(window[1]);
      onSale += window[0] <= now && (window[1] === 0 || now <= window[1]) ? 1 : 0;
    }
  }
  return onSale;
};

const always = pack => {
  for (const def of Object.values(pack)) {
    def.availabilityStartTime = "0";
    def.availabilityEndTime = "0";
  }
};

// the day the stamps were made for; a new day needs new ones.
const today = (now = Date.now() / 1000) => Math.floor(now / DAY);

module.exports = {
  stamp,
  always,
  today,
  windowFor,
  inSeason,
  everythingOnSale: () => everythingOnSale,
  setEverythingOnSale(on) {
    everythingOnSale = on === true;
  },
};
