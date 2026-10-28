"use strict";

const fs = require("fs");
const zlib = require("zlib");
const config = require("../config.js");

// the game's fonts for the browser version (public/play.html), as Ruffle's
// fontSources: a SWF whose fonts it takes for the computer's own.
//
// in Flash, the game's text is drawn in the fonts sharedFonts.swf embeds:
// the asset SWFs import them by their export names (CCDigitalDeliveryRegular,
// CCDigitalDeliveryBold, TikiIsland) and the game's own text asks for
// "CCDigitalDelivery". Ruffle finds none of them that way, looks for a font
// of that name on the computer instead, and draws its own. so this is
// sharedFonts.swf's fonts again, each under every name the game asks for:
// its own name and full name (DefineFontName) in its own weight, and its
// export name in both, as text set in bold asks for it too.

const TAG_END = 0;
const TAG_SHOW_FRAME = 1;
const TAG_DEFINE_FONT_3 = 75;
const TAG_SYMBOL_CLASS = 76;
const TAG_DEFINE_FONT_NAME = 88;
const FLAG_BOLD = 0x01;

const tags = body => {
  const list = [];
  const rectBytes = Math.ceil((5 + (body[0] >> 3) * 4) / 8);
  let at = rectBytes + 4; // frame size, rate and count
  while (at < body.length) {
    const head = body.readUInt16LE(at);
    at += 2;
    let length = head & 0x3f;
    if (length === 0x3f) {
      length = body.readUInt32LE(at);
      at += 4;
    }
    const code = head >> 6;
    list.push({code, data: body.subarray(at, at + length)});
    at += length;
    if (code === TAG_END) {
      break;
    }
  }
  return {header: body.subarray(0, rectBytes + 4), list};
};

const tag = (code, data) => {
  const head = Buffer.alloc(6);
  head.writeUInt16LE((code << 6) | 0x3f, 0);
  head.writeUInt32LE(data.length, 2);
  return Buffer.concat([head, data]);
};

const cString = (data, at) => {
  const end = data.indexOf(0, at);
  return data.toString("latin1", at, end < 0 ? data.length : end);
};

const build = () => {
  const file = fs.readFileSync(config.sharedFontsSwf);
  const signature = file.toString("latin1", 0, 3);
  const body = signature === "CWS" ? zlib.inflateSync(file.subarray(8)) : file.subarray(8);
  const {header, list} = tags(body);

  const fonts = new Map(); // id -> {data, bold, names: Map("name|bold" -> {name, bold})}
  const named = (font, name, bold) => name && font.names.set(`${name}|${bold}`, {name, bold});
  for (const {code, data} of list) {
    if (code === TAG_DEFINE_FONT_3) {
      const bold = (data[2] & FLAG_BOLD) !== 0;
      const font = {data, bold, names: new Map()};
      named(font, cString(data.subarray(5, 5 + data[4]), 0), bold);
      fonts.set(data.readUInt16LE(0), font);
    }
  }
  for (const {code, data} of list) {
    if (code === TAG_DEFINE_FONT_NAME && fonts.has(data.readUInt16LE(0))) {
      const font = fonts.get(data.readUInt16LE(0));
      named(font, cString(data, 2), font.bold);
    }
    if (code === TAG_SYMBOL_CLASS) {
      let at = 2;
      for (let i = data.readUInt16LE(0); i > 0; i--) {
        const id = data.readUInt16LE(at);
        const name = cString(data, at + 2);
        at += 2 + Buffer.byteLength(name, "latin1") + 1;
        if (fonts.has(id)) {
          named(fonts.get(id), name, false);
          named(fonts.get(id), name, true);
        }
      }
    }
  }

  // a DefineFont3 for each name: the same glyphs under a new id, name and weight
  const out = [];
  let nextId = 1;
  for (const font of fonts.values()) {
    const rest = font.data.subarray(5 + font.data[4]);
    for (const {name, bold} of font.names.values()) {
      const nameBytes = Buffer.from(`${name}\0`, "latin1");
      const head = Buffer.from([0, 0, bold ? font.data[2] | FLAG_BOLD : font.data[2] & ~FLAG_BOLD, font.data[3], nameBytes.length]);
      head.writeUInt16LE(nextId++, 0);
      out.push(tag(TAG_DEFINE_FONT_3, Buffer.concat([head, nameBytes, rest])));
    }
  }
  out.push(tag(TAG_SHOW_FRAME, Buffer.alloc(0)), tag(TAG_END, Buffer.alloc(0)));

  // a frame count of 1, in the original's header otherwise
  const frameHeader = Buffer.from(header);
  frameHeader.writeUInt16LE(1, frameHeader.length - 2);
  const swfBody = Buffer.concat([frameHeader, ...out]);
  const start = Buffer.alloc(8);
  start.write("CWS", 0, "latin1");
  start[3] = file[3];
  start.writeUInt32LE(8 + swfBody.length, 4);
  return Buffer.concat([start, zlib.deflateSync(swfBody)]);
};

let made = null;
// the font SWF, made once (sharedFonts.swf is not changed while the server runs)
const swf = () => {
  if (!made) {
    made = build();
  }
  return made;
};

module.exports = {swf};
