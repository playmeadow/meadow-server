"use strict";

const {logText} = require("./logtext.js");
const accounts = require("./accounts.js");
const config = require("../config.js");
const defpacks = require("./defpacks.js");
const epicDens = require("./epicdens.js");
const masterpieces = require("./masterpieces.js");
const {activeAvatar, isUint} = require("./player.js");

// parties (client side: PartyManager, PartyPopup, CustomPartyCreatePopup).
//
// "AJ parties" are the game's own party rooms. the real game opened a few
// at a time on a timetable; here every one whose room exists is open all
// the time. A party room is called "party<defId>".
//
// "Jammer parties" are hosted by players: pick one of the party rooms made
// for it, a three-word name and the music, pay a diamond, and the party is
// listed for everyone until it ends. its room is "pparty<host username>",
// which is how the client tells whose party it is in.

const ROOM_TYPE_PARTY = 5; // RoomManagerWorld: clientInfo.roomType in a party
const CURRENCY_DIAMONDS = 3;
const HOST_COST = 1; // diamonds; CustomPartyCreatePopup shows this price
const NOT_HOSTING = -1;
const ALWAYS_OPEN_SECONDS = 86400;
// the world map's "AJHQ" button asks for this party: today's showcase den.
const PARTY_EPIC_DEN = 36;
const PARTY_GALLERY = 47; // PartyManager.PARTY_DEF_MASTERPIECE

// PartyManager restrictions
const RESTRICT_AVATAR = 1;
const RESTRICT_PET = 4;
const RESTRICT_PET_ONLY = 8;

// generic lists the party windows ask for.
const LIST_CUSTOM_PARTY_DEFS = 370;
const LIST_PARTY_MUSIC = 401;
// the three name wheels of CustomPartyCreatePopup, as ranges of ids in the
// localization defPack ("Epic" ... "Trading", "Birthday" ... "Animal",
// "Den" ... "Alliance"). 24138 sits in the first range but is a den item's name.
const NAME_LISTS = new Map([
  [386, [24135, 24161]],
  [387, [24162, 24185]],
  [388, [24186, 24210]],
]);
const NOT_A_NAME = 24138;
const MAX_PARTIES = 200;

const now = () => Math.floor(Date.now() / 1000);

