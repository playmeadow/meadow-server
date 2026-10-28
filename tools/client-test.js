// drives the custom client (~/aj-private-client) through a real login and
// saves a screenshot of the game view. it opens a window on the desktop.
//
//   AJ_USER=name AJ_PASS=password [WAIT=55000] node tools/client-test.js shot.png
//
// extra arguments go to Electron. uses the Chrome DevTools Protocol.
const {spawn} = require("child_process"); const os = require("os"); const fs = require("fs");
const PORT = 9336; const extra = process.argv.slice(3); const shotPath = process.argv[2];
const child = spawn(os.homedir() + "/aj-private-client/run.sh", [`--remote-debugging-port=${PORT}`, "--enable-logging", ...extra], {stdio: ["ignore", "pipe", "pipe"]});
let log = ""; child.stdout.on("data", d => log += d); child.stderr.on("data", d => log += d);
const sleep = ms => new Promise(r => setTimeout(r, ms));
const connect = async target => { const ws = new WebSocket(target.webSocketDebuggerUrl); await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; }); let id = 0; const pending = new Map(); ws.onmessage = m => { const d = JSON.parse(m.data); if (d.id && pending.has(d.id)) { pending.get(d.id)(d); pending.delete(d.id); } }; return (method, params = {}) => new Promise(res => { const i = ++id; pending.set(i, res); ws.send(JSON.stringify({id: i, method, params})); }); };
const targets = async () => (await fetch(`http://127.0.0.1:${PORT}/json`)).json();
const evalIn = async (send, expr) => { const r = await send("Runtime.evaluate", {expression: expr, awaitPromise: true, returnByValue: true}); return r.result.exceptionDetails ? "EXC" : r.result.result.value; };
(async () => {
  let list = []; for (let i = 0; i < 40; i++) { try { list = await targets(); if (list.some(t => t.url.includes("index.html"))) break; } catch (e) {} await sleep(300); }
  const host = await connect(list.find(t => t.url.includes("index.html")));
  await sleep(800);
  await evalIn(host, `document.getElementById('username').value=${JSON.stringify(process.env.AJ_USER)}; document.getElementById('password').value=${JSON.stringify(process.env.AJ_PASS)}; document.getElementById('log-in').click()`);
  await sleep(Number(process.env.WAIT || 12000));
  console.log("game visible:", await evalIn(host, "!document.getElementById('game').hidden"), "status:", await evalIn(host, "document.getElementById('status').textContent"));
  const g = (await targets()).find(x => x.type === "webview");
  if (g && shotPath !== "-") { const guest = await connect(g); const sh = await guest("Page.captureScreenshot", {format: "png"}); if (sh.result && sh.result.data) fs.writeFileSync(shotPath, Buffer.from(sh.result.data, "base64")); }
  child.kill(); await sleep(300);
  console.log(log.split("\n").filter(l => /ERROR|plugin|Plugin|flash|Flash|sandbox/i.test(l) && !/GetVSync|Security Warning/.test(l)).slice(0, 12).join("\n").slice(0, 1800));
  process.exit(0);
})().catch(e => { console.log("FAILED", e.message); child.kill(); process.exit(1); });
