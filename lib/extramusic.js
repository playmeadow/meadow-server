"use strict";

const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const amf3 = require("./amf3.js");
const cdn = require("./cdn.js");

// extra den music: sounds found in the game's files that nothing plays, or
// that only one room plays, made into music den items (see "Odd audio" in
// DISCOVERIES.md). they are not in any shop; the item finder and the admin
// panel's gifts give them by id.
//
// A music den item plays "audio/<its abbrName>.mp3" from the content server
// (DenItemHolder), and the CDN has no such files for these. each one's
// sound sits inside a media file or a room file as an MP3 (a DefineSound
// tag of a zlib-compressed SWF), so the file is cut out of there when a
// client first asks for it. nothing of it is kept in this repository,
// except the tracks that are files of their own (`mp3`, in public/music/).

const FIRST_ID = 6001; // the official den items end at 5925
const STRING_BASE = 9000100;
const VOLUME = "40"; // the def's `flag`, as the official tracks have it
const TEMPLATE = 614; // "Jam On": each new row starts as a copy of this track's

// music files from the game's development CDN that no den item plays,
// kept in public/music/ and titled with their file names. tracks that
// already are den items there under another name (the same audio, or the
// same track by its name and length) were left out.
const DEV_MUSIC = [
  "aj_BD_newTheme.mp3", "AJ_cinema_lobby.mp3", "AJ_CS_mus_over_flow.mp3", "aj_dr_musIntro.mp3", "aj_dr_musOutro.mp3",
  "aj_eat_em_up.mp3", "aj_fallingPhantoms.mp3", "aj_mus_BD_FullSpectrum.mp3", "aj_mus_BD_muffled.mp3",
  "aj_mus_BD_OceanFullSpectrum.mp3", "aj_mus_Best_Dressed1.mp3", "aj_mus_bestDressedOcean1.mp3",
  "aj_mus_bestDressedOceanMuffled.mp3", "aj_mus_carnival.mp3", "aj_mus_club.mp3", "AJ_mus_den_sitar.mp3",
  "aj_mus_dolphin.mp3", "AJ_mus_double_up.mp3", "aj_mus_flag_room.mp3", "AJ_mus_gem_ball.mp3",
  "aj_mus_gem_breaker.mp3", "aj_mus_hassel_hoff.mp3", "aj_mus_hedgehog.mp3", "aj_mus_horseRaceLP.mp3",
  "AJ_mus_jamaa_township.mp3", "aj_mus_oceans_shop.mp3", "AJ_Mus_Phantom_Fighter.mp3", "aj_mus_phantoms_treasure.mp3",
  "aj_mus_pillBug.mp3", "aj_mus_rare_item_shop.mp3", "aj_mus_shiveer_tent.mp3", "aj_mus_sorting_game.mp3",
  "AJ_Mus_spider_shooter.mp3", "aj_mus_Thierrys_aquarium.mp3", "aj_mus_touchPool.mp3", "AJ_mus_twister.mp3",
  "aj_mus_wolfParty.mp3", "aj_musBackToSchoolParty.mp3", "aj_musBestGuess.mp3", "aj_musChineseNewYear.mp3",
  "aj_musEagleLP.mp3", "aj_musHospital.mp3", "aj_musNewJammaIntro.mp3", "aj_musNPEintro.mp3", "aj_musOutback.mp3",
  "aj_musOutbackShop.mp3", "aj_musPhntmKingIntro.mp3", "aj_musSpotOn.mp3", "aj_musStingerRaceIntro.mp3",
  "aj_musStingerRaceOver.mp3", "aj_musTelescopeRoom.mp3", "aj_musVolcanoGreely.mp3", "AJ_Native_American.mp3",
  "aj_petshop_mus.mp3", "AJ_reggaeton.mp3", "AJ_Shopping_music.mp3", "ajm_musBossBattle25.mp3", "ajm_musCloud.mp3",
  "ajm_musFFFruitShack.mp3", "ajm_musFFSplash.mp3", "ajm_musFFTheater.mp3", "ajm_tugOfWar.mp3", "ajmusMasterp.mp3",
  "ajq_forbodingTheme.mp3", "ajq_MiraThemeFinal.mp3", "ajq_mus2PhntmKings.mp3", "ajq_musAdvent20Hub.mp3",
  "ajq_musBattleoftheForrest.mp3", "ajq_musbunnyBurrow.mp3", "ajq_musCave.mp3", "ajq_musCaveBossBattle.mp3",
  "ajq_musCaveSlides.mp3", "ajq_musCharge.mp3", "ajq_musCombat.mp3", "ajq_musCraftingVillage.mp3",
  "ajq_musDungeon.mp3", "ajq_musEerieGreelyCave.mp3", "ajq_musFactoryBossLp.mp3", "ajq_musFroggyMarsh.mp3",
  "ajq_musGraveyard.mp3", "ajq_musHauntedForest.mp3", "ajq_musInToDeep.mp3", "ajq_musIntotheCaves.mp3",
  "ajq_musMadGreely.mp3", "ajq_musMiraTomb.mp3", "ajq_musOceanQuest9.mp3", "ajq_musOuterLimits.mp3",
  "ajq_musPeckSafe.mp3", "ajq_musPecksSecret.mp3", "ajq_musPhntmCreepy.mp3", "ajq_musPhntmDiguise.mp3",
  "ajq_musPhntmInvasion.mp3", "ajq_musPhntmKingIntro.mp3", "ajq_musPhntmRetreat.mp3", "ajq_musPumpkinPatch.mp3",
  "ajq_musQ22FinalRoom.mp3", "ajq_musQuest.mp3", "ajq_musQuest19Cave.mp3", "ajq_musQuest22.mp3",
  "ajq_musQuest22B.mp3", "ajq_MusQuest23.mp3", "ajq_MusQuest23Intro.mp3", "ajq_musQuestStealth.mp3",
  "ajq_musRoofTop.mp3", "ajq_musSafeLP.mp3", "ajq_musScienceLab.mp3", "ajq_musSearch4GreelyLP.mp3",
  "ajq_musSirGilbertsCastle.mp3", "ajq_musSpooky.mp3", "ajq_musSpotted.mp3", "ajq_musSuspicious.mp3",
  "ajq_musTrainingForrest.mp3", "ajq_musTreeHutPlayful.mp3", "ajq_musTugOfWarIdleLP.mp3", "ajq_musTurningTheTide.mp3",
  "ajq_musTutorial.mp3", "ajq_musVolcanoFreeze.mp3", "ajq_musVolIn.mp3", "ajq_musVolOut.mp3", "ajq_musWinterFun.mp3",
  "ajw_musWildExplorers.mp3", "ajw_musWildExplorersTent.mp3", "astronomy_mus_think.mp3", "fs_mus_intro.mp3",
  "Mus_AP_Interface.mp3", "Mus_Art_Studio_theme.mp3", "MusAppondaleMuseum.mp3", "MusBirdsOfParadise.mp3",
  "MusDenDef.mp3", "TD_mus_120bpm_lp.mp3", "TD_mus_80bpm_lp.mp3", "TD_mus_80bpm_nw.mp3", "TD_mus_80bpm_we.mp3",
];

