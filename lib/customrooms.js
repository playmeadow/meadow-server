"use strict";

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const amf3 = require("./amf3.js");
const cdn = require("./cdn.js");
const config = require("../config.js");
const defpacks = require("./defpacks.js");
const roomInfo = require("./roominfo.js");
const {logText} = require("./logtext.js");
const {pictureSwf, sizeOf, packGrid} = require("./roomswf.js");

// rooms made in the admin panel's room editor (public/room-editor.html):
// pictures uploaded and placed, a walkable grid painted over them, spawn
// points and doors. each is saved as the editor's own description of it,
// data/custom-rooms/rooms/<slug>.json, and built into a room file the
// client loads as it loads the game's (data/custom-rooms/rooms/<slug>.xroom:
// zlib, then AMF3; each picture a SWF of its own, lib/roomswf.js). a room
// goes by "custom.<slug>": "!go custom.<slug>" takes a player there, and it
// is in the room list from the moment it is saved, with no restart.
//
// the client puts the room's people at the first background layer's x and
// y (RoomManagerBase: _mainBackObj), and every other layer is placed less
// that (convertToWorldSpace). the first layer is a picture of nothing at
// 0, 0, so that everything in the room is where the editor shows it.

const FOLDER = () => path.join(config.dataDir, "custom-rooms");
const ROOMS = () => path.join(FOLDER(), "rooms");
const PICTURES = () => path.join(FOLDER(), "pictures");
const roomFile = (slug, ext) => path.join(ROOMS(), `${slug}.${ext}`);

const FIRST_ID = 5000; // room def ids: the official ones end at 755, the extra rooms' at 962
const CELL = 24; // the grid's cells, as the game's rooms have them
const SCREEN = {w: 900, h: 550};
const MIN_SIZE = SCREEN;
const MAX_SIZE = {w: 8000, h: 6000};
const MAX_PICTURE_BYTES = 12 * 1024 * 1024;
const MAX_PICTURE_SIDE = 8000; // Flash's bitmaps: 8191 a side,
const MAX_PICTURE_PIXELS = 16000000; // 16,777,215 in all
const MAX_PICTURES = 80;
const MAX_SPAWNS = 20;
const MAX_DOORS = 40;
const MAX_NAME = 40;
const SLUG = /^[a-z0-9_]{1,40}$/;
const SPAWN_NAME = /^[A-Za-z0-9_]{1,30}$/;
const HASH = /^[0-9a-f]{24}$/;
// where a picture is drawn: behind everyone, among them (in front of whoever
// stands above its bottom edge), in front of everyone, and in front of that.
const DEPTHS = [0, 1, 2, 4];
const PICTURE_KEPT_MS = 24 * 3600 * 1000; // an upload no room uses yet

const rooms = new Map(); // slug -> the editor's description
let musicNames = null;

const basePath = slug => `custom.${slug}`;
const pathName = slug => `custom/${slug}`;
const clientPath = slug => cdn.hashedPath(`roomDefs/${pathName(slug)}.xroom`);
const pictureFile = hash => {
  for (const ext of ["png", "jpg"]) {
    const file = path.join(PICTURES(), `${hash}.${ext}`);
    if (fs.existsSync(file)) {
      return file;
    }
  }
  return null;
};
const readPicture = hash => {
  const file = HASH.test(String(hash)) ? pictureFile(hash) : null;
  return file ? {data: fs.readFileSync(file), type: file.endsWith(".png") ? "png" : "jpeg"} : null;
};

// ---- pictures

