"use strict";

// pictures made room art: each PNG or JPEG goes into a SWF of its own (one
// bitmap, its top left where it is drawn), which the client's room loader
// takes as it takes the game's own art (Loader.loadBytes). and the walkable
// grid as the client reads it (RoomGrid.setGrid): runs of one value, each a
// big-endian short of the value (2 bits) and the run's length (14). used by
// tools/import-xroomgl.js and the room editor (lib/customrooms.js).

class Bits {
  constructor() {
    this.bytes = [];
    this.acc = 0;
    this.n = 0;
  }
  put(value, count) {
    for (let i = count - 1; i >= 0; i--) {
      this.acc = (this.acc << 1) | ((value >>> i) & 1);
      if (++this.n === 8) {
        this.bytes.push(this.acc & 0xff);
        this.acc = 0;
        this.n = 0;
      }
    }
  }
  signed(value, count) {
    this.put(value < 0 ? (value + 2 ** count) >>> 0 : value, count);
  }
  flush() {
    if (this.n) {
      this.put(0, 8 - this.n);
    }
    return Buffer.from(this.bytes);
  }
}
// the bits a signed number takes
const sbits = (...values) => Math.max(1, ...values.map(value => (value < 0 ? ~value : value).toString(2).length + 1));

const rect = (bits, x0, x1, y0, y1) => {
  const n = sbits(x0, x1, y0, y1);
  bits.put(n, 5);
  for (const value of [x0, x1, y0, y1]) {
    bits.signed(value, n);
  }
};
// scale (16.16 fixed) and translation (twips)
const matrix = (bits, scale, tx, ty, scaleY = scale) => {
  if (scale !== null) {
    const fixed = Math.round(scale * 65536);
    const fixedY = Math.round(scaleY * 65536);
    const n = sbits(fixed, fixedY);
    bits.put(1, 1);
    bits.put(n, 5);
    bits.signed(fixed, n);
    bits.signed(fixedY, n);
  }
  else {
    bits.put(0, 1);
  }
  bits.put(0, 1); // no rotation
  const n = sbits(tx, ty);
  bits.put(n, 5);
  bits.signed(tx, n);
  bits.signed(ty, n);
};

const tag = (code, body) => {
  const head = Buffer.alloc(6);
  head.writeUInt16LE((code << 6) | 0x3f, 0);
  head.writeUInt32LE(body.length, 2);
  return Buffer.concat([head, body]);
};

// `image` (PNG or JPEG bytes, w x h pixels) with its top left at (ox, oy),
// drawn `dw` x `dh` (stretched, when that is not its own size)
const pictureSwf = (image, w, h, ox, oy, dw = w, dh = h) => {
  const TW = 20;
  const x0 = Math.round(ox * TW);
  const y0 = Math.round(oy * TW);
  const x1 = x0 + Math.round(dw * TW);
  const y1 = y0 + Math.round(dh * TW);
  // FileAttributes: ActionScript 3, so the Loader's content is a MovieClip
  const attributes = tag(69, Buffer.from([0x08, 0, 0, 0]));
  // DefineBitsJPEG2 takes PNG too (SWF 8 on)
  const bitmap = tag(21, Buffer.concat([Buffer.from([1, 0]), image]));
  // DefineShape: a rectangle filled with the bitmap, clipped and smoothed
  const shape = new Bits();
  rect(shape, x0, x1, y0, y1);
  const shapeHead = shape.flush();
  const fill = new Bits();
  fill.put(1, 8); // one fill style
  fill.put(0x41, 8);
  fill.put(1, 8); // bitmap 1 (little-endian u16)
  fill.put(0, 8);
  matrix(fill, TW * dw / w, x0, y0, TW * dh / h);
  const fillBytes = fill.flush();
  const records = new Bits();
  records.put(0, 8); // no line styles
  records.put(1, 4); // fill bits
  records.put(0, 4); // line bits
  // move to the top left, fill on the right of the edges (clockwise)
  records.put(0, 1);
  records.put(0b00101, 5); // StateFillStyle1, StateMoveTo
  const n = sbits(x0, y0);
  records.put(n, 5);
  records.signed(x0, n);
  records.signed(y0, n);
  records.put(1, 1); // fill style 1
  // an edge's length takes 17 bits at most (3,276 pixels): longer ones in parts
  const edge = (dx, dy) => {
    const MAX = 60000;
    if (Math.abs(dx) > MAX || Math.abs(dy) > MAX) {
      edge(Math.trunc(dx / 2), Math.trunc(dy / 2));
      edge(dx - Math.trunc(dx / 2), dy - Math.trunc(dy / 2));
      return;
    }
    const m = sbits(dx, dy);
    records.put(1, 1); // edge
    records.put(1, 1); // straight
    records.put(m - 2, 4);
    records.put(0, 1); // not a general line
    records.put(dx === 0 ? 1 : 0, 1); // vertical?
    records.signed(dx === 0 ? dy : dx, m);
  };
  edge(x1 - x0, 0);
  edge(0, y1 - y0);
  edge(x0 - x1, 0);
  edge(0, y0 - y1);
  records.put(0, 6); // end
  const defineShape = tag(2, Buffer.concat([Buffer.from([2, 0]), shapeHead, fillBytes, records.flush()]));
  // PlaceObject2: shape 2 at depth 1, where it is drawn
  const place = new Bits();
  place.put(0x06, 8);
  place.put(1, 8);
  place.put(0, 8);
  place.put(2, 8);
  place.put(0, 8);
  matrix(place, null, 0, 0);
  const placeObject = tag(26, place.flush());
  const showFrame = Buffer.from([0x40, 0x00]);
  const end = Buffer.from([0, 0]);
  const frame = new Bits();
  rect(frame, Math.min(0, x0), Math.max(1, x1), Math.min(0, y0), Math.max(1, y1));
  const body = Buffer.concat([frame.flush(), Buffer.from([0, 24, 1, 0]), attributes, bitmap, defineShape, placeObject, showFrame, end]);
  const head = Buffer.alloc(8);
  head.write("FWS", 0, "latin1");
  head[3] = 10;
  head.writeUInt32LE(8 + body.length, 4);
  return Buffer.concat([head, body]);
};

const sizeOf = bytes => {
  if (bytes.toString("latin1", 1, 4) === "PNG") {
    return [bytes.readUInt32BE(16), bytes.readUInt32BE(20)];
  }
  if (bytes[0] === 0xff && bytes[1] === 0xd8) {
    for (let i = 2; i < bytes.length - 9;) {
      if (bytes[i] !== 0xff) {
        i++;
        continue;
      }
      const marker = bytes[i + 1];
      if (marker >= 0xc0 && marker <= 0xc3) {
        return [bytes.readUInt16BE(i + 7), bytes.readUInt16BE(i + 5)];
      }
      i += 2 + bytes.readUInt16BE(i + 2);
    }
  }
  return null;
};

const packGrid = cells => {
  const out = [];
  for (let i = 0; i < cells.length;) {
    const value = cells[i] & 3;
    let run = 1;
    while (i + run < cells.length && (cells[i + run] & 3) === value && run < 0x3fff) {
      run++;
    }
    const short = Buffer.alloc(2);
    short.writeUInt16BE((value << 14) | run);
    out.push(short);
    i += run;
  }
  return Buffer.concat(out);
};

module.exports = {pictureSwf, sizeOf, packGrid};
