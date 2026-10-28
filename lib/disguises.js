"use strict";

const accounts = require("./accounts.js");
const defpacks = require("./defpacks.js");

// playing as one of the game's characters ("!become liza").
//
// the alphas were animals players could not be: in 2013 they were animal
// types of their own (2, 3, 9 to 12, since given to the eagle, deer, hyena,
// otter, polar bear and owl), and that artwork is gone. what is left of
// them is in the NPC table (defPack 1025): the clips the adventures put on
// the map, each a drawing that can stand, face left or right, talk, cast
// and so on, but not walk.
//
// the client has one way to draw a player as something from that table:
// the Phantomizer den item, which swaps a player's animal for NPC 2, a
// phantom, that then follows it about (DenXtCommManager.denPhantomResponse,
// "dph": [ok, sfsUserId, on]). the patched client takes the NPC's id from
// one more field of that message (XtReplyDemuxer, avatar.NPCView in
// swf-src/). so a disguise is a "dph" that follows a player's animal
// wherever the client is told of the animal.
//
// what does not work, by the nature of it: the clip glides, as it has no
// walk; the animal under it still does everything, unseen (sit, dance,
// clothes); and a client keeps the first disguise it drew for an animal
// until that animal is drawn afresh, so changing from one to another shows
// when the player next changes rooms.

const NPC_PHANTOM = 2; // what the client draws when no id is given
const TYPE_CLIP = "0";
const TYPE_ANIMAL = "1"; // an ordinary animal in an outfit: the villagers of the adventures

// the names "!become" takes, with the NPC each is: the alphas and the
// phantom, nothing else. numbers are not taken: most of the NPC table is
// the adventures' set pieces and bosses, drawn at a size that fills the
// screen.
const NAMED = new Map([
  ["peck", 20], ["liza", 21], ["greely", 22], ["graham", 23], ["gilbert", 24], ["cosmo", 25], ["tavie", 219],
  ["phantom", NPC_PHANTOM],
]);
const ALLOWED = new Set(NAMED.values());

// is this NPC one a player can be drawn as? only those named above, and
// only with artwork. a disguise saved before the list was this short is
// ignored, so it falls away by itself.
const usable = id => {
  const def = ALLOWED.has(id) && defpacks.npcDef(id);
  return Boolean(def) && (def.type === TYPE_ANIMAL || (def.type === TYPE_CLIP && Number(def.mediaRefId) > 0));
};

// the NPC id for what a player typed (a name above), or null.
const find = text => {
  const id = NAMED.get(String(text).toLowerCase());
  return usable(id) ? id : null;
};

const of = account => (usable(account.disguise) ? account.disguise : 0);

// tells `to` how `subject` (a session whose animal `to` has just been told
// of, or has on screen) is disguised, if at all.
const show = (to, subject) => {
  const id = of(subject.account);
  if (id) {
    to.sendXt("dph", -1, 1, subject.id, 1, id);
  }
};

// puts a disguise on (an NPC id) or takes it off (0). the player's own
// client is told here; `redraw` puts their animal on everyone else's screen
// afresh, which brings the disguise with it (`show`).
const set = (session, id, redraw) => {
  session.account.disguise = id;
  accounts.save(session.account);
  session.sendXt("dph", -1, 1, session.id, id ? 1 : 0, id || NPC_PHANTOM);
  redraw(session);
};

module.exports = {find, of, show, set, names: () => [...NAMED.keys()]};
