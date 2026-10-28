"use strict";

const defpacks = require("./defpacks.js");

// Epic Dens: the world map's list of dens worth a visit (client side:
// VolumeSelector, DenXtCommManager.requestDenHighest).
//
// the official list named players, and its "AJHQ" button led to a showcase
// den Animal Jam HQ had furnished, a new one every so often, held as party
// 36. those showcase dens are still on the CDN, 53 of them, each a whole
// room with its furniture in the file. here the list is the showcase dens:
// the client shows a name per row and asks to enter "den<that name>", which
// the server answers by putting the player in the room. the client draws
// twenty rows at most, so the list is a different twenty each day, and the
// AJHQ button goes to one more.
//
// the files do not say what the dens were called. each is named after the
// den type it was built in, going by its file name.
const KINDS = new Map([
  ["skyden", "Sky Kingdom"], ["ginger", "Gingerbread House"], ["winterp", "Winter Palace"], ["lcastle", "Lucky Castle"],
  ["beach", "Beach House"], ["crystal_", "Crystal Palace"], ["sprgctg", "Spring Cottage"], ["peck", "Peck's Den"],
  ["pixel", "Pixel Place"], ["greely", "Greely's Hideout"], ["gilbert", "Gilbert's Palace"], ["haunted", "Haunted Manor"],
  ["snofort", "Snow Fort"], ["cottage", "Friendship Cottage"], ["liza", "Liza's Garden"], ["barn", "Ol' Barn"],
  ["solarcade", "Sol Arcade"], ["graham", "Graham's Observatory"], ["bounce", "Bounce House"], ["cosmotree", "Cosmo's Tree House"],
  ["waterpark", "Water Park"], ["greelyhalloween", "Haunted Hideout"], ["fallfree", "Autumn House"],
  ["friendshipfortress", "Friendship Fortress"], ["epicbetaden", "Epic Beta Den"],
  ["fantcastle", "Fantasy Castle"], ["sandcastle", "Sandcastle"],
]);
const FOLDER = "epic_dens/room_";
const ROWS_SHOWN = 20; // VolumeSelector.createDenWindows

let dens = null; // [{name, base}], in room id order

const all = () => {
  if (!dens) {
    const count = new Map();
    dens = defpacks.roomPaths().filter(path => path.startsWith(FOLDER)).map(path => {
      const base = path.replace(/\//g, ".");
      // an older version of one (lib/extrarooms.js) is "<file>_old"
      const old = path.endsWith("_old");
      const kind = path.slice(FOLDER.length).replace(/_old$/, "").replace(/\d*$/, "");
      return {title: (KINDS.get(kind) || kind) + (old ? " (old)" : ""), base, id: Number(defpacks.roomDef(base).id)};
    }).sort((one, other) => one.id - other.id);
    // "Sky Kingdom 2" where there are several of a kind.
    for (const den of dens) {
      count.set(den.title, (count.get(den.title) || 0) + 1);
      den.number = count.get(den.title);
    }
    for (const den of dens) {
      den.name = count.get(den.title) > 1 ? `${den.title} ${den.number}` : den.title;
    }
  }
  return dens;
};

const today = () => Math.floor(Date.now() / 86400000);

// the names in today's list.
const fromToday = (day, offset) => all()[(day * ROWS_SHOWN + offset) % all().length];
const list = (day = today()) => Array.from({length: Math.min(ROWS_SHOWN, all().length)}, (_, i) => fromToday(day, i).name);

const byName = name => all().find(den => den.name.toLowerCase() === String(name).toLowerCase());

// the den behind the AJHQ button today: the one after today's list.
const featured = (day = today()) => fromToday(day, ROWS_SHOWN);

module.exports = {all, list, byName, featured};
