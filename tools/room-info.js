const path=require("path");const SRV=process.argv[2];
const cdn=require(path.join(SRV,"lib/cdn.js")),zlib=require("zlib"),amf=require(path.join(SRV,"lib/amf3.js"));
(async()=>{for(const p of process.argv.slice(3)){const b=await cdn.get(cdn.hashedPath("roomDefs/"+p+".xroom"));if(!b){console.log("==",p,"MISSING");continue}const o=amf.decode(zlib.inflateSync(b));
const ts=o.assets.map(a=>Number(a.timeStamp)).filter(Boolean).sort((a,b)=>a-b);const d=t=>new Date(t>1e12?t:t*1000).toISOString().slice(0,10);
console.log("==",p,"assets",o.assets.length,"newest asset",ts.length?d(ts[ts.length-1]):"?", "oldest",ts.length?d(ts[0]):"?");
const L=o.actors.ActorLayer||[];
if(process.env.KEYS){console.log("  layer keys:",Object.keys(L[0]).join(","));console.log("  settings:",JSON.stringify(o.actors.ActorSettings[0],(k,v)=>Buffer.isBuffer(v)?"bytes":v).slice(0,900))}
const names=[...new Set([...o.assets.map(a=>a.name),...L.map(l=>l.name)])].filter(n=>/hallow|spook|pumpk|phantom|night|snow|winter|jamaalid|xmas|christ|holiday|friend|heart|valent|summer|beach|freedom|firework|lucky|clover|feast|leaf|spring|egg|birthday|season/i.test(String(n)));
console.log("  seasonal-looking names:",names.join(", ").slice(0,700)||"(none)");
if(process.env.ALL)console.log("  all layers:",L.map(l=>l.name).join(", ").slice(0,3000));
}})().catch(e=>console.log("ERR",e.stack));