// {file, title, sound: the sound's exported name ("" for the only, unnamed
// one), and where it is: a media id, or a room file and the asset in it, or
// an MP3 of this server's own in public/music/ (`mp3`)}. new tracks go at the
// end: a track's item id is its place in the list.
const TRACKS = [
  {file: "XtraNarration", title: "Narration", media: 1904, sound: "Narration"},
  {file: "XtraUnnamed", title: "Unnamed Sound", media: 46, sound: ""},
  {file: "XtraPhantomKings", title: "Phantom Kings", media: 2680, sound: "ajq_q7phntmKings.wav"},
  {file: "XtraYearBook", title: "TV Yearbook", media: 5828, sound: "ajq_tvYearBook"},
  {file: "XtraUSBKey", title: "Phantom USB Key", media: 5828, sound: "ajq_phntmUSBkey"},
  {file: "XtraNightingale", title: "Nightingale", media: 2365, sound: "ajq_nightingaleFull"},
  {file: "XtraVolcano", title: "Volcano", media: 2507, sound: "aj_musVolcanoFull"},
  ...[1, 2, 3, 4].map(layer => ({file: `XtraConcert${layer}`, title: `Concert Layer ${layer}`,
    room: "party/venue_concert", asset: "Concert\\Concert_Party_Front_Lights.swf", sound: `layer${layer}`})),
  {file: "XtraDebugMusic", title: "AJ_Debug_Music.mp3", mp3: "AJ_Debug_Music.mp3"},
  ...DEV_MUSIC.map(mp3 => ({file: `Xtra_${mp3.slice(0, -4)}`, title: mp3, mp3})),
].map((track, index) => ({...track, id: FIRST_ID + index, stringId: STRING_BASE + index}));

