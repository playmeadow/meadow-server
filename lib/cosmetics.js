"use strict";

// cosmetics, bought with Earth Crystals (lib/crystals.js) on the /crystals
// page: what a player's animal looks like to everyone, made of what the
// game already has.
// - an outline round the animal, in one colour of the player's choosing or
//   cycling through the rainbow (a GlowFilter, as the game's own thin
//   outline is).
// - a soft glow round it in one of the two colours the game gives that
//   outline: earth (land rooms) and ocean.
// - a background behind the animal on their player card: one of the Jammer
//   Wall's wallpapers (lib/wall-art.json).
// one of each kind is worn at a time. the game is told with "xcs" [who,
// outline 0 none / 1 a colour / 2 rainbow, its colour, glow colour or -1]
// (swf-src/Cosmetics.as) for everyone in the room, and a player card asks
// for its background with "xcb" [username], answered [username, media].

const accounts = require("./accounts.js");
const crystals = require("./crystals.js");
const wallArt = require("./wall-art.json");

const OUTLINE_NONE = 0;
const OUTLINE_COLOUR = 1;
const OUTLINE_RAINBOW = 2;
const NO_GLOW = -1;
const DEFAULT_OUTLINE_COLOUR = 0x9D00FF;

// the wallpapers' own names, from their files' symbols (blueWave_WallPaper)
const WALLPAPER_NAMES = {
  3941: "Blue Wave",
  3942: "Crystal",
  3943: "Fancy Cloud",
  3944: "Lava",
  3945: "Lava Swirl",
  3946: "Pink Wave",
  3947: "Red Wave",
  3948: "Star Purple",
  3949: "Hot Rock",
  3959: "Groovy Bricks",
  3960: "Hexagon Stars",
  3991: "Blue Shapes",
  3992: "Candy Bubble",
  3993: "Celebrate",
  3994: "Fancy Space",
  3995: "Ice",
  3996: "Moon Circles",
  3997: "Phantom Web",
  3998: "Pink Map",
  3999: "Water Rainbow",
  4011: "White",
  4012: "Black",
  4013: "Purple",
  4014: "Cyan",
  4015: "Green",
  4016: "Yellow",
  4017: "Orange",
  4018: "Red Orange",
  4019: "Red",
  4020: "Pink",
  4021: "Violet",
  4023: "Cloud Pattern",
  4024: "Gray Seed",
  4025: "Green Blocks",
  4026: "Green Space",
  4027: "Groovy Green Shapes",
  4028: "Pink Crystal",
  4029: "Red Brick",
  4030: "Sun Flower Corn",
  4040: "Purple Diamond",
  6452: "Black White Circles",
  6453: "Blue Basket Weave",
  6454: "Green Hexagon",
  6455: "Pink Squares",
  6456: "Rainbow Hexagon",
  6457: "Rainbow Pixel",
  6458: "Rainbow Triangles",
  6459: "Steel",
};

const CATALOG = [
  {id: "outline", kind: "outline", name: "Outline", price: 200, text: "An outline round your animal, in any one colour you choose."},
  {id: "outline-rainbow", kind: "outline", name: "Rainbow Outline", price: 600, text: "An outline that cycles through every colour."},
  {id: "glow-earth", kind: "glow", name: "Earth Glow", price: 300, colour: 0x553E2F, text: "A soft glow in the earthy brown the game outlines land animals with."},
  {id: "glow-ocean", kind: "glow", name: "Ocean Glow", price: 300, colour: 0x2A5955, text: "A soft glow in the deep teal the game outlines sea animals with."},
  ...wallArt.wallpapers.map((wallpaper, at) => ({id: `card-${wallpaper.media}`, kind: "card", name: WALLPAPER_NAMES[wallpaper.media] || `Wallpaper ${at + 1}`, price: 100,
    media: wallpaper.media, picture: `/cosmetics/cards/${wallpaper.media}.png`, text: "Behind your animal on your player card: a Jammer Wall wallpaper."})),
];
const byId = new Map(CATALOG.map(item => [item.id, item]));
const KINDS = ["outline", "glow", "card"];

