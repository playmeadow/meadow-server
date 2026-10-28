"use strict";

const cdn = require("./cdn.js");
const customItems = require("./customitems.js");
const defpacks = require("./defpacks.js");
const extraMusic = require("./extramusic.js");

// a den item's pictures, as the game asks for them (DenItemHelper, by way
// of DenItemServer): "items/<id << 16 | picture>" from the content server.
// the CDN has them for the game's own den items only, so the extra music
// tracks (lib/extramusic.js) and the custom den items (lib/customitems.js:
// staff's, players', uploaded music) had none, and showed as an empty slot:
// a track given was in the den's music list, and could not be seen there.
// each is drawn as the item it was made from: the extra tracks as the
// track their rows copy, a custom item as its base.

// the picture numbers a den item is asked for by (DenItem.getIconId, and
// the den's own category ids), with room to spare
const PICTURES = 16;

let made = -1; // defpacks.customVersion() the map below was made at
let map = new Map(); // content path -> the base item's content path

const pathOf = (id, picture) => cdn.hashedPath(`items/${((id << 16) | picture) >>> 0}`);

const rebuild = () => {
  map = new Map();
  const bases = [...extraMusic.ids.map(id => [id, extraMusic.TEMPLATE]),
    ...customItems.list().filter(entry => entry.kind === "den").map(entry => [entry.id, entry.base])];
  for (const [id, base] of bases) {
    for (let picture = 0; picture < PICTURES; picture++) {
      map.set(pathOf(id, picture), pathOf(base, picture));
    }
  }
  made = defpacks.customVersion();
};

// {body} for a request for one of these items' pictures, or undefined when
// it is for something else. `mayFetch` as cdn.get takes it.
const asset = async (relPath, mayFetch) => {
  if (made !== defpacks.customVersion()) {
    rebuild();
  }
  const from = map.get(relPath);
  if (!from) {
    return undefined;
  }
  return {body: await cdn.get(from, mayFetch)};
};

module.exports = {asset};