// an upload: {hash, width, height} or {error}
const addPicture = data => {
  if (!Buffer.isBuffer(data) || data.length < 16) {
    return {error: "That is not a picture."};
  }
  if (data.length > MAX_PICTURE_BYTES) {
    return {error: `That picture is too big: ${MAX_PICTURE_BYTES / 1024 / 1024} MB at most.`};
  }
  const png = data.toString("latin1", 0, 8) === "\x89PNG\r\n\x1a\n";
  const jpeg = data[0] === 0xff && data[1] === 0xd8;
  const size = (png || jpeg) && sizeOf(data);
  if (!size) {
    return {error: "Pictures are PNG or JPEG files."};
  }
  const [width, height] = size;
  if (width < 1 || height < 1 || width > MAX_PICTURE_SIDE || height > MAX_PICTURE_SIDE || width * height > MAX_PICTURE_PIXELS) {
    return {error: `That picture is ${width} by ${height}: the game draws ${MAX_PICTURE_SIDE} a side and 16 million pixels at most.`};
  }
  const hash = crypto.createHash("sha256").update(data).digest("hex").slice(0, 24);
  if (!pictureFile(hash)) {
    fs.mkdirSync(PICTURES(), {recursive: true, mode: 0o700});
    const file = path.join(PICTURES(), `${hash}.${png ? "png" : "jpg"}`);
    const waiting = `${file}.${process.pid}.part`;
    fs.writeFileSync(waiting, data, {mode: 0o600});
    fs.renameSync(waiting, file);
  }
  return {hash, width, height};
};

// a PNG of one colour, for a room's background colour
const crcTable = new Int32Array(256).map((_, n) => {
  let c = n;
  for (let k = 0; k < 8; k++) {
    c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  }
  return c;
});
const crc32 = bytes => {
  let c = -1;
  for (const byte of bytes) {
    c = crcTable[(c ^ byte) & 0xff] ^ (c >>> 8);
  }
  return (c ^ -1) >>> 0;
};
const chunk = (type, body) => {
  const head = Buffer.alloc(8);
  head.writeUInt32BE(body.length, 0);
  head.write(type, 4, "latin1");
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([head.subarray(4), body])));
  return Buffer.concat([head, body, crc]);
};
const solidPng = (width, height, rgb, alpha = 255) => {
  const header = Buffer.alloc(13);
  header.writeUInt32BE(width, 0);
  header.writeUInt32BE(height, 4);
  header[8] = 8; // bits per channel
  header[9] = 6; // RGBA
  const row = Buffer.alloc(1 + width * 4);
  for (let x = 0; x < width; x++) {
    row[1 + x * 4] = (rgb >> 16) & 0xff;
    row[2 + x * 4] = (rgb >> 8) & 0xff;
    row[3 + x * 4] = rgb & 0xff;
    row[4 + x * 4] = alpha;
  }
  const raw = Buffer.concat(new Array(height).fill(row));
  return Buffer.concat([Buffer.from("\x89PNG\r\n\x1a\n", "latin1"), chunk("IHDR", header),
    chunk("IDAT", zlib.deflateSync(raw, {level: 9})), chunk("IEND", Buffer.alloc(0))]);
};

// ---- a room checked, and built

const number = (value, min, max) => {
  const n = Math.round(Number(value));
  return Number.isFinite(n) && n >= min && n <= max ? n : null;
};

