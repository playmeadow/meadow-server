"use strict";

// writes out the files a room file carries inside it.
//
//   node tools/room-assets.js <outdir> <room/path>...
//   node tools/room-assets.js /tmp/scenes pvp_tictactoe/room_main
//
// A room file (roomDefs/<path>.xroom: zlib, then AMF3) holds its artwork as
// SWFs in `assets`, each with a name and its bytes (`ba`); its layers say
// which asset each one shows. A minigame's scene is such a room, and the
// SWF on its "theGame" layer has code of its own: half the rules of each
// buddy game are in there (lib/buddygames.js). to read it:
//
//   java -jar tools/ffdec/ffdec-cli.jar -export script <dir> <the .swf>

const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const amf3 = require("../lib/amf3.js");
const cdn = require("../lib/cdn.js");

(async () => {
  const [outDir, ...rooms] = process.argv.slice(2);
  if (!outDir || rooms.length === 0) {
    console.log("usage: node tools/room-assets.js <outdir> <room/path>...");
    process.exit(1);
  }
  for (const room of rooms) {
    const body = await cdn.get(cdn.hashedPath(`roomDefs/${room}.xroom`));
    if (!body) {
      console.log(`${room}: no such room file`);
      continue;
    }
    const decoded = amf3.decode(zlib.inflateSync(body));
    const dir = path.join(outDir, room.replace(/\//g, "_"));
    fs.mkdirSync(dir, {recursive: true});
    for (const asset of decoded.assets) {
      const name = String(asset.name).replace(/[\\/: ]/g, "_");
      if (Buffer.isBuffer(asset.ba)) {
        fs.writeFileSync(path.join(dir, name), asset.ba);
      }
      console.log(`${room}: ${name} ${Buffer.isBuffer(asset.ba) ? `${asset.ba.length} bytes` : "(no bytes)"}`);
    }
    for (const layer of decoded.actors.ActorLayer || []) {
      console.log(`${room}: layer "${layer.name}" shows ${layer.assetName || layer.asset || "?"}`);
    }
  }
  process.exit(0);
})();