module.exports = ({watchers, findOnline}) => {
  // what an account owns and wears: {owned: [id], outline, colour, glow, card}
  const stateOf = account => {
    if (!account.cosmetics || typeof account.cosmetics !== "object") {
      account.cosmetics = {owned: [], outline: null, colour: DEFAULT_OUTLINE_COLOUR, glow: null, card: null};
    }
    return account.cosmetics;
  };

  // the "xcs" fields for a session's animal
  const look = account => {
    const state = stateOf(account);
    const outline = byId.get(state.outline);
    const glow = byId.get(state.glow);
    return [!outline ? OUTLINE_NONE : outline.id === "outline-rainbow" ? OUTLINE_RAINBOW : OUTLINE_COLOUR, state.colour, glow ? glow.colour : NO_GLOW];
  };
  const wearsAnything = account => {
    const state = stateOf(account);
    return Boolean(state.outline || state.glow);
  };

  // for a player who has just been shown `target`'s animal (lib/world.js,
  // after "ac"); `to` may be the player themselves.
  const show = (to, target) => {
    if (target.account && wearsAnything(target.account)) {
      to.sendXt("xcs", -1, target.id, ...look(target.account));
    }
  };

  // a change: everyone who sees the animal, and its player
  const changed = account => {
    const session = findOnline(account.username);
    if (!session || !session.room) {
      return;
    }
    for (const other of [session, ...watchers(session)]) {
      other.sendXt("xcs", -1, session.id, ...look(account));
    }
  };

  // what the /crystals page shows
  const shop = account => {
    const state = stateOf(account);
    return {
      balance: crystals.balance(account),
      catalog: CATALOG.map(({id, kind, name, price, text, colour, picture}) => ({id, kind, name, price, text, colour, picture})),
      owned: state.owned,
      wearing: {outline: state.outline, glow: state.glow, card: state.card},
      colour: state.colour,
    };
  };

  // {ok} or {error}
  const buy = (account, id) => {
    const item = byId.get(String(id));
    const state = stateOf(account);
    if (!item) {
      return {error: "There's no such cosmetic."};
    }
    if (state.owned.includes(item.id)) {
      return {error: "You have it already."};
    }
    if (crystals.balance(account) < item.price) {
      return {error: `It costs ${item.price.toLocaleString()} Earth Crystals; you have ${crystals.balance(account).toLocaleString()}.`};
    }
    state.owned.push(item.id);
    crystals.change(account, -item.price, "buy", {detail: item.name});
    return {ok: `You bought ${item.name}.`};
  };

  // wears an owned cosmetic of a kind, or none (id null); the outline's
  // colour comes with it. {ok} or {error}
  const wear = (account, kind, id, colour) => {
    const state = stateOf(account);
    if (!KINDS.includes(kind)) {
      return {error: "There's no such kind of cosmetic."};
    }
    if (id !== null) {
      const item = byId.get(String(id));
      if (!item || item.kind !== kind || !state.owned.includes(item.id)) {
        return {error: "You don't have that."};
      }
    }
    if (colour !== undefined) {
      if (!/^#?[0-9a-f]{6}$/i.test(String(colour))) {
        return {error: "A colour is six hex digits, like #9D00FF."};
      }
      state.colour = parseInt(String(colour).replace("#", ""), 16);
    }
    state[kind] = id === null ? null : String(id);
    accounts.save(account);
    changed(account);
    return {ok: true};
  };

  // a player card's background: the media of the wallpaper worn, or 0
  const cardOf = account => {
    const item = account ? byId.get(stateOf(account).card) : null;
    return item ? item.media : 0;
  };

  const handlers = {
    // "xcb" [username]: the player card asks for its background
    xcb(session, roomId, [username]) {
      const account = accounts.byName(String(username || ""));
      session.sendXt("xcb", -1, String(username || ""), cardOf(account));
    },
  };

  return {CATALOG, handlers, show, shop, buy, wear, cardOf};
};

Object.assign(module.exports, {CATALOG});