// what the editor sent made a room's description: {room} or {error}.
// `old` is the room it changes, if it is one already.
const check = (body, old) => {
  const slug = old ? old.slug : String(body.slug || "").trim().toLowerCase();
  if (!SLUG.test(slug)) {
    return {error: "The room's path is letters, numbers and _ (40 at most)."};
  }
  const name = String(body.name || "").trim();
  if (!name || name.length > MAX_NAME || /[%<>]/.test(name)) {
    return {error: `Give the room a name (${MAX_NAME} characters at most, no % < >).`};
  }
  const width = number(body.width, MIN_SIZE.w, MAX_SIZE.w);
  const height = number(body.height, MIN_SIZE.h, MAX_SIZE.h);
  if (width === null || height === null) {
    return {error: `A room is ${MIN_SIZE.w} to ${MAX_SIZE.w} wide and ${MIN_SIZE.h} to ${MAX_SIZE.h} high.`};
  }
  const background = /^#[0-9a-f]{6}$/i.test(body.background || "") ? body.background.toLowerCase() : null;
  const music = String(body.music || "").trim();
  if (music && !/^[A-Za-z0-9_ -]{1,60}\.mp3$/.test(music)) {
    return {error: "Music is the name of one of the game's tracks, like ajMusDiamondRoom.mp3."};
  }
  const pictures = Array.isArray(body.pictures) ? body.pictures : [];
  if (pictures.length > MAX_PICTURES) {
    return {error: `${MAX_PICTURES} pictures at most.`};
  }
  const placed = [];
  for (const picture of pictures) {
    const file = HASH.test(String(picture.hash)) && pictureFile(picture.hash);
    const size = file && sizeOf(fs.readFileSync(file));
    const x = number(picture.x, -MAX_SIZE.w, MAX_SIZE.w * 2);
    const y = number(picture.y, -MAX_SIZE.h, MAX_SIZE.h * 2);
    if (!size || x === null || y === null || !DEPTHS.includes(Number(picture.depth))) {
      return {error: "One of the pictures is not there any more: upload it again."};
    }
    placed.push({hash: picture.hash, x, y, depth: Number(picture.depth), w: size[0], h: size[1]});
  }
  if (!placed.length && !background) {
    return {error: "A room needs a picture or a background colour."};
  }
  const spawns = (Array.isArray(body.spawns) ? body.spawns : []).map(spawn => ({name: String(spawn.name || "").trim(),
    x: number(spawn.x, 0, width), y: number(spawn.y, 0, height)}));
  if (!spawns.length || spawns.length > MAX_SPAWNS) {
    return {error: `A room has 1 to ${MAX_SPAWNS} spawn points: where players appear.`};
  }
  const spawnNames = new Set();
  for (const spawn of spawns) {
    if (!SPAWN_NAME.test(spawn.name) || spawnNames.has(spawn.name) || spawn.x === null || spawn.y === null) {
      return {error: "Each spawn point has a name of its own (letters, numbers and _) and is inside the room."};
    }
    spawnNames.add(spawn.name);
  }
  const doors = (Array.isArray(body.doors) ? body.doors : []).map(door => ({x: number(door.x, 0, width), y: number(door.y, 0, height),
    r: number(door.r, 10, 400), room: String(door.room || "").trim(), spawn: String(door.spawn || "").trim()}));
  if (doors.length > MAX_DOORS) {
    return {error: `${MAX_DOORS} doors at most.`};
  }
  for (const door of doors) {
    if (door.x === null || door.y === null || door.r === null) {
      return {error: "Each door is inside the room, 10 to 400 across."};
    }
    const target = door.room === basePath(slug) || defpacks.roomDef(door.room);
    if (!door.room || !target || door.room.startsWith("den") || /^player_den\./.test(door.room)) {
      return {error: `A door goes to a room there is: "${door.room}" is not one.`};
    }
    if (door.spawn && !SPAWN_NAME.test(door.spawn)) {
      return {error: "A door's spawn point is the name of one in the room it goes to, or nothing."};
    }
  }
  const cols = Math.ceil(width / CELL);
  const rows = Math.ceil(height / CELL);
  const grid = String(body.grid || "");
  if (grid.length !== cols * rows || /[^0-3]/.test(grid)) {
    return {error: "The walkable area does not fit the room: draw it again."};
  }
  return {room: {slug, name, width, height, background, music, ocean: body.ocean === true, open: body.open !== false,
    pictures: placed, spawns, doors, grid, id: old ? old.id : null}};
};

const layer = (assetName, depth, x, y, w, h) => ({assetName, layer: depth, x, y, left: x, top: y, width: w, height: h,
  scaleX: 1, scaleY: 1, rot: 0, flip: 0, scrollX: 1, scrollY: 1, typeIndex: 0, delaySecs: 0, offsetSecs: 0, name: "", refId: 0, refObjName: ""});

