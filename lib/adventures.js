"use strict";

const {logText} = require("./logtext.js");
// adventures. the engine is in the client (quest/QuestManager): it places
// the actors named in the room file and plays them. what happens when was
// decided by scripts on the official server, which no file holds, so each
// adventure here is a script written by hand from a recording of the
// official game (tools/recorder.js): lib/adventures/<name>.js says what to
// send when the player triggers an actor, answers one, and so on.
//
// one player to an adventure, each in rooms of their own. the Meadow Arena
// (lib/arena.js) is the one for several: its messages are handed on to it.

const accounts = require("./accounts.js");
const achievements = require("./achievements.js");
const config = require("../config.js");
const dens = require("./dens.js");
const {activeAvatar} = require("./player.js");
const {MAX_LEVEL, levelXp, levelFor, xpOf, percent} = require("./questlevels.js");
const arenaModule = require("./arena.js");

const scripts = new Map([
  require("./adventures/training-grounds.js"),
  require("./adventures/return-of-the-phantoms.js"),
].map(script => [script.defId, script]));

const LIST_ADVENTURES = 201; // the adventure list's rows: script def ids
const ROOM_TYPE_QUEST = 7;
const CURRENCY_GEMS = 0;
const HEARTS = 6; // a player's health, and what a phantom's zap takes of it
const ZAP = 2;
const GIFT_DEN_ITEM = 1;
const GIFT_GEMS = 3;

