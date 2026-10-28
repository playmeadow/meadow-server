"use strict";

// rooms that are in no build of the Flash client, and older versions of
// rooms it still has, from the HTML5 client's room files (lib/extra-rooms.json:
// the room's id and path, the file it is made from, unreleased or older).
// tools/import-xroomgl.js builds them into config.extraRoomsDir; each one
// built is in the room list (lib/defpacks.js) and its file is served where
// the client looks for it (lib/cdn.js), so "!go <path>" and the admin
// panel's Debug page take a player there. an older version goes by its
// room's path with "_old" after it.

const fs = require("fs");
const path = require("path");
const config = require("../config.js");
const cdn = require("./cdn.js");
const {logText} = require("./logtext.js");
const {rooms} = require("./extra-rooms.json");

const built = rooms.filter(room => {
  const file = path.join(config.extraRoomsDir, `${room.pathName}.xroom`);
  if (!fs.existsSync(file)) {
    return false;
  }
  cdn.serveLocal(cdn.hashedPath(`roomDefs/${room.pathName}.xroom`), file);
  return true;
});
if (built.length) {
  console.log(`[rooms] ${logText(built.length)} extra rooms from ${logText(config.extraRoomsDir)}`);
}

module.exports = {
  // the room pack's entries for them
  defs: () => built.map(({id, pathName, type, isPlatformer}) => ({id, pathName, type, isPlatformer})),
  rooms: () => built,
};
