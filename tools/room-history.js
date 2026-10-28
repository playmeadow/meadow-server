"use strict";

// lists every version of the lands' room files the CDN still has: for each
// room, which builds share a version, the big pictures inside it, and when
// its newest artwork was saved. this is how the older designs in the Theme
// list were found (DISCOVERIES.md, "Older designs of the lands").
//
//   node tools/room-history.js <workdir>
//
// downloads about 1.9 GB and keeps the 400 MB that is distinct, in
// <workdir>/files, so a second run only reads. A build is dated by the
// newest sale start in its item pack, which is a few weeks ahead of it.

const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const amf3 = require("../lib/amf3.js");
const cdn = require("../lib/cdn.js");
const config = require("../config.js");

const OLDEST_BUILD = 1600;
const LANDS = /^(appondale|aussie|balloosh|bahari_bay|canyon_path|coral_canyons|coralpets|crystal_sands|jamaa_township|lost_temple_of_zios|mountains_of_shivveer|oceans|pirate_ship|sarepia|r?holidays_and_celebrations)\//;
const BIG_PICTURE = 60000; // bytes; smaller JPEGs are patches and signs
const WORKERS = 12;

const tail = assetPath => cdn.hashedPath(assetPath).split("/").slice(1).join("/");

const download = async (build, assetPath) => {
  const url = new URL(`${build}/${tail(assetPath)}`, config.upstreamContent);
  url.searchParams.set("v", config.upstreamBuildVersion);
  for (let attempt = 0; attempt < 4; attempt++) {
    try {
      const res = await fetch(url, {headers: {"User-Agent": "Mozilla/5.0"}});
      if (res.status === 404 || res.status === 403) {
        return null;
      }
      if (res.ok) {
        return Buffer.from(await res.arrayBuffer());
      }
    }
    catch (err) {
      // tried again below
    }
  }
  throw new Error(`could not fetch ${assetPath} of build ${build}`);
};

const day = time => new Date(time).toISOString().slice(0, 10);

(async () => {
  const workDir = process.argv[2];
  if (!workDir) {
    console.log("usage: node tools/room-history.js <workdir>");
    process.exit(1);
  }
  const filesDir = path.join(workDir, "files");
  const indexFile = path.join(workDir, "index.json");
  fs.mkdirSync(filesDir, {recursive: true});

  // {builds: {build: newest sale start}, rooms: {room: {build: hash of its file}}}
  // read if it is there: no separate look first, which the file could change after
  let index = null;
  try {
    index = JSON.parse(fs.readFileSync(indexFile));
  }
  catch (err) {
    if (err.code !== "ENOENT") {
      throw err;
    }
  }
  if (!index) {
    index = {builds: {}, rooms: {}};
    const jobs = [];
    const candidates = Array.from({length: Number(config.deployVersion) - OLDEST_BUILD + 1}, (unused, at) => OLDEST_BUILD + at);
    await Promise.all(candidates.map(async build => {
      const rooms = await download(build, "defPacks/1011");
      if (!rooms) {
        return;
      }
      const items = Object.values(amf3.decode(zlib.inflateRawSync(await download(build, "defPacks/1000"))));
      index.builds[build] = day(1000 * Math.max(...items.map(def => Number(def.availabilityStartTime) || 0)));
      for (const def of Object.values(amf3.decode(zlib.inflateRawSync(rooms)))) {
        if (def && LANDS.test(def.pathName)) {
          jobs.push([build, String(def.pathName)]);
        }
      }
    }));
    console.log(`${Object.keys(index.builds).length} builds, ${jobs.length} room files`);
    const worker = async () => {
      while (jobs.length > 0) {
        const [build, room] = jobs.pop();
        const body = await download(build, `roomDefs/${room}.xroom`);
        const hash = body ? crypto.createHash("sha1").update(body).digest("hex").slice(0, 12) : null;
        // named by its own hash, so one already there is this same file: "wx"
        // writes only a new one, in the one step.
        if (body) {
          try {
            fs.writeFileSync(path.join(filesDir, hash), body, {flag: "wx"});
          }
          catch (err) {
            if (err.code !== "EEXIST") {
              throw err;
            }
          }
        }
        (index.rooms[room] = index.rooms[room] || {})[build] = hash;
      }
    };
    await Promise.all(Array.from({length: WORKERS}, worker));
    // written whole under another name, then put in its place
    fs.writeFileSync(`${indexFile}.tmp`, JSON.stringify(index));
    fs.renameSync(`${indexFile}.tmp`, indexFile);
  }

  console.log("Builds, by the newest sale start in each:");
  console.log(Object.entries(index.builds).map(([build, date]) => `  ${build} ${date}`).join("\n"));
  const described = new Map();
  const describe = hash => {
    if (!described.has(hash)) {
      const room = amf3.decode(zlib.inflateSync(fs.readFileSync(path.join(filesDir, hash))));
      const pictures = room.assets.filter(asset => /\.jpe?g$/i.test(asset.name) && Buffer.isBuffer(asset.ba) && asset.ba.length > BIG_PICTURE)
        .map(asset => String(asset.name).split("\\").slice(-2).join("/")).sort();
      const newest = Math.max(0, ...room.assets.map(asset => Number(new Date(asset.timeStamp)) || 0));
      described.set(hash, {pictures: pictures.join(" + ") || "(no big picture)", newest: newest ? day(newest) : "?", assets: room.assets.length});
    }
    return described.get(hash);
  };
  for (const room of Object.keys(index.rooms).sort()) {
    // versions with the same big pictures are one line: they differ in
    // decorations, which change monthly.
    const looks = new Map();
    for (const build of Object.keys(index.rooms[room]).sort()) {
      const hash = index.rooms[room][build];
      if (hash) {
        const {pictures, newest, assets} = describe(hash);
        const look = looks.get(pictures) || looks.set(pictures, {builds: [], newest, assets: new Set()}).get(pictures);
        look.builds.push(build);
        look.newest = newest > look.newest ? newest : look.newest;
        look.assets.add(assets);
      }
    }
    console.log(`\n${room}`);
    for (const [pictures, look] of looks) {
      console.log(`  ${pictures}\n    builds ${look.builds.join(" ")}; ${Math.min(...look.assets)}-${Math.max(...look.assets)} assets; newest artwork ${look.newest}`);
    }
  }
})().catch(err => {
  console.error(err);
  process.exit(1);
});
