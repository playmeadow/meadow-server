"use strict";

const crypto = require("crypto");
const accounts = require("./accounts.js");

// moderators' notes on a player: what staff want one another to know about
// them ("talked to them about trading, seemed fine"), on the player's page
// of the moderator panel and with "!notes" in the game. the player is never
// shown them (lib/manage.js leaves them out of their data).
//
// on an account: modNotes [{id, at, by, text}], the oldest first.

const MAX_NOTES = 100;
const MAX_TEXT = 500;

const now = () => Math.floor(Date.now() / 1000);

const list = account => [...(account.modNotes || [])].reverse();

// returns {note} or {error}.
const add = (account, by, text) => {
  const clean = String(text || "").replace(/\s+/g, " ").trim().slice(0, MAX_TEXT);
  if (!clean) {
    return {error: "Write the note first."};
  }
  const note = {id: crypto.randomBytes(6).toString("hex"), at: now(), by: String(by), text: clean};
  account.modNotes = [...(account.modNotes || []), note].slice(-MAX_NOTES);
  accounts.save();
  return {note};
};

// a note taken away by whoever wrote it, or by someone who may remove anyone's
// (`anyone`). returns {note} or {error}.
const remove = (account, id, by, anyone) => {
  const note = (account.modNotes || []).find(entry => entry.id === String(id));
  if (!note) {
    return {error: "No such note."};
  }
  if (!anyone && note.by.toLowerCase() !== String(by).toLowerCase()) {
    return {error: "Only whoever wrote a note, or an admin, can remove it."};
  }
  account.modNotes = account.modNotes.filter(entry => entry !== note);
  accounts.save();
  return {note};
};

// the newest notes on anybody, with whom they are about.
const recent = count => accounts.all()
  .flatMap(account => (account.modNotes || []).map(note => ({...note, about: account.username})))
  .sort((one, other) => other.at - one.at)
  .slice(0, count);

module.exports = {list, add, remove, recent, MAX_TEXT};