// the room file of a room's description
const build = room => {
  const now = new Date();
  const assets = [];
  const asset = (name, ba) => assets.push({timeStamp: now, ba, name});
  asset("custom\\origin.swf", pictureSwf(solidPng(1, 1, 0, 0), 1, 1, 0, 0));
  const layers = [layer("custom\\origin.swf", 0, 0, 0, 1, 1)];
  if (room.background) {
    // a small picture, stretched by the SWF to the whole room
    asset("custom\\background.swf", pictureSwf(solidPng(8, 8, parseInt(room.background.slice(1), 16)), 8, 8, 0, 0, room.width, room.height));
    layers.push(layer("custom\\background.swf", 0, 0, 0, room.width, room.height));
  }
  const added = new Set();
  // drawn in the order they are listed: each depth's own after the one before
  for (const picture of room.pictures) {
    const name = `custom\\${picture.hash}.swf`;
    if (!added.has(name)) {
      added.add(name);
      asset(name, pictureSwf(fs.readFileSync(pictureFile(picture.hash)), picture.w, picture.h, 0, 0));
    }
    layers.push(layer(name, picture.depth, picture.x, picture.y, picture.w, picture.h));
  }
  // the editor says where one may go (1 walking, 2 flying, 3 both); the
  // game's grid says where one may not (RoomGrid: a cell is open when it is
  // 0, and for a land animal when its 1 bit is clear, for a flying one its 2)
  const cols = Math.ceil(room.width / CELL);
  const rows = Math.ceil(room.height / CELL);
  const settings = {name: room.name, music: room.music, musicVol: 50, denCatId: 0,
    xmin: 0, ymin: 0, xmax: Math.max(0, room.width - SCREEN.w), ymax: Math.max(0, room.height - SCREEN.h),
    grid: {r2: CELL, r: CELL / 2, width: cols, height: rows, min: {x: 0, y: 0}, max: {x: cols * CELL, y: rows * CELL},
      packedGrid: packGrid([...room.grid].map(cell => 3 - Number(cell)))}};
  const actors = {
    ActorLayer: layers,
    ActorSpawn: room.spawns.map(spawn => ({name: spawn.name, x: spawn.x, y: spawn.y, r: 60, toSpawn: ""})),
    ActorSettings: [settings],
    ActorPortal: room.doors.map(door => ({x: door.x, y: door.y, r: door.r, goto: door.room, spawn: door.spawn || room.spawns[0].name,
      type: 0, fullSpawn: ""})),
    ActorAction: [],
    ActorVolume: [],
    ActorCollisionPoint: [],
  };
  return zlib.deflateSync(amf3.encode({assets, actors}));
};

const register = (room, file) => {
  defpacks.setCustomRoom({id: String(room.id), pathName: pathName(room.slug), type: room.ocean ? "1" : "0", isPlatformer: "0"});
  // for lib/roominfo.js, which reads the room's name from its file
  cdn.serveLocal(clientPath(room.slug), roomFile(room.slug, "xroom"));
  roomInfo.learn(basePath(room.slug), file);
};

// ---- what the panel asks

const summary = room => ({slug: room.slug, base: basePath(room.slug), name: room.name, ocean: room.ocean, open: room.open,
  width: room.width, height: room.height, pictures: room.pictures.length, doors: room.doors.length,
  createdBy: room.createdBy, createdAt: room.createdAt, updatedBy: room.updatedBy, updatedAt: room.updatedAt});

const list = () => [...rooms.values()].sort((a, b) => b.updatedAt - a.updatedAt).map(summary);

const get = slug => rooms.get(String(slug));

// the editor's room saved: {ok, room} or {error}. `isNew` makes one (whose
// path must be free), else changes the room at body.slug.
const save = (body, by, isNew) => {
  const old = isNew ? null : rooms.get(String(body.slug));
  if (!isNew && !old) {
    return {error: "No such room."};
  }
  const checked = check(body, old);
  if (checked.error) {
    return checked;
  }
  const room = checked.room;
  if (isNew && (rooms.has(room.slug) || defpacks.roomDef(basePath(room.slug)))) {
    return {error: `There is a room at custom.${room.slug} already.`};
  }
  const now = Math.floor(Date.now() / 1000);
  room.id = old ? old.id : Math.max(FIRST_ID - 1, ...[...rooms.values()].map(one => one.id)) + 1;
  room.createdBy = old ? old.createdBy : by;
  room.createdAt = old ? old.createdAt : now;
  room.updatedBy = by;
  room.updatedAt = now;
  const file = build(room);
  fs.mkdirSync(ROOMS(), {recursive: true, mode: 0o700});
  for (const [ext, data] of [["xroom", file], ["json", JSON.stringify(room)]]) {
    const waiting = `${roomFile(room.slug, ext)}.${process.pid}.part`;
    fs.writeFileSync(waiting, data, {mode: 0o600});
    fs.renameSync(waiting, roomFile(room.slug, ext));
  }
  rooms.set(room.slug, room);
  register(room, file);
  console.log(`[custom rooms] ${logText(by)} ${old ? "changed" : "made"} custom.${logText(room.slug)} (${logText(file.length)} bytes)`);
  return {ok: true, room};
};

