"use strict";

const {logText} = require("./logtext.js");
const crypto = require("crypto");
const fs = require("fs");
const path = require("path");
const config = require("../config.js");

// mirrors LoaderCache.hashItV2 in the client: the last path component of every
// versioned asset is obfuscated this way before it is requested.
const hashName = name => {
  const salted = "W3 7r4Ck h4X0r3rs" + name;
  let out = "";
  for (let i = 0; i < salted.length; i++) {
    out = i % 2 === 0 ? out + salted[i] : salted[i] + out;
  }
  return crypto.createHash("md5").update(out).digest("hex");
};

// "defPacks/1003" -> "1830/defPacks/<hash>"
const hashedPath = assetPath => {
  const parts = assetPath.split("/");
  parts.push(hashName(parts.pop()));
  return `${config.deployVersion}/${parts.join("/")}`;
};

const missing = new Set();
const inFlight = new Map();

// asset paths are short and plain; anything else is not worth asking the
// upstream CDN about on a stranger's behalf.
const ASSET_PATH = /^[A-Za-z0-9_.\-\/]{1,200}$/;
const MAX_MISSING = 20000;
const MAX_DOWNLOADS = 64; // at once

// the builds this server has any use for: the one the game runs on, the
// older ones room files are taken from, and the themes' (config.js). the
// official CDN holds a good deal more under other names (every other build,
// and two folders of players' own data); none of that is fetched, kept or
// handed on for anyone.
const BUILDS = new Set([config.deployVersion, ...config.olderBuilds, ...Object.values(config.themes).map(theme => theme.build)].map(String));

// the path as it is kept and asked for: "a/./b" and "a//b" are "a/b", and
// nothing climbs out of its build. null for a path that is not an asset's.
const clean = relPath => {
  if (typeof relPath !== "string" || !ASSET_PATH.test(relPath)) {
    return null;
  }
  const parts = relPath.split("/").filter(part => part !== "" && part !== ".");
  return parts.length >= 2 && !parts.includes("..") && BUILDS.has(parts[0]) ? parts.join("/") : null;
};

const cacheFile = relPath => {
  const file = path.join(config.cacheDir, relPath);
  return file.startsWith(config.cacheDir + path.sep) ? file : null;
};

// the cache is the official game's files, and nginx sends them itself
// (deploy/): they must be readable by others, whatever umask this process
// keeps for its private data (server.js). one written owner-only was a 403
// from nginx, and the game waited for it behind a spinner for good.
const FILE_MODE = 0o644;
const DIR_MODE = 0o755;

// how much the cache holds: counted once at start (in the background), then
// kept up as files are added. files and folders an earlier server wrote
// owner-only are opened up on the way.
let cacheBytes = 0;
const measure = async folder => {
  for (const entry of await fs.promises.readdir(folder, {withFileTypes: true}).catch(() => [])) {
    const entryPath = path.join(folder, entry.name);
    const stat = await fs.promises.stat(entryPath).catch(() => null);
    if (!stat) {
      continue;
    }
    const wanted = entry.isDirectory() ? DIR_MODE : FILE_MODE;
    if ((stat.mode & 0o777) !== wanted) {
      await fs.promises.chmod(entryPath, wanted).catch(() => {});
    }
    if (entry.isDirectory()) {
      await measure(entryPath);
    }
    else {
      cacheBytes += stat.size;
    }
  }
};
measure(config.cacheDir).then(() => {
  if (cacheBytes > config.maxCacheBytes) {
    console.log(`[cdn] the cache holds ${logText(Math.round(cacheBytes / 1048576))} MB, over its limit: new files are served but not kept (AJ_MAX_CACHE_MB)`);
  }
});

// mkdir -p, each folder it makes opened up (the umask would leave them 700)
const mkdirOpen = async folder => {
  const first = await fs.promises.mkdir(folder, {recursive: true});
  if (first) {
    for (let dir = folder; dir.length >= first.length; dir = path.dirname(dir)) {
      await fs.promises.chmod(dir, DIR_MODE);
    }
  }
};

