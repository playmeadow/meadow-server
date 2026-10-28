"use strict";

const {logText} = require("./logtext.js");
const fs = require("fs");
const path = require("path");

// the server's own filter for what players write to each other: typed chat,
// Jam-a-Gram messages, Jammer Wall posts and bios. unlike the chat filter in
// the client (the player's to set, or turn off), this one cannot be turned off,
// and what it catches reaches nobody. it is meant to be narrow: slurs, and
// sexual talk aimed at someone, never swearing as such ("fuck" is fine,
// "i'll fuck you in the ass" is not). the rules are lib/chat-filter.txt,
// read again when it changes; the file says how they are written.

const RULES_FILE = path.join(__dirname, "chat-filter.txt");
// for "a .. b": how many words may come between the two ("a + b": none)
const MAX_GAP = 4;
// letters written as digits or signs, as the client's filter reads them
// (AJClient.filterText), plus "@" and "$".
const STAND_INS = {0: "o", 1: "i", 3: "e", 4: "a", 5: "s", 7: "t", "@": "a", $: "s"};

// A letter drawn out three times or more ("fuuuck") is read as the word
// with every run of letters made one, and compared that way: a word written
// plainly is compared as it is ("ass" is not "as").
const squash = word => word.replace(/(.)\1+/g, "$1");
const stretched = word => /(.)\1\1/.test(word);

// the words of a message as compared: small letters, apostrophes dropped
// ("i'll" is "ill"), stand-ins read as the letters they are, split at
// anything else. a word that is only digits is a number and goes. three or
// more single letters in a row ("f u c k", "f.u.c.k") are read as one word.
const wordsOf = text => {
  const words = String(text).toLowerCase().replace(/['\u2019`]/g, "")
    .split(/[^a-z0-9@$]+/).filter(word => word && !/^\d+$/.test(word))
    .map(word => word.replace(/[0-9@$]/g, sign => STAND_INS[sign] || "")).filter(Boolean);
  const joined = [];
  for (let i = 0; i < words.length;) {
    let end = i;
    while (end < words.length && words[end].length === 1) {
      end++;
    }
    if (end - i >= 3) {
      joined.push(words.slice(i, end).join(""));
      i = end;
    }
    else {
      joined.push(words[i]);
      i++;
    }
  }
  return joined;
};

// one word of a rule: {text, start, inside, any}. "word" is that word,
// "word*" any word starting with it, "*word*" any word with it anywhere
// inside, "?" any word at all.
const patternOf = token => {
  if (token === "?") {
    return {any: true};
  }
  const inside = token.length > 2 && token.startsWith("*") && token.endsWith("*");
  const start = !inside && token.endsWith("*");
  const text = token.replace(/^\*|\*$/g, "").toLowerCase().replace(/[0-9@$]/g, sign => STAND_INS[sign] || "").replace(/[^a-z]/g, "");
  return text ? {text, start, inside} : null;
};

const fits = (word, pattern) => {
  if (pattern.any) {
    return true;
  }
  const forms = stretched(word) ? [word, squash(word)] : [word];
  const wanted = form => (form === word ? pattern.text : squash(pattern.text));
  return forms.some(form => (pattern.inside ? form.includes(wanted(form))
    : pattern.start ? form.startsWith(wanted(form)) : form === wanted(form)));
};

// A rule: clauses joined by " & ", all of which must be found in the
// message; a clause: slots in order, joined by " + " (the next word) or
// " .. " (at most MAX_GAP words later), each slot {choices, gap}, its gap
// being how far after the one before it may start; a slot's choices are
// joined by "|", and a choice is one word, or words that follow each other.
// a choice written "!word" is one the slot must not be: "?|!it" is any word
// but "it". A slot of only those takes up no word: "a + !up" is "a", not
// followed by "up" (or at the end of the message).
const parse = line => line.split(/\s+&\s+/).map(clause => {
  const parts = clause.split(/\s+(\.\.|\+)\s+/);
  const slots = [];
  for (let i = 0; i < parts.length; i += 2) {
    const written = parts[i].split("|").map(choice => choice.trim());
    const wordsIn = list => list.map(choice => choice.split(/\s+/).map(patternOf)).filter(choice => choice.length > 0 && choice.every(Boolean));
    const choices = wordsIn(written.filter(choice => !choice.startsWith("!")));
    const not = wordsIn(written.filter(choice => choice.startsWith("!")).map(choice => choice.slice(1)));
    slots.push({choices, not, gap: parts[i - 1] === "+" ? 0 : MAX_GAP});
  }
  return slots;
});

// where in `words` a slot's choice starts at `at`: the index after it, or -1.
const startsWith = (words, at, choice) => at + choice.length <= words.length && choice.every((pattern, i) => fits(words[at + i], pattern));
const slotAt = (words, at, slot) => {
  if (slot.not.some(choice => startsWith(words, at, choice))) {
    return -1;
  }
  for (const choice of slot.choices) {
    if (startsWith(words, at, choice)) {
      return at + choice.length;
    }
  }
  return -1;
};

const clauseFrom = (words, slots, from, to) => {
  if (slots.length === 0) {
    return true;
  }
  if (slots[0].choices.length === 0) {
    return !slots[0].not.some(choice => startsWith(words, from, choice)) && clauseFrom(words, slots.slice(1), from, from + (slots.length > 1 ? slots[1].gap : 0));
  }
  for (let at = from; at <= Math.min(to, words.length - 1); at++) {
    const end = slotAt(words, at, slots[0]);
    if (end !== -1 && clauseFrom(words, slots.slice(1), end, end + (slots.length > 1 ? slots[1].gap : 0))) {
      return true;
    }
  }
  return false;
};

let kept = {mtime: -1, rules: []};
const rules = () => {
  let mtime = 0;
  try {
    mtime = fs.statSync(RULES_FILE).mtimeMs;
  }
  catch (err) {
    return [];
  }
  if (kept.mtime !== mtime) {
    const lines = fs.readFileSync(RULES_FILE, "utf8").split(/\r?\n/).map(line => line.trim()).filter(line => line && !line.startsWith("#"));
    const parsed = [];
    for (const line of lines) {
      const clauses = parse(line);
      if (clauses.every(clause => clause.length > 0 && clause.every(slot => slot.choices.length > 0 || slot.not.length > 0) && clause[0].choices.length > 0)) {
        parsed.push({line, clauses});
      }
      else {
        console.log(`[filter] lib/chat-filter.txt: a rule that could not be read was left out: ${logText(line)}`);
      }
    }
    kept = {mtime, rules: parsed};
    console.log(`[filter] ${logText(parsed.length)} rules`);
  }
  return kept.rules;
};

// the rule a message breaks (its line in the file), or null.
const broken = text => {
  const words = wordsOf(text);
  if (words.length === 0) {
    return null;
  }
  const rule = rules().find(candidate => candidate.clauses.every(clause => clauseFrom(words, clause, 0, words.length - 1)));
  return rule ? rule.line : null;
};

// the game's own warning screen, over the game, for ten seconds
// (FacilitatorXtCommManager, "fw" of facilitatorDisciplineResponse). its
// kind picks the picture and the words: 3 "Personal Information", 5
// "Bullying", 11 "Scamming", 0 a short "Inappropriate Chat", and this one
// "Inappropriate Behavior" with the game's own text ("It looks like the
// conversation you're having isn't appropriate..."). it also lets go of
// the sender's chat bubble that waits for the line.
const WARNING_BEHAVIOR = 4;
const warn = session => session.sendXt("fd", -1, "fw", WARNING_BEHAVIOR);

module.exports = {broken, warn, wordsOf};
