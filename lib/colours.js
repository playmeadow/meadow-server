"use strict";

const {logText} = require("./logtext.js");
const accounts = require("./accounts.js");

// custom colours. the game stores a colour as four palette indexes packed in
// one number, which leaves no room for "any hex colour". so a number in a
// range no real colour uses (CUSTOM_BASE and up) is instead the id of an
// entry here: the four RGB values that layer is drawn with. the patched
// client keeps the entries it has been sent (PaletteHelper.customColors).
//
// a game is sent an entry just before the first message that carries its
// id (unseen, from lib/sfs.js's write), not the whole table: the table grows
// by thousands a day, and every game holding all of it, and hearing of every
// new one, was the cost the old limits guarded. tints are the exception: a
// pet's or den item's tint is a slot number in its bits, not an id any
// message shows, so tints still go to every game (isTint, lib/world.js).

const CUSTOM_BASE = 0xFD000000; // top byte 0xFD: unused by every item and animal def
const config = require("../config.js");
const MAX_ID = 0xFDFFFFFF; // the last id with the top byte 0xFD
const MAX_RGB = 0xFFFFFF;

const SCHEMA = "CREATE TABLE IF NOT EXISTS custom_colours (id INTEGER PRIMARY KEY, rgb TEXT NOT NULL UNIQUE)";

const byKey = new Map(); // "r1,r2,r3,r4" -> id
const entries = new Map(); // id -> [r1, r2, r3, r4]
let nextId = CUSTOM_BASE; // one past the highest id ever given: ids are never used twice

const load = () => {
  const db = accounts.database();
  db.exec(SCHEMA);
  for (const row of db.prepare("SELECT id, rgb FROM custom_colours").all()) {
    byKey.set(row.rgb, row.id);
    entries.set(row.id, row.rgb.split(",").map(Number));
    nextId = Math.max(nextId, row.id + 1);
  }
  console.log(`[colours] ${logText(entries.size)} custom colours`);
};

const valid = rgbs => rgbs.length === 4 && rgbs.every(value => Number.isInteger(value) && value >= 0 && value <= MAX_RGB);

// the id for these four RGB values, making the entry if it is new and
// `mayCreate` is not false. returns {id, rgbs, created}; null when the
// values are bad, and {full: true} when a new entry would be needed and may
// not be made (the table is full, or the asker has made enough today).
const allocate = (rgbs, mayCreate = true) => {
  if (!valid(rgbs)) {
    return null;
  }
  const key = rgbs.join(",");
  if (byKey.has(key)) {
    return {id: byKey.get(key), rgbs, created: false};
  }
  if (!mayCreate || entries.size >= config.maxCustomColours || nextId > MAX_ID) {
    return {full: true};
  }
  const id = nextId++;
  accounts.database().prepare("INSERT INTO custom_colours (id, rgb) VALUES (?, ?)").run(id, key);
  byKey.set(key, id);
  entries.set(id, rgbs);
  return {id, rgbs, created: true};
};

// an entry made as a tint: [rgb, strength 1-100, 0, 0] (lib/pets.js, the
// den item tints of lib/admin.js).
const isTint = rgbs => Number.isInteger(rgbs[1]) && rgbs[1] >= 1 && rgbs[1] <= 100 && !rgbs[2] && !rgbs[3];

// [id, r1, r2, r3, r4] for the entries `wanted` keeps (every one by default),
// in groups small enough for one message.
const chunks = (wanted = () => true, size = 200) => {
  const all = [...entries].filter(([id, rgbs]) => wanted(id, rgbs)).map(([id, rgbs]) => [id, ...rgbs]);
  const out = [];
  for (let i = 0; i < all.length; i += size) {
    out.push(all.slice(i, i + size));
  }
  return out;
};

// the ids a game has been sent, kept on its session
const seenBy = session => {
  if (!session.coloursSeen) {
    session.coloursSeen = new Set();
  }
  return session.coloursSeen;
};
const markSeen = (session, id) => seenBy(session).add(id);

// the entries this message names that its game has not been sent yet, now
// counted as sent: [id, r1, r2, r3, r4] each. an id is a whole number of
// eight to ten digits, as written or as the signed int a client may echo.
const ID_TEXT = /(?<!\d)-?\d{8,10}(?!\d)/g;
const unseen = (session, message) => {
  const out = [];
  if (entries.size === 0) {
    return out;
  }
  for (const match of message.matchAll(ID_TEXT)) {
    const id = Number(match[0]) >>> 0;
    if (id >= CUSTOM_BASE && id <= MAX_ID && entries.has(id) && !seenBy(session).has(id)) {
      seenBy(session).add(id);
      out.push([id, ...entries.get(id)]);
    }
  }
  return out;
};

// is this number a colour the game can draw: one of its own (anything below
// the custom range), or an entry of the table?
const known = id => id < CUSTOM_BASE || id > MAX_ID || entries.has(id);

// the four RGB values of an entry, or null.
const rgbsOf = id => entries.get(id) || null;

module.exports = {CUSTOM_BASE, load, allocate, chunks, isTint, markSeen, unseen, known, rgbsOf, count: () => entries.size};
