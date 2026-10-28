"use strict";

// typed chat made fit to read before anyone sees it (lib/world.js, pubMsg):
// not a filter of what is said (that is lib/chatfilter.js) but of how much
// of it there is. a key held down ("aaaaaaaaaa..."), a word said over and
// over, one long run of letters with no space, a line all in capitals, a
// wall of emoji: each is cut down, and the line still goes. the same line
// said again and again in a short while does not.

const MAX_RUN = 5; // the same character this many times at most ("nooooo")
const MAX_REPEAT = 4; // the same word or emoji this many times in a row
const MAX_WORD = 32; // letters with no space between
const MAX_EMOJI = 12; // emoji in a line ("\{1f600}", as the client sends them)
const SHOUT_LENGTH = 12; // a line this long or more ...
const SHOUT_SHARE = 0.7; // ... with this share of its letters capitals is lowered
const REPEAT_LINES = 3; // the last few lines a player said ...
const REPEAT_MS = 20000; // ... within this long: one of those again is not sent

const EMOJI = /\\\{[0-9a-f]{2,6}(?:-[0-9a-f]{2,6}){0,9}\}/g;

// the line made tidy. emoji tags count as one character each here.
const tidy = text => {
  // every emoji as one character for now (a private-use one), so that the
  // rules below see it as one: put back at the end
  const emoji = [];
  let line = String(text).replace(EMOJI, tag => {
    emoji.push(tag);
    return String.fromCharCode(0xE000);
  });
  // a character held down (not a digit: "1000000" is a number)
  line = line.replace(new RegExp(`(.)\\1{${MAX_RUN},}`, "gu"), (run, char) => (/\d/.test(char) ? run : char.repeat(MAX_RUN)));
  // one long run with no space
  line = line.split(" ").map(word => (word.length > MAX_WORD ? word.slice(0, MAX_WORD) : word)).join(" ");
  // the same word (or emoji) over and over: in a row, with or without spaces
  line = line.replace(new RegExp(`((?:\\S+?)\\s*)\\1{${MAX_REPEAT},}`, "giu"), (run, once) => (/\d/.test(once) ? run : once.repeat(MAX_REPEAT)));
  // shouting
  const letters = line.replace(/[^A-Za-z]/g, "");
  if (letters.length >= SHOUT_LENGTH && letters.replace(/[^A-Z]/g, "").length / letters.length >= SHOUT_SHARE) {
    line = line.toLowerCase();
  }
  // the emoji back, no more than MAX_EMOJI of them
  let kept = 0;
  let at = 0;
  line = line.replace(new RegExp(String.fromCharCode(0xE000), "g"), () => {
    const tag = emoji[at++];
    return kept++ < MAX_EMOJI ? tag : "";
  });
  return line.replace(/\s{2,}/g, " ").trim();
};

// was this line said by them just now (one of their last few, a short while
// ago)? kept on the session, as recentChat is.
const repeated = (session, line) => {
  const now = Date.now();
  const said = (session.saidLately || []).filter(entry => now - entry.at < REPEAT_MS);
  const again = said.some(entry => entry.line.toLowerCase() === line.toLowerCase());
  session.saidLately = [...said, {line, at: now}].slice(-REPEAT_LINES);
  return again;
};

module.exports = {tidy, repeated};
