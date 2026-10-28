"use strict";

// collects when each item was on sale, from every build of the defPacks the
// CDN still serves, into lib/sale-dates.json (see lib/sales.js for what
// reads it).
//
//   node tools/sale-history.js
//
// an item's def carries one sale window, availabilityStartTime to
// availabilityEndTime, and the official game rewrote it whenever the item
// came back: Halloween items have a window each October, and so on. any one
// build only has the latest. old builds stay on the CDN under their own
// number (35 of them between 1636 and 1830 when this was written), so
// reading them all gives each item's windows over about four years.
//
// downloads about 10 MB and keeps none of it.

const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const amf3 = require("../lib/amf3.js");
const cdn = require("../lib/cdn.js");
const config = require("../config.js");

const PACKS = {clothing: 1000, denItems: 1030, diamond: 1054};
const OLDEST_BUILD = 1600;
const DAY = 86400;
const OUT = path.join(__dirname, "..", "lib", "sale-dates.json");

const fetchPack = async (build, id) => {
  const tail = cdn.hashedPath(`defPacks/${id}`).split("/").slice(1).join("/");
  const url = new URL(`${build}/${tail}`, config.upstreamContent);
  url.searchParams.set("v", config.upstreamBuildVersion);
  for (let attempt = 0; attempt < 3; attempt++) {
    try {
      const res = await fetch(url, {headers: {"User-Agent": "Mozilla/5.0"}});
      if (res.status === 404 || res.status === 403) {
        return null;
      }
      if (res.ok) {
        return Object.values(amf3.decode(zlib.inflateRawSync(Buffer.from(await res.arrayBuffer()))));
      }
    }
    catch (err) {
      // tried again below
    }
  }
  throw new Error(`could not fetch defPack ${id} of build ${build}`);
};

(async () => {
  const candidates = [];
  for (let build = OLDEST_BUILD; build <= Number(config.deployVersion); build++) {
    candidates.push(build);
  }
  const found = await Promise.all(candidates.map(async build => (await fetchPack(build, PACKS.clothing) ? build : null)));
  const builds = found.filter(Boolean);
  console.log(`${builds.length} builds on the CDN: ${builds[0]} to ${builds[builds.length - 1]}`);

  const out = {builds: [builds[0], builds[builds.length - 1]]};
  for (const [name, id] of Object.entries(PACKS)) {
    const windows = new Map(); // def id -> Set of "startDay,endDay"
    for (const build of builds) {
      for (const def of await fetchPack(build, id) || []) {
        const start = Number(def.availabilityStartTime) || 0;
        const end = Number(def.availabilityEndTime) || 0;
        // only a window with both ends says "this is when it is sold".
        if (start > 0 && end > start) {
          const key = String(def.id);
          windows.set(key, (windows.get(key) || new Set()).add(`${Math.floor(start / DAY)},${Math.ceil(end / DAY)}`));
        }
      }
    }
    out[name] = Object.fromEntries([...windows].sort((one, other) => Number(one[0]) - Number(other[0]))
      .map(([key, set]) => [key, [...set].map(window => window.split(",").map(Number)).sort((one, other) => one[0] - other[0])]));
    const counts = Object.values(out[name]).map(list => list.length);
    console.log(`${name}: ${counts.length} items with sale windows, ${counts.reduce((sum, count) => sum + count, 0)} windows`);
  }
  // one item a line: the file is committed, and this keeps its diffs readable.
  const body = Object.entries(out).map(([name, value]) => (Array.isArray(value)
    ? `  ${JSON.stringify(name)}: ${JSON.stringify(value)}`
    : `  ${JSON.stringify(name)}: {\n${Object.entries(value).map(([id, list]) => `    ${JSON.stringify(id)}: ${JSON.stringify(list)}`).join(",\n")}\n  }`));
  fs.writeFileSync(OUT, `{\n${body.join(",\n")}\n}\n`);
  console.log(`wrote ${OUT} (${fs.statSync(OUT).size} bytes)`);
})().catch(err => {
  console.error(err.message);
  process.exit(1);
});
