#!/bin/sh
# makes a folder to copy to the machine that will host the server: the code,
# the asset cache, and a clean copy of the database. nothing else of data/
# goes: not the logs (months of game messages, with what players typed and
# enough to work some passwords out), not the recordings of the official
# game, not the old accounts.json.
#
#   tools/pack-for-vps.sh <new folder>
#
# the database is copied with SQLite's own VACUUM INTO, so it is whole and
# small whether or not the server is running. tools/ is left out but for
# what the running server may be asked to use.
set -e
cd "$(dirname "$(readlink -f "$0")")/.."
out=${1:?usage: tools/pack-for-vps.sh <new folder>}
[ -e "$out" ] && { echo "$out is already there" >&2; exit 1; }
mkdir -p "$out/data" "$out/tools"
cp -r server.js config.js package.json lib public swf client-updates "$out/"
cp tools/reset-admin-password.js "$out/tools/"
cp -r cache "$out/cache"
node -e '
const {DatabaseSync} = require("node:sqlite");
const db = new DatabaseSync(process.argv[1]);
db.exec("PRAGMA busy_timeout = 5000");
db.prepare("VACUUM INTO ?").run(process.argv[2]);
' data/game.sqlite "$out/data/game.sqlite"
[ -d data/masterpieces ] && cp -r data/masterpieces "$out/data/masterpieces"
chmod -R go-rwx "$out/data"
find "$out" -type d -exec chmod u+rwx {} +
find "$out" -type f -exec chmod u+rw,a-x {} +
echo "Packed into $out:"
du -sh "$out"/* | sed 's/^/  /'