const download = async (relPath, file) => {
  const url = new URL(relPath, config.upstreamContent);
  url.searchParams.set("v", config.upstreamBuildVersion);
  const res = await fetch(url, {headers: {"User-Agent": "Mozilla/5.0"}, signal: AbortSignal.timeout(config.upstreamTimeoutMs)});
  if (!res.ok) {
    if (res.status === 404 || res.status === 403) {
      if (missing.size >= MAX_MISSING) {
        missing.clear();
      }
      missing.add(relPath);
    }
    console.log(`[cdn] ${logText(res.status)} ${logText(relPath)}`);
    return null;
  }
  const body = Buffer.from(await res.arrayBuffer());
  // A cache that cannot be written to (wrong owner, full disk) costs a
  // download each time; it must not cost the player the file.
  try {
    if (cacheBytes + body.length > config.maxCacheBytes) {
      return body;
    }
    cacheBytes += body.length;
    await mkdirOpen(path.dirname(file));
    const tmp = `${file}.${process.pid}.tmp`;
    await fs.promises.writeFile(tmp, body);
    await fs.promises.chmod(tmp, FILE_MODE);
    await fs.promises.rename(tmp, file);
    console.log(`[cdn] cached ${logText(relPath)} (${logText(body.length)} bytes)`);
  }
  catch (err) {
    console.log(`[cdn] could not cache ${logText(relPath)}: ${logText(err.message)}`);
  }
  return body;
};

// `mayFetch`: may a file that is not in the cache be asked of the official
// CDN for this request? (Whoever asks for too many is given only what is
// there already: lib/http.js.)
const getExact = async (asked, mayFetch = () => true) => {
  const relPath = clean(asked);
  const file = relPath && cacheFile(relPath);
  if (!file) {
    return null;
  }
  try {
    return await fs.promises.readFile(file);
  }
  catch (err) {
    if (err.code !== "ENOENT" && err.code !== "EISDIR" && err.code !== "ENOTDIR") {
      throw err;
    }
  }
  if (config.offline || missing.has(relPath)) {
    return null;
  }
  if (!inFlight.has(relPath) && (inFlight.size >= MAX_DOWNLOADS || !mayFetch())) {
    return null;
  }
  if (!inFlight.has(relPath)) {
    // A download that fails (the CDN not answering in time) is "not there"
    // for now, and is tried again the next time the file is asked for.
    inFlight.set(relPath, download(relPath, file).catch(err => {
      console.log(`[cdn] could not fetch ${logText(relPath)}: ${logText(err.message)}`);
      return null;
    }).finally(() => inFlight.delete(relPath)));
  }
  return inFlight.get(relPath);
};

// files of this server's own served in place of the CDN's: the extra rooms
// (lib/extrarooms.js), by the path the client asks for them at.
const localFiles = new Map();
const serveLocal = (relPath, file) => localFiles.set(relPath, file);

// returns the asset's bytes, or null when it does not exist. A room file the
// current build no longer has is looked for in the older builds named in
// config.olderBuilds (the client asks for everything under the current one).
const CURRENT_ROOM_FILE = new RegExp(`^${config.deployVersion}/(roomDefs/.+)$`);
const get = async (relPath, mayFetch) => {
  const local = localFiles.get(clean(relPath));
  if (local) {
    return fs.promises.readFile(local).catch(() => null);
  }
  const body = await getExact(relPath, mayFetch);
  const room = body ? null : CURRENT_ROOM_FILE.exec(clean(relPath) || "");
  if (room) {
    for (const build of config.olderBuilds) {
      const older = await getExact(`${build}/${room[1]}`, mayFetch);
      if (older) {
        return older;
      }
    }
  }
  return body;
};

// the asset's bytes if it is already in the cache, else null; never downloads.
const cached = async asked => {
  const relPath = clean(asked);
  if (localFiles.has(relPath)) {
    return fs.promises.readFile(localFiles.get(relPath)).catch(() => null);
  }
  const file = relPath && cacheFile(relPath);
  try {
    return file ? await fs.promises.readFile(file) : null;
  }
  catch (err) {
    return null;
  }
};

// whether the official CDN said it has no such file (a 404 or 403 when it
// was asked), as against one not asked for yet or not fetched just now.
const knownMissing = asked => missing.has(clean(asked));

// is this asset one of this server's own files (serveLocal)? those change
// with the server, where the game's own never do.
const isLocal = asked => localFiles.has(clean(asked));

module.exports = {get, cached, knownMissing, hashName, hashedPath, serveLocal, isLocal};