module.exports = ({enterRoom, findOnline, blocks}) => {
  // parties being hosted: lowercased host username -> {host, defId, name, music, endsAt}
  const hosted = new Map();

  const joinable = def => def && def.room && defpacks.roomDef(def.room) && !def.isGame;
  const ajParties = () => defpacks.partyDefs().filter(def => joinable(def) && !def.isCustom);
  const customDefs = () => defpacks.partyDefs().filter(def => joinable(def) && def.isCustom);

  const nameList = listId => {
    const [first, last] = NAME_LISTS.get(Number(listId));
    return Array.from({length: last - first + 1}, (_, i) => first + i).filter(id => id !== NOT_A_NAME);
  };
  const validName = (listId, id) => isUint(id) && nameList(listId).includes(Number(id));

  const partyOf = account => {
    const party = hosted.get(account.username.toLowerCase());
    if (party && party.endsAt <= now()) {
      hosted.delete(account.username.toLowerCase());
      return null;
    }
    return party || null;
  };

  // seconds the account's own party has left; NOT_HOSTING without one.
  const timeLeft = account => {
    const party = partyOf(account);
    return party ? party.endsAt - now() : NOT_HOSTING;
  };

  const liveParties = () => [...hosted.values()].filter(party => partyOf(party.host));

  // PartyManager.roomSoireeResponse: [0, reason, ...]; "NA" wrong animal,
  // "NP" no pet, each with the party def the barrier popup is about.
  const refuse = (session, reason, defId) => session.sendXt("sj", -1, 0, reason, defId);

  const joinAjParty = (session, defId) => {
    const def = defpacks.partyDef(defId);
    if (!joinable(def) || def.isCustom) {
      refuse(session, "NM", defId);
      return;
    }
    const avatar = activeAvatar(session.account);
    if (def.restrictions === RESTRICT_AVATAR && !((BigInt(def.avatarDefFlags) >> BigInt(avatar.type - 1)) & 1n)) {
      refuse(session, "NA", def.id);
      return;
    }
    if ([RESTRICT_PET, RESTRICT_PET_ONLY].includes(def.restrictions) && !avatar.petInvId) {
      refuse(session, "NP", def.id);
      return;
    }
    const shard = config.shards[0];
    if (def.id === PARTY_EPIC_DEN) {
      // A room to each showcase den, so that whoever is inside when the day
      // turns stays where they are.
      const den = epicDens.featured();
      enterRoom(session, `party${def.id}_${den.id}`, den.base, den.name, shard.id, {roomType: ROOM_TYPE_PARTY, secondaryDefId: def.id});
      return;
    }
    // the Masterpiece Gallery hangs players' paintings on its walls: the
    // room is told which with its properties (PartyManager.setupMasterpiecesInRoom,
    // which also has to be given the two lists when there are none).
    enterRoom(session, `party${def.id}`, def.room, defpacks.string(def.titleStrId) || "Party", shard.id,
      {roomType: ROOM_TYPE_PARTY, secondaryDefId: def.id, ...(def.id === PARTY_GALLERY ? {customData: masterpieces.gallery} : {})});
  };

  // PartyManager.customPartyJoinResponse: [success, reason]
  const joinHosted = (session, host) => {
    const party = host && partyOf(host);
    // A one-use staff teleport may inspect a hosted party despite a block;
    // ordinary party joins retain the host's privacy rule.
    if (!party || (!session.staffTravel && blocks.either(host, session.account))) {
      session.sendXt("sjp", -1, 0, party ? "BLK" : "NPP");
      return;
    }
    const def = defpacks.partyDef(party.defId);
    const room = enterRoom(session, `pparty${host.username}`, def.room, party.name, config.shards[0].id,
      {roomType: ROOM_TYPE_PARTY, secondaryDefId: def.id, customMusicDef: party.music, partyHost: host});
    if (room) {
      session.sendXt("sjp", -1, 1);
    }
  };

  // ends a party: everyone in it goes back to the starting room.
  const end = (party, sendHome) => {
    hosted.delete(party.host.username.toLowerCase());
    const hostSession = findOnline(party.host.username);
    if (hostSession) {
      // PartyManager.customPartyKillResponse: [diamonds refunded]
      hostSession.sendXt("spk", -1, 0);
    }
    sendHome(`pparty${party.host.username}`);
  };

  const handlers = {
    // PartyPopup.partyListResponse: [?, count, (partyDefId, secondsToStart,
    // secondsToEnd)...]
    sl(session) {
      const list = ajParties();
      session.sendXt("sl", -1, 0, list.length, ...list.flatMap(def => [def.id, 0, ALWAYS_OPEN_SECONDS]));
    },

    // [partyDefId]
    sj(session, roomId, [defId]) {
      joinAjParty(session, defId);
    },

    // PartyPopup.customPartyListResponse: [success, total, first, pageSize,
    // count, (hostUuid, "nameId|nameId|nameId", server node, partyDefId,
    // secondsLeft)...]. the node has to be this server's own address
    // (SFClient.serverIp) or the client tries to change servers.
    slp(session) {
      const list = liveParties().filter(party => !blocks.either(party.host, session.account));
      session.sendXt("slp", -1, 1, list.length, 0, list.length, list.length,
        ...list.flatMap(party => [party.host.uuid, party.name, config.host, party.defId, party.endsAt - now()]));
    },

    // CustomPartyCreatePopup: [partyDefId, nameId1, nameId2, nameId3,
    // musicDenItemId]. PartyManager.customPartyCreateResponse reads
    // [1, isHost, secondsLeft] or [0, reason].
    scp(session, roomId, [defId, name1, name2, name3, music]) {
      const {account} = session;
      const def = defpacks.partyDef(defId);
      const fail = reason => session.sendXt("scp", -1, 0, reason);
      if (!joinable(def) || !def.isCustom || !validName(386, name1) || !validName(387, name2) || !validName(388, name3)
        || !defpacks.musicIds().includes(Number(music))) {
        fail("INV");
        return;
      }
      if (partyOf(account)) {
        fail("EXISTS");
        return;
      }
      if ((account.currency.diamonds || 0) < HOST_COST) {
        fail("ND");
        return;
      }
      if (liveParties().length >= MAX_PARTIES) {
        fail("DIS");
        return;
      }
      account.currency.diamonds -= HOST_COST;
      accounts.save(account);
      const party = {host: account, defId: def.id, name: `${name1}|${name2}|${name3}`, music: Number(music), endsAt: now() + config.partyMinutes * 60};
      hosted.set(account.username.toLowerCase(), party);
      console.log(`[world] ${logText(account.username)} is hosting a party (def ${logText(def.id)})`);
      session.sendXt("cu", -1, CURRENCY_DIAMONDS, account.currency.diamonds, 0);
      session.sendXt("scp", -1, 1, 1, party.endsAt - now());
      joinHosted(session, account);
    },

    // PartyManager.customPartyIsHostingResponse: [hostUuid] -> seconds left
    // of that player's party, -1 when there is none.
    sphp(session, roomId, [uuid]) {
      const party = liveParties().find(candidate => candidate.host.uuid === uuid);
      session.sendXt("sphp", -1, party ? party.endsAt - now() : NOT_HOSTING);
    },

    // PartyManager.onGetPartyNodeId: [hostUuid] -> [success, hostUuid, node]
    spn(session, roomId, [uuid]) {
      const party = liveParties().find(candidate => candidate.host.uuid === uuid);
      session.sendXt("spn", -1, party ? 1 : 0, uuid, config.host);
    },

    // [hostUuid]
    sjp(session, roomId, [uuid]) {
      const party = liveParties().find(candidate => candidate.host.uuid === uuid);
      joinHosted(session, party ? party.host : null);
    },

    // PartyXtCommManager.sendPartyMasterpiece: the paintings on show, as
    // JSON (BulletinBoard.onMasterpiecesLoaded reads pool[0]); empty for none.
    sm(session) {
      const gallery = masterpieces.gallery();
      session.sendXt("sm", -1, gallery.pool.length ? JSON.stringify(gallery) : "");
    },
  };

  // "party12" / "ppartyAlice", from a buddy's "go to": joins it. false when
  // the name is not a party room's.
  const joinByRoomName = (session, name) => {
    const aj = /^party(\d+)(?:_\d+)?$/.exec(name);
    if (aj) {
      joinAjParty(session, aj[1]);
      return true;
    }
    if (/^pparty/i.test(name)) {
      joinHosted(session, accounts.byName(name.slice(6)));
      return true;
    }
    return false;
  };

  // parties whose time is up, checked once a minute.
  const expire = sendHome => {
    for (const party of [...hosted.values()]) {
      if (party.endsAt <= now()) {
        end(party, sendHome);
      }
    }
  };

  // generic lists: null when `listId` is not one of the party windows'.
  const list = listId => {
    if (Number(listId) === LIST_CUSTOM_PARTY_DEFS) {
      return customDefs().map(def => def.id);
    }
    if (Number(listId) === LIST_PARTY_MUSIC) {
      return defpacks.musicIds();
    }
    return NAME_LISTS.has(Number(listId)) ? nameList(listId) : null;
  };

  return {
    handlers,
    timeLeft,
    joinByRoomName,
    expire,
    list,
    // the host left the game or was removed: the party goes with them.
    forget(account, sendHome) {
      const party = hosted.get(account.username.toLowerCase());
      if (party) {
        end(party, sendHome);
      }
    },
    partyOf,
  };
};