const ids = TRACKS.map(track => track.id);

// rows for the den item pack, each a copy of an official track's row.
const defs = template => TRACKS.map(track => ({
  ...template, id: String(track.id), nameStrId: String(track.stringId), abbrName: track.file, cost: "0", membersOnly: "0",
  flag: VOLUME, availabilityStartTime: null, availabilityEndTime: null,
}));

const strings = () => Object.fromEntries(TRACKS.map(track => [track.stringId, track.title]));

const TAG_DEFINE_SOUND = 14;
const TAG_EXPORT = 56;
const TAG_SYMBOL_CLASS = 76;
const FORMAT_MP3 = 2;

const soundIn = (swf, name) => {
  if (swf.toString("latin1", 0, 3) !== "CWS") {
    return null;
  }
  const body = zlib.inflateSync(swf.subarray(8));
  const sounds = new Map(); // character id -> MP3 data
  const names = new Map(); // character id -> exported name
  let at = Math.ceil((5 + 4 * (body[0] >> 3)) / 8) + 4; // past the frame size, rate and count
  while (at + 2 <= body.length) {
    const head = body.readUInt16LE(at);
    at += 2;
    let length = head & 0x3F;
    if (length === 0x3F) {
      length = body.readUInt32LE(at);
      at += 4;
    }
    const tag = body.subarray(at, at + length);
    at += length;
    if (head >> 6 === TAG_DEFINE_SOUND && tag.length > 9 && tag[2] >> 4 === FORMAT_MP3) {
      sounds.set(tag.readUInt16LE(0), tag.subarray(9)); // id, flags, sample count, seek samples, then the frames
    }
    else if (head >> 6 === TAG_SYMBOL_CLASS || head >> 6 === TAG_EXPORT) {
      let pos = 2;
      for (let left = tag.readUInt16LE(0); left > 0 && pos + 2 < tag.length; left--) {
        const end = tag.indexOf(0, pos + 2);
        names.set(tag.readUInt16LE(pos), tag.toString("utf8", pos + 2, end));
        pos = end + 1;
      }
    }
  }
  for (const [id, data] of sounds) {
    if ((names.get(id) || "") === name) {
      return Buffer.from(data);
    }
  }
  return null;
};

const MUSIC_DIR = path.join(__dirname, "..", "public", "music");

const extract = async track => {
  if (track.mp3) {
    return fs.promises.readFile(path.join(MUSIC_DIR, track.mp3));
  }
  if (track.media) {
    const swf = await cdn.get(cdn.hashedPath(`media/${track.media}`));
    return swf ? soundIn(swf, track.sound) : null;
  }
  const room = await cdn.get(cdn.hashedPath(`roomDefs/${track.room}.xroom`));
  const asset = room && amf3.decode(zlib.inflateSync(room)).assets
    .find(candidate => String(candidate.name).toLowerCase() === track.asset.toLowerCase());
  return asset && Buffer.isBuffer(asset.ba) ? soundIn(asset.ba, track.sound) : null;
};

const audioPaths = new Map(TRACKS.map(track => [cdn.hashedPath(`audio/${track.file}.mp3`), track]));
const made = new Map(); // track -> promise of its MP3

// what to answer a content request with when it is for one of these
// tracks' audio: {body, type}; undefined when it is not, and {body: null}
// when the source could not be read. (Music items have no picture: the
// den's music list shows their names.)
const asset = async relPath => {
  const track = audioPaths.get(relPath);
  if (!track) {
    return undefined;
  }
  if (!made.has(track)) {
    made.set(track, extract(track).catch(() => null));
  }
  const body = await made.get(track);
  if (!body) {
    made.delete(track); // offline, perhaps: try again next time
  }
  return {body, type: "audio/mpeg"};
};

module.exports = {TRACKS, ids, defs, strings, asset, TEMPLATE};
