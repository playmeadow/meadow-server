#!/usr/bin/env node
"use strict";

// builds the rooms of lib/extra-rooms.json (lib/extrarooms.js) from the HTML5
// client's room files: the rooms that are in no build of the Flash client,
// and the older versions of rooms it still has.
//
//   node tools/import-xroomgl.js SOURCE [OUT]
//
// SOURCE is a folder of .xroomgl files laid out as the CDN's roomDefs
// (SOURCE/appondale/room_main_lucky.xroomgl); OUT, extra-rooms/ by default
// (config.extraRoomsDir), gets <pathName>.xroom for each room listed.
//
// an .xroomgl is [u32 big-endian n][n bytes of JSON][the assets, back to
// back]. its JSON is the .xroom's actors under other names (layers for
// ActorLayer and so on), and its assets are pictures: the HTML5 client's
// PNG or JPEG of each of the Flash room's SWFs, at the size of the SWF's own
// units. the Flash client loads an asset's bytes and puts what it gets at
// the layer's x and y, but a SWF's artwork seldom starts at its origin; the
// layer's left and top say where it does in the room. so each picture goes
// into a SWF of its own (one bitmap, placed where the artwork was), and the
// room loads that as it loaded the original. what the original did beside
// showing itself (animation, named parts the game looks for) is not in a
// picture, and is not there.
//
// the walkable grid is a plain array in an .xroomgl; the Flash client reads
// it packed (RoomGrid.setGrid): runs of one value, each a big-endian short
// of the value (2 bits) and the run's length (14).

const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const amf3 = require("../lib/amf3.js");
const {pictureSwf, sizeOf, packGrid} = require("../lib/roomswf.js");
const {rooms} = require("../lib/extra-rooms.json");

const ACTORS = {layers: "ActorLayer", spawn: "ActorSpawn", setting: "ActorSettings", portal: "ActorPortal",
  action: "ActorAction", volume: "ActorVolume", collisionPoint: "ActorCollisionPoint"};

// where an asset's artwork starts in its own units: from a layer of it,
// unflipped where there is one. a flipped layer is drawn mirrored about
// its right (or bottom) edge (RoomManagerBase.setLayerMatrix).
const originOf = (layers, w, h) => {
  const layer = layers.find(one => !one.flip) || layers[0];
  const sx = Math.abs(Number(layer.scaleX) || 1);
  const sy = Math.abs(Number(layer.scaleY) || 1);
  const ox = layer.flip & 1 ? (Number(layer.x) + Number(layer.width) - Number(layer.left)) / sx - w : (Number(layer.left) - Number(layer.x)) / sx;
  const oy = layer.flip & 2 ? (Number(layer.y) + Number(layer.height) - Number(layer.top)) / sy - h : (Number(layer.top) - Number(layer.y)) / sy;
  return [Number.isFinite(ox) ? ox : 0, Number.isFinite(oy) ? oy : 0];
};

const convert = buf => {
  const n = buf.readUInt32BE(0);
  const header = JSON.parse(buf.toString("utf8", 4, 4 + n));
  const layersOf = new Map();
  for (const layer of header.layers || []) {
    const key = String(layer.assetName).toLowerCase();
    layersOf.set(key, [...(layersOf.get(key) || []), layer]);
  }
  const now = new Date();
  const assets = [];
  let at = 4 + n;
  let pictures = 0;
  for (const asset of header.assets || []) {
    const bytes = buf.subarray(at, at + asset.len);
    at += asset.len;
    const size = sizeOf(bytes);
    const layers = layersOf.get(String(asset.name).toLowerCase());
    let ba = Buffer.from(bytes);
    if (size && layers) {
      ba = pictureSwf(bytes, size[0], size[1], ...originOf(layers, size[0], size[1]));
      pictures++;
    }
    assets.push({timeStamp: now, ba, name: asset.name});
  }
  if (at !== buf.length) {
    throw new Error(`${buf.length - at} bytes after the assets`);
  }
  const actors = {};
  for (const [key, actor] of Object.entries(ACTORS)) {
    actors[actor] = header[key] || [];
  }
  for (const setting of actors.ActorSettings) {
    // a room with no grid (the world map: never walked in) is walkable
    // everywhere it shows (a cell of 0 is open), in cells as the game's are
    // (24 pixels)
    if (!setting.grid) {
      const [x0, y0] = [Number(setting.xmin) || 0, Number(setting.ymin) || 0];
      const width = Math.ceil(((Number(setting.xmax) || 0) - x0 + 900) / 24);
      const height = Math.ceil(((Number(setting.ymax) || 0) - y0 + 550) / 24);
      setting.grid = {r2: 24, r: 12, width, height, min: {x: x0, y: y0}, max: {x: x0 + width * 24, y: y0 + height * 24},
        grid: new Array(width * height).fill(0)};
    }
    const grid = setting.grid;
    if (grid && Array.isArray(grid.grid)) {
      grid.packedGrid = packGrid(grid.grid);
      delete grid.grid;
    }
    delete setting.packedGrid;
  }
  return {room: {assets, actors}, pictures};
};

const main = () => {
  const [source, out = path.join(__dirname, "..", "extra-rooms")] = process.argv.slice(2);
  if (!source) {
    console.error("usage: node tools/import-xroomgl.js SOURCE [OUT]");
    process.exit(2);
  }
  let made = 0;
  for (const room of rooms) {
    const from = path.join(source, `${room.from}.xroomgl`);
    if (!fs.existsSync(from)) {
      console.log(`missing ${room.from}.xroomgl`);
      continue;
    }
    const {room: converted, pictures} = convert(fs.readFileSync(from));
    const file = path.join(out, `${room.pathName}.xroom`);
    fs.mkdirSync(path.dirname(file), {recursive: true});
    fs.writeFileSync(file, zlib.deflateSync(amf3.encode(converted)));
    console.log(`${room.pathName}: ${converted.assets.length} assets (${pictures} pictures), ${converted.actors.ActorLayer.length} layers`);
    made++;
  }
  console.log(`${made} of ${rooms.length} rooms built in ${out}`);
};

if (require.main === module) {
  main();
}

module.exports = {convert, pictureSwf, packGrid};
