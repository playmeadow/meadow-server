"use strict";

const fs = require("fs");
const path = require("path");
const config = require("../config.js");

// which usernames a player may not choose (sign-up, and a request for a new
// name): the ones that would pass for whoever runs the game, and slurs.
// deliberately loose. A name is refused for BEING such a word, or having
// one as one of its words; a name that merely contains one is let through,
// and whoever runs the server deals with the odd one by hand (rename, in
// the admin panel). the lists are files, read again when they change:
//   lib/reserved-names.txt       staff-like names
//   public/filter/level1.txt     the chat filter's first level: slurs, threats
//   lib/sexual-names.txt         sexual words, refused anywhere in a name
//                                (bar the short ones marked "=", see the file)
// and the names of the Epic Dens, which are how a showcase den is asked for.

const RESERVED_FILE = path.join(__dirname, "reserved-names.txt");
const SLURS_FILE = path.join(config.publicDir, "filter", "level1.txt");
const SEXUAL_FILE = path.join(__dirname, "sexual-names.txt");
const DIGITS = {0: "o", 1: "i", 3: "e", 4: "a", 5: "s", 7: "t"};

// A word as it is compared: small letters, digits at either end dropped
// ("mod123"), digits inside read as the letters they stand in for. this and
// the matching below are the chat filter's own rules (AJClient.filterText
// in the patched client), since the slurs are its first list.
const plain = word => word.toLowerCase().replace(/^\d+|\d+$/g, "").replace(/\d/g, digit => DIGITS[digit] || "").replace(/[^a-z]/g, "");
// A letter drawn out ("mooood") is undone, but only for a word that has one
// drawn out three times or more: "coon" must not be the same word as "con".
const squash = word => word.replace(/(.)\1+/g, "$1");
const stretched = word => /(.)\1\1/.test(word);

// the entries of a list file: [{text, prefix, word}], text made plain as
// above. "word" is for a line marked "=": in lib/sexual-names.txt the rest
// are matched anywhere in a name.
const lists = new Map(); // file -> {mtime, entries}
// the file is opened once, and its time and its words are both of what was
// opened: a list changed in between cannot be read under the old one's time.
const read = file => {
  let fd;
  try {
    fd = fs.openSync(file, "r");
  }
  catch (err) {
    return [];
  }
  try {
    const mtime = fs.fstatSync(fd).mtimeMs;
    const kept = lists.get(file);
    if (kept && kept.mtime === mtime) {
      return kept.entries;
    }
    const entries = fs.readFileSync(fd, "utf8").split(/\r?\n/).map(line => line.trim()).filter(line => line && !line.startsWith("#"))
      .map(line => ({text: line.replace(/^=/, "").replace(/\*$/, "").split(/\s+/).map(plain).join(""), prefix: line.endsWith("*"), word: line.startsWith("=")}))
      .filter(entry => entry.text.length >= 2);
    lists.set(file, {mtime, entries});
    return entries;
  }
  finally {
    fs.closeSync(fd);
  }
};

let epicDens = null;
const denNames = () => {
  if (!epicDens) {
    try {
      const names = require("./epicdens.js").all().map(den => plain(den.name));
      if (names.length === 0) {
        return names; // the game's data is not loaded yet
      }
      epicDens = names;
    }
    catch (err) {
      return [];
    }
  }
  return epicDens;
};

const refused = username => {
  const words = String(username).split(/[ .-]+/).map(plain).filter(Boolean);
  const whole = plain(String(username));
  const same = (word, entry) => word === entry.text || (entry.prefix && word.startsWith(entry.text))
    || (stretched(word) && (squash(word) === squash(entry.text) || (entry.prefix && squash(word).startsWith(squash(entry.text)))));
  const hit = entry => same(whole, entry) || words.some(word => same(word, entry));
  // anywhere in the name, with a letter drawn out three times or more read
  // as two and as one ("booooobs"; "Bobbby" is not "boob").
  const drawnOut = [whole, whole.replace(/(.)\1{2,}/g, "$1$1"), whole.replace(/(.)\1{2,}/g, "$1")];
  const inside = entry => (entry.word ? hit(entry) : drawnOut.some(form => form.includes(entry.text)));
  return read(RESERVED_FILE).some(hit) || read(SLURS_FILE).some(hit) || read(SEXUAL_FILE).some(inside) || denNames().includes(whole);
};

module.exports = {refused, plain};