module.exports = context => {
  const {enterRoom, joinRoom, tell} = context;
  const arena = arenaModule(context);
  const playing = session => (session.quest && session.room === session.quest.room ? session.quest : null);

  const tools = (session, quest) => {
    const q = {
      me: session.id,
      vars: quest.vars,
      send(cmd, ...fields) {
        if (playing(session) === quest) {
          session.sendXt(cmd, -1, ...fields);
        }
      },
      after(ms, action) {
        setTimeout(() => {
          try {
            if (playing(session) === quest) {
              action();
            }
          }
          catch (err) {
            console.error(`[adventure] ${quest.script.title}: a timed step failed: ${err.stack}`);
          }
        }, ms).unref();
      },
      // QuestManager.handleXpUpdate: [earned, total, level before, level
      // now, percent, the actor the number floats over].
      xp(amount, actor = "") {
        const avatar = activeAvatar(session.account);
        const before = xpOf(avatar);
        const level = levelFor(before);
        avatar.questXp = before + amount;
        avatar.questLevel = levelFor(avatar.questXp);
        if (amount > 0) {
          accounts.save(session.account);
        }
        q.send("quxp", amount, avatar.questXp, level, avatar.questLevel, percent(avatar.questXp), actor);
        if (avatar.questLevel > level) {
          // A new level: full health, the animal's numbers, then the level.
          quest.hearts = HEARTS;
          q.send("quhp", session.id, 100, HEARTS, HEARTS, HEARTS);
          q.send("qusu", 10, 200, 1, 200);
          q.send("qulu", session.id, avatar.questLevel);
        }
      },
      // what the player carries (an actor's name), and using it up:
      // command 7 takes it out of their hands.
      held: () => quest.held,
      use() {
        quest.held = null;
        q.send("qcmd", 7);
      },
      // goes to another of the adventure's rooms, to stand at `spawn`.
      room(key, spawn) {
        const place = quest.script.rooms[key];
        q.send("qcmd", 14, 0, spawn);
        const room = enter(session, quest.script, place);
        if (room) {
          quest.room = room;
          q.send("qmusic", place.music);
        }
      },
      // the prizes to choose from at the end: [GIFT_DEN_ITEM, def id, 0]
      // or [GIFT_GEMS, amount, amount] each (QuestManager.handlePickGift).
      offer(gifts) {
        quest.gifts = gifts;
        q.send("qpgift", gifts.length, 0, ...gifts.flat());
      },
      level: () => levelFor(xpOf(activeAvatar(session.account))),
      gems(amount) {
        const {account} = session;
        account.currency.gems = (account.currency.gems || 0) + amount;
        achievements.currencyChanged(account, "gems", amount);
        accounts.save(account);
        session.sendXt("cu", -1, CURRENCY_GEMS, account.currency.gems, 0);
      },
    };
    return q;
  };

  const run = (session, kind, key, ...args) => {
    const quest = playing(session);
    if (!quest) {
      return;
    }
    const table = quest.script.on[kind];
    // A script may answer a whole family of actors: [pattern, handler] in
    // "<kind>Like", the handler given the actor's name.
    const family = key === null ? null : (quest.script.on[`${kind}Like`] || []).find(([pattern]) => pattern.test(key));
    const handler = key === null ? table : (table || {})[key];
    if (handler) {
      handler(tools(session, quest), ...args);
    }
    else if (family) {
      family[1](tools(session, quest), key, ...args);
    }
    else if (key !== null && kind !== "pickedUp") {
      console.log(`[adventure] ${logText(quest.script.title)}: nothing written for "${logText(kind)} ${logText(key)}"`);
    }
  };

  // QuestXtCommManager.questStartResponse: [script def, players, actor
  // count, when the script was written, then for each actor its name,
  // type, def id (a name for type 16), state, visible, needs a click, path,
  // and the state of its artwork]. the room join follows it.
  const enter = (session, script, place) => enterRoom(session, `quest_${session.id}_${script.defId}_${Date.now()}__${place.room}`,
    place.room, place.name, config.shards[0].id, {roomType: ROOM_TYPE_QUEST, secondaryDefId: script.defId, nameStringId: place.nameStringId,
      joinFlags: [0, 1, 0, 1, 0]}); // a game room, and temporary

  const start = (session, script) => {
    const returnTo = session.room.name;
    session.questLobby = null;
    session.sendXt("qs", session.room.id, script.defId, 1, script.actors.length, script.written, ...script.actors.flat());
    session.sendXt("qcmd", -1, 38, script.objective);
    session.sendXt("qmusic", -1, script.rooms.start.music);
    const room = enter(session, script, script.rooms.start);
    if (!room) {
      return;
    }
    session.quest = {script, room, returnTo, vars: {}, loaded: false, held: null, hearts: HEARTS, gifts: null, gift: null};
    tools(session, session.quest).xp(0);
  };

  const handlers = {
    // QuestXtCommManager.sendQuestCreateJoinPublic: [room, script def,
    // difficulty, 0]. A refusal is [0, reason]; "NV" is "Failed to join!".
    qj(session, roomId, [, defId]) {
      if (Number(defId) === arena.ARENA_DEF) {
        arena.join(session);
        return;
      }
      const script = scripts.get(Number(defId));
      if (!script || !session.room || playing(session)) {
        session.sendXt("qj", -1, 0, "NV");
        if (!script) {
          tell(session, "That adventure is not on this server yet.");
        }
        return;
      }
      if (!script.lobby) {
        start(session, script);
        return;
      }
      // an adventure for several waits for its players: [1, 1, script
      // def, 0], then who is waiting ("qw"). the player's own Start
      // button, or the client by itself, then asks to begin ("qs").
      session.questLobby = script;
      session.sendXt("qj", session.room.id, 1, 1, script.defId, 0);
      session.sendXt("qw", session.room.id, session.id);
    },
    // QuestXtCommManager.sendQuestStartRequest: [room]
    qs(session) {
      if (session.arenaLobby) {
        arena.start(session);
        return;
      }
      if (session.questLobby && session.room && !playing(session)) {
        start(session, session.questLobby);
      }
    },
    // ... and leaving the wait
    qjx(session) {
      if (session.arenaLobby || session.arenaQueued) {
        arena.cancel(session);
        return;
      }
      session.questLobby = null;
      session.sendXt("qjx", -1, 1);
    },
    // the private lobby asks the same way: [room, script def, difficulty].
    qjc(session, roomId, params) {
      if (Number(params[1]) === arena.ARENA_DEF) {
        arena.openLobby(session);
        return;
      }
      handlers.qj(session, roomId, params);
    },
    // QuestXtCommManager.sendQuestJoinPrivate: [room, host], from a host's
    // bubble; sendQuestJoinBuddy: [room, buddy], from a buddy's card; and
    // the host's kick [player]. only the arena has private lobbies here.
    qjp(session, roomId, [, host]) {
      arena.joinPrivate(session, host);
    },
    qjf(session, roomId, [, buddy]) {
      arena.joinBuddy(session, buddy);
    },
    qjk(session, roomId, [name]) {
      arena.kick(session, name);
    },

    // "What was moved?", once the room is up: nothing is answered, and it
    // is where a script begins.
    qmi(session) {
      if (arena.playing(session)) {
        arena.loaded(session);
        return;
      }
      const quest = playing(session);
      if (quest && !quest.loaded) {
        quest.loaded = true;
        run(session, "loaded", null);
      }
    },

    // [actor, 0]: walked into, or clicked
    qat(session, roomId, [actor]) {
      run(session, "trigger", String(actor));
    },
    // [actor, ?, answer]: a talk read to its end
    qaskr(session, roomId, [actor]) {
      run(session, "answer", String(actor));
    },
    // [actor, state]: an actor's own change of mind (a phantom noticing the
    // player, giving up), which the server only passes round:
    // QuestManager.handleQuestActorRequestSeekResponse [actor, state, who].
    qas(session, roomId, [actor, state]) {
      if (playing(session) && /^-?\d+$/.test(state)) {
        session.sendXt("qas", -1, String(actor), Number(state), session.id);
      }
    },
    // QuestXtCommManager.questPickUpItem: [actor, who]. answered [1, actor,
    // who] (QuestManager.handlePickUpItem); with something in hand already
    // it is [0, actor], which has the client ask whether to drop that.
    qpup(session, roomId, [actor]) {
      const quest = playing(session);
      const name = String(actor);
      if (!quest || !quest.script.actors.some(row => row[0] === name)) {
        return;
      }
      const refill = quest.script.refills;
      if (quest.held && !(refill && refill.test(quest.held) && refill.test(name))) {
        session.sendXt("qpup", -1, 0, name, "null");
        return;
      }
      quest.held = name;
      session.sendXt("qpup", -1, 1, name, session.id);
      run(session, "pickedUp", name);
    },
    // "Yes, drop it": [x, y, the actor wanted, who]. what was held is put
    // down there ([4, actor, who, x, y, 0, 150, who, the one wanted]) and
    // the other picked up.
    qdroppup(session, roomId, [x, y, actor]) {
      const quest = playing(session);
      const name = String(actor);
      if (!quest || !quest.held || ![x, y].every(value => /^-?\d+$/.test(value)) || !quest.script.actors.some(row => row[0] === name)) {
        return;
      }
      session.sendXt("qpup", -1, 4, quest.held, session.id, Number(x), Number(y), 0, 150, session.id, name);
      quest.held = name;
      session.sendXt("qpup", -1, 1, name, session.id);
      run(session, "pickedUp", name);
    },

    // A phantom has zapped the player: [phantom, who, x, y], which goes
    // back after the player's health, [who, percent, change, hearts, of]
    // (QuestManager.handleHealthUpdate). at none the player is down ("qpd").
    qpzap(session, roomId, [phantom, , x, y]) {
      const quest = playing(session);
      if (!quest || quest.hearts <= 0 || ![x, y].every(value => /^-?\d+$/.test(value))) {
        return;
      }
      quest.hearts = Math.max(0, quest.hearts - ZAP);
      session.sendXt("quhp", -1, session.id, Math.floor(quest.hearts * 100 / HEARTS), -ZAP, quest.hearts, HEARTS);
      if (quest.hearts === 0) {
        session.sendXt("qpd", -1, session.id);
      }
      session.sendXt("qpzap", -1, String(phantom), session.id, Number(x), Number(y));
    },
    // ... and asks to get up again: [0, x, y], a place of the client's
    // choosing. [who, percent, hearts three times, x, y], then "qprr" 6.
    qprr(session, roomId, [, x, y]) {
      const quest = playing(session);
      if (!quest || quest.hearts > 0 || ![x, y].every(value => /^-?\d+$/.test(value))) {
        return;
      }
      quest.hearts = HEARTS;
      session.sendXt("qrspn", -1, session.id, 100, HEARTS, HEARTS, HEARTS, Number(x), Number(y));
      session.sendXt("qprr", -1, HEARTS);
    },

    // the prize picked from those offered: [which, ?, ?], then "done".
    qpgift(session, roomId, [index]) {
      const quest = playing(session);
      if (quest && quest.gifts && quest.gift === null && /^\d+$/.test(index) && Number(index) < quest.gifts.length) {
        quest.gift = quest.gifts[Number(index)];
      }
    },
    qpgiftdone(session) {
      const quest = playing(session);
      if (!quest || !quest.gift) {
        return;
      }
      const [kind, value] = quest.gift;
      quest.gifts = quest.gift = null;
      if (kind === GIFT_DEN_ITEM) {
        dens.giveDenItem(session.account, value);
        dens.sendDenItems(session);
      }
      else if (kind === GIFT_GEMS) {
        tools(session, quest).gems(value);
      }
      run(session, "gifted", null);
    },

    // [plant, phantom]: a chomper plant has caught one. nothing comes back.
    qpa() {},
    // [plant, phantom, x, y]: ... and eaten it
    qep(session, roomId, [plant, phantom, x, y]) {
      if (playing(session) && [x, y].every(value => /^-?\d+$/.test(value))) {
        run(session, "eaten", null, String(plant), String(phantom), Number(x), Number(y));
      }
    },
    // [actor, 0] is answered by the script when the chest is triggered
    // ("qat"); [actor, 1] is the chest opened.
    qatt(session, roomId, [actor, opened]) {
      if (opened === "1") {
        run(session, "opened", String(actor));
      }
    },

    // QuestXtCommManager.sendQuestExit. the official game goes to the
    // Adventure Base Camp; here it is back to where the player came from.
    qx(session) {
      if (arena.playing(session)) {
        arena.exit(session);
        return;
      }
      const quest = playing(session);
      if (quest) {
        session.quest = null;
        joinRoom(session, quest.returnTo);
      }
    },
  };

  return {
    handlers: {...arena.handlers, ...handlers},
    list: listId => (Number(listId) === LIST_ADVENTURES ? [...scripts.keys(), arena.ARENA_DEF] : null),
    arena,
  };
};

Object.assign(module.exports, {levelXp, MAX_LEVEL, HEARTS});
