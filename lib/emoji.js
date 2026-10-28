"use strict";

const fs = require("fs");
const path = require("path");
const config = require("../config.js");
const {logText} = require("./logtext.js");

// pictures of emoji, for the patched client's chat bubbles (gui.ChatBalloon):
// the game's font has none, so an emoji typed in chat (with Windows' emoji
// panel, say) is drawn as one of these. they are Twemoji's (CC-BY 4.0,
// jdecked/twemoji on GitHub), asked of config.emojiUpstream once
// each and kept in data/emoji. a name is the emoji's code points in hex,
// joined by "-", as Twemoji names its files ("1f600", "1f468-200d-1f469").

const NAME = /^[0-9a-f]{2,6}(?:-[0-9a-f]{2,6}){0,9}$/;
const MAX_BYTES = 64 * 1024;
const MAX_MISSING = 5000;
const PNG_SIGNATURE = Buffer.from([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
const DIR = path.join(config.dataDir, "emoji");

const missing = new Set(); // names the upstream does not have
const pending = new Map(); // name -> promise, so that one is asked for once

const isName = name => typeof name === "string" && NAME.test(name);

const fileOf = name => path.join(DIR, `${name}.png`);

const fetchUpstream = async name => {
  const res = await fetch(`${config.emojiUpstream}${name}.png`, {signal: AbortSignal.timeout(config.upstreamTimeoutMs)});
  if (!res.ok) {
    if (res.status === 404 || res.status === 403) {
      if (missing.size >= MAX_MISSING) {
        missing.clear();
      }
      missing.add(name);
    }
    return null;
  }
  const body = Buffer.from(await res.arrayBuffer());
  // a PNG, and a small one, or nothing is kept
  if (body.length > MAX_BYTES || !body.subarray(0, 8).equals(PNG_SIGNATURE)) {
    console.log(`[emoji] not a picture: ${logText(name)}`);
    return null;
  }
  try {
    fs.mkdirSync(DIR, {recursive: true});
    const tmp = `${fileOf(name)}.${process.pid}.tmp`;
    fs.writeFileSync(tmp, body);
    fs.renameSync(tmp, fileOf(name));
  }
  catch (err) {
    console.log(`[emoji] could not keep ${logText(name)}: ${logText(err.message)}`);
  }
  return body;
};

// the picture for `name`: a Buffer, or null. `mayFetch()`: whether one not
// kept yet may be asked of the upstream for this request (asked only then).
const get = async (name, mayFetch) => {
  if (!isName(name) || missing.has(name)) {
    return null;
  }
  try {
    return await fs.promises.readFile(fileOf(name));
  }
  catch (err) {
    if (err.code !== "ENOENT") {
      return null;
    }
  }
  if (!mayFetch()) {
    return null;
  }
  if (!pending.has(name)) {
    pending.set(name, fetchUpstream(name).catch(() => null).finally(() => pending.delete(name)));
  }
  return pending.get(name);
};

module.exports = {get, isName};
