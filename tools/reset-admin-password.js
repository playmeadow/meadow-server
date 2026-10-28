"use strict";

// forgets the admin panel's password, so the panel asks for a new one the
// next time it is opened. restart the server afterwards: from another machine
// the panel will want the setup code it prints at start.
//
//   node tools/reset-admin-password.js

const path = require("path");
const {DatabaseSync} = require("node:sqlite");
const config = require("../config.js");

const db = new DatabaseSync(path.join(config.dataDir, "game.sqlite"));
const result = db.prepare("DELETE FROM settings WHERE key = 'admin_password'").run();
console.log(result.changes ? "The admin password is forgotten. Restart the server, then open /admin." : "There was no admin password.");