const remove = (slug, by) => {
  const room = rooms.get(String(slug));
  if (!room) {
    return {error: "No such room."};
  }
  rooms.delete(room.slug);
  defpacks.unsetCustomRoom(pathName(room.slug));
  roomInfo.learn(basePath(room.slug), null);
  for (const ext of ["xroom", "json"]) {
    fs.rmSync(roomFile(room.slug, ext), {force: true});
  }
  console.log(`[custom rooms] ${logText(by)} deleted custom.${logText(room.slug)}`);
  return {ok: true, room};
};

// what the client is sent for a content path, when it is one of these
// rooms: {body} (null when its file is gone); undefined when it is not.
const asset = async relPath => {
  const room = [...rooms.values()].find(one => clientPath(one.slug) === relPath);
  if (!room) {
    return undefined;
  }
  return {body: await fs.promises.readFile(roomFile(room.slug, "xroom")).catch(() => null)};
};

// whether only staff may go in
const closed = base => {
  const match = /^custom\.([a-z0-9_]+)$/.exec(String(base));
  const room = match && rooms.get(match[1]);
  return Boolean(room && !room.open);
};

// the spawn points of any room, for a door's: from its file
const spawnsOf = async base => {
  const def = defpacks.roomDef(String(base));
  if (!def) {
    return null;
  }
  const body = await cdn.get(cdn.hashedPath(`roomDefs/${def.pathName}.xroom`), () => true);
  try {
    return (amf3.decode(zlib.inflateSync(body)).actors.ActorSpawn || []).map(spawn => String(spawn.name)).filter(Boolean);
  }
  catch (err) {
    return [];
  }
};

// the game's music, as its rooms name it: from the rooms in the cache
const music = async () => {
  if (!musicNames) {
    const names = new Set();
    for (const roomPath of defpacks.roomPaths()) {
      const body = await cdn.cached(cdn.hashedPath(`roomDefs/${roomPath}.xroom`));
      try {
        const settings = body && (amf3.decode(zlib.inflateSync(body)).actors.ActorSettings || [])[0];
        if (settings && /\.mp3$/i.test(settings.music || "")) {
          names.add(settings.music);
        }
      }
      catch (err) {
        // not a room file this can read: no music from it
      }
    }
    musicNames = [...names].sort((a, b) => a.localeCompare(b));
  }
  return musicNames;
};

// pictures no room uses, uploaded more than a day ago, go
const sweepPictures = () => {
  const used = new Set([...rooms.values()].flatMap(room => room.pictures.map(picture => picture.hash)));
  let gone = 0;
  for (const name of fs.existsSync(PICTURES()) ? fs.readdirSync(PICTURES()) : []) {
    const file = path.join(PICTURES(), name);
    if (!used.has(name.split(".")[0]) && Date.now() - fs.statSync(file).mtimeMs > PICTURE_KEPT_MS) {
      fs.rmSync(file, {force: true});
      gone++;
    }
  }
  return gone;
};

// at start: every saved room, built again (the build may have changed)
const load = () => {
  for (const name of fs.existsSync(ROOMS()) ? fs.readdirSync(ROOMS()) : []) {
    if (!name.endsWith(".json")) {
      if (name.endsWith(".part")) {
        fs.rmSync(path.join(ROOMS(), name), {force: true});
      }
      continue;
    }
    try {
      const room = JSON.parse(fs.readFileSync(path.join(ROOMS(), name), "utf8"));
      const file = build(room);
      fs.writeFileSync(roomFile(room.slug, "xroom"), file, {mode: 0o600});
      rooms.set(room.slug, room);
      register(room, file);
    }
    catch (err) {
      console.log(`[custom rooms] ${logText(name)} could not be read: ${logText(err.message)}`);
    }
  }
  const gone = sweepPictures();
  console.log(`[custom rooms] ${logText(rooms.size)} rooms${gone ? `, ${logText(gone)} unused pictures removed` : ""}`);
};

module.exports = {CELL, SCREEN, MIN_SIZE, MAX_SIZE, MAX_PICTURE_BYTES, addPicture, readPicture, check, build, list, get, save, remove,
  asset, closed, spawnsOf, music, load, basePath};
