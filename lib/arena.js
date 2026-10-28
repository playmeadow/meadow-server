"use strict";

// the Meadow Arena: two against two (or one against one) with weapons, as an adventure of
// its own (script def ARENA_DEF, lib/defpacks.js adds its row and names).
// nothing in it is new art: the room is one of the game's adventure rooms,
// the weapons are the clothing items the game already gives an attack
// (attackMediaRefId, attack, combatType), and the hearts are the
// adventures' hearts.
//
// how players come together, each with the game's own windows:
// - "Play" in the adventure list (qj): alone into the queue.
// - a private lobby (qjc), which others join from the host's bubble (qjp)
//   or a buddy's card (qjf). its host presses Play (qs) when they like:
//   with four it is a match of its own (the first two in against the next
//   two), with two a team, which goes into the queue.
// the queue makes a match of two teams, a team being two who came together
// or two who came alone.
//
// a duel is the same one against one: its own queue ("!arena duel") and
// lobbies of two ("!arena host duel"), started by the host's Play.
//
// a duel may be played for Earth Crystals (lib/crystals.js): "!arena duel
// 500" waits for someone queued for the same, "!arena host duel 500" opens
// a lobby for it: whoever joins is told the stake and asked to stay, and
// the host's Play starts it once they have. both stakes are held when it starts; the winner takes both, less
// the fee, and battle XP for what was risked. a loser who hardly played is
// written down for the staff, and between two new accounts the stakes go
// back instead.
//
// a match: everyone picks a deck of four of the weapons they own (the
// client's deck window, swf-src/Arena.as), then rounds, the first team to
// win two taking the match. a round ends when both players of a team are
// down. a weapon is played for elixir, which fills over time; what it
// costs and what it takes off depends on its attack (cardOf). a player who
// has not been hurt for a while heals.
//
// the client and the server speak "xar" both ways, the operation first:
//   client: deck d1 d2 d3 d4 | play slot x y | hit play target
//   server: team, deck, cards, spawn, count, fight, elx, play, no, round, end
// and the game's own quhp (health), qpd (down), qrspn (up again), quxp, qm
// and qp (others' swipes and shots, passed round).

const accounts = require("./accounts.js");
const crystals = require("./crystals.js");
const config = require("../config.js");
const defpacks = require("./defpacks.js");
const {logText} = require("./logtext.js");
const {activeAvatar} = require("./player.js");
const {levelFor, levelXp, arenaXpOf, arenaLevelOf, MAX_LEVEL} = require("./questlevels.js");
const weaponList = require("./arena-weapons.json");

const ARENA_DEF = 9100; // the arena's script def (lib/defpacks.js)
const ROOM_TYPE_QUEST = 7;
// a small room, for players to be near each other: the lava-red floor
// between stone walls of Greely's Inferno (adventure 5a), drawn bigger than
// rooms are (Arena.zoom in the client).
const ROOM = {room: "adventures.room_adventure_5a", name: "Meadow Arena", nameStringId: 9000020, music: "ajq_muscombat"};
const WRITTEN = "2026-10-25 12:00:00";
// the arena has no actors of its own: the start of a quest, which the
// client wants to find, and that is all.
const ACTORS = [["queststart", 18, 0, 0, 1, 1, "", ""]];
// where each team stands at the start of a round: one team on each side
// of the middle of the floor (a duel's two take the first places).
const SPAWNS = process.env.AJ_ARENA_CLOSE === "1"
  // for trying the client's aim: everyone a step apart
  ? [[[470, 480], [470, 530]], [[530, 480], [530, 530]]]
  : [[[340, 470], [380, 570]], [[640, 440], [600, 540]]];

// AJ_ARENA_FAST=1: everything quick, and no critical hits, for test/arena.js
const FAST = process.env.AJ_ARENA_FAST === "1";
const TEAM_SIZE = 2;
// hearts: the game shows one heart for every two of its health points, so
// the arena's hearts go to it doubled (HP), and a heart taken off is one
// heart gone on the screen. its hearts window has two rows of them for this
// (GuiManager.setQuestHearts).
const HEARTS = 30;
const HP = hearts => hearts * 2;
const ELIXIR_MAX = 10;
const ELIXIR_START = 7;
const ELIXIR_EVERY_MS = FAST ? 40 : 1400; // one elixir: twice Clash Royale's
const PLAY_EVERY_MS = FAST ? 0 : 350; // the least time between two plays of one player
// healing: a player heals only when out of the fight a while: unhurt,
// playing no card, and no one of the other team near
const HEAL_AFTER_MS = FAST ? 1500 : 8000; // unhurt this long
const HEAL_IDLE_MS = FAST ? 0 : 5000; // no card played this long
const HEAL_CLEAR = 350; // no one of the other team this near (room pixels)
const HEAL_EVERY_MS = FAST ? 300 : 3000; // then a heart each
const DECK_MS = FAST ? 5000 : 30000; // to choose a deck in
const COUNT_FROM = FAST ? 1 : 3; // seconds counted down before a round
const BETWEEN_MS = FAST ? 300 : 4000; // after a round, before the next is counted down
const ROUND_MS = 150000; // a round that goes on this long is decided on hearts
const END_MS = FAST ? 500 : 9000; // the result on the screen, then everyone goes back
const LOAD_MS = 15000; // a player whose room has not loaded by then is waited for no longer
const TICK_MS = FAST ? 50 : 250;
const PLAY_MS = 2500; // how long after a weapon is played its hit may be reported
const MELEE_REACH = 260; // how far apart attacker and target may be (room pixels) for a swipe ...
const RANGED_REACH = 800; // ... and a shot
const MELEE_TARGETS = 2; // a swipe can catch both of the other team
const WINS_NEEDED = 2;
const LOBBY_SIZE = 4;
const DUEL_LOBBY_SIZE = 2;

// the weapon every deck can fall back on: the game's own paw swipe for a
// player with nothing in hand (QuestManager.QUEST_WEAPON_DEFAULT_MELEE).
const PAW = 123;
// the weapons every player has, each from an arena level on
// (lib/arena-weapons.json): not what they own.
const WEAPONS = weaponList.weapons.map(weapon => ({id: Number(weapon.id), level: Number(weapon.level) || 1}));

// players further apart in arena level than this play for fun: no battle
// XP either way, and no Earth Crystals (lib/crystals.js asks too)
const LEVEL_GAP = 10;

// battle XP, given as it happens: the arena's own (account.arenaXp), not
// the adventures'. a level takes 50 times its number squared
// (lib/questlevels.js), so the first levels come in a match or two and the
// late ones in hundreds.
const XP_PER_HEART = 1; // for each heart taken off the other team
const XP_DOWN = 10; // for each of them knocked down
const XP_ROUND = 20; // to each of the team that won a round
const XP_WIN = 100; // to each of the team that won the match
const XP_LOST = 40; // taken from each of the team that lost it: never below the start of their level
const XP_PER_STAKE = 10; // the winner of a staked duel: a battle XP for every this many crystals staked
// a staked duel's loser who played fewer cards than this, or hurt no one,
// may have lost on purpose
const THROWN_PLAYS = 3;
const NEW_ACCOUNT_SECONDS = 30 * 86400; // ... and between two accounts this young, the stakes go back

const BUBBLE = 11; // UserCommXtCommManager: a custom adventure's bubble

const clamp = (value, low, high) => Math.min(high, Math.max(low, value));

// what a weapon is in the arena. attack 1 to 40 in the game's items: the
// stronger, the more elixir and the more hearts it takes off (the paw 1
// for 1, the Alpha Sword 8 for 7). a healing staff (attack below 0) heals
// its player and their teammate instead. the critical hit number of an
// item (0 to 5, 20 for the candy cane swords) is a chance of a hit taking
// off twice as much.
const cardOf = defId => {
  const def = defpacks.itemDef(defId);
  if (!def || !(Number(def.attackMediaRefId) > 0)) {
    return null;
  }
  const attack = Number(def.attack) || 0;
  const ranged = Number(def.combatType) === 1;
  if (attack < 0) {
    return {defId: Number(defId), ranged, heal: Math.max(1, Math.round(-attack / 3)), damage: 0, cost: clamp(Math.ceil(-attack / 6) + 1, 2, 7), crit: 0};
  }
  return {defId: Number(defId), ranged, heal: 0, damage: Math.max(1, Math.round(attack / 5)), cost: clamp(Math.ceil(attack / 6), 1, 7),
    crit: Math.min(25, (Number(def.criticalHit) || 0) * 3)};
};

module.exports = ({enterRoom, joinRoom, tell, findOnline, ask}) => {
  const queue = []; // [{members: [session, ...]}], the oldest first
  const matches = new Set();
  let nextMatch = 1;

  const live = session => Boolean(session && session.account && findOnline(session.account.username) === session);

  // the weapons an account may put in a deck: the arena's, up to its level.
  const ownedCards = account => WEAPONS.filter(weapon => weapon.level <= arenaLevelOf(account)).map(weapon => cardOf(weapon.id)).filter(Boolean);
  // a deck for a player who chose none, or too few: their strongest.
  const defaultDeck = (account, chosen = []) => {
    const deck = [...chosen];
    const rest = ownedCards(account).filter(card => !deck.some(other => other.defId === card.defId))
      .sort((one, other) => other.damage + other.heal - one.damage - one.heal);
    while (deck.length < 4 && rest.length) {
      deck.push(rest.shift());
    }
    while (deck.length < 4) {
      deck.push(cardOf(PAW));
    }
    return deck;
  };

  // ---- lobbies (the game's private adventure window) ----

  // a player starting something new in the arena is first taken out of
  // the lobby or queue they were in (its window closes), so nobody is left
  // stuck in one they can no longer see. false while in a match.
  const freeUp = session => {
    if (session.arenaMatch) {
      tell(session, "You're in an arena match already.");
      return false;
    }
    if (session.arenaQueued && !session.arenaQueued.lobby) {
      unqueue(session.arenaQueued);
      session.sendXt("qjx", -1, 1);
    }
    if (session.arenaLobby) {
      leaveLobby(session);
    }
    return true;
  };

  const sendWaiting = lobby => {
    for (const member of lobby.members) {
      if (member.room) {
        member.sendXt("qw", member.room.id, ...lobby.members.map(other => other.id));
      }
    }
  };

  // the bubble over the host's head, which the others in the room click
  // to join: "def,0,difficulty|on" (UserCommXtCommManager, type 11; the
  // balloon is drawn only for "on", ChatBalloon.setCustomAdventureMessage).
  // the host is sent it too: their own client shows it over them.
  const bubbleLine = () => [`${ARENA_DEF},0,0|on`, BUBBLE, 0];
  const showBubble = (to, owner) => {
    const lobby = owner.arenaLobby;
    if (lobby && lobby.host === owner && lobby.bubble && owner.room && to.room === owner.room) {
      to.sendXt("uc", owner.room.id, owner.id, ...bubbleLine(owner));
    }
  };
  const bubbleOff = host => {
    if (host.room) {
      for (const other of host.room.sessions) {
        other.sendXt("uc", host.room.id, host.id, "off", BUBBLE);
      }
    }
  };
  // the host's client asks for the bubble ("on") once its lobby is open,
  // and takes it down ("off").
  const bubble = (session, word) => {
    const lobby = session.arenaLobby;
    if (!lobby || lobby.host !== session) {
      return false;
    }
    if (word === "on" && lobby.members.length < lobby.size) {
      lobby.bubble = true;
      for (const other of session.room ? session.room.sessions : []) {
        showBubble(other, session);
      }
    }
    else if (word === "on") {
      // a full lobby's window opened again (reopen): its bubble stays down.
      // never "off" to the host for this: their game would close the window.
    }
    else {
      lobby.bubble = false;
      bubbleOff(session);
    }
    return true;
  };

  const potOf = stake => stake * 2 - Math.ceil(stake * 2 * crystals.FEE_PERCENT / 100);
  const stakeWords = stake => `${stake.toLocaleString()} Earth Crystals each. The winner takes ${potOf(stake).toLocaleString()}`;

  const openLobby = (session, duel = false, stake = 0) => {
    if (!session.room || !freeUp(session)) {
      session.sendXt("qjc", -1, 0, "NV");
      return;
    }
    const problem = stake ? crystals.stakeProblem(session, stake) : null;
    if (problem) {
      tell(session, problem);
      return;
    }
    const lobby = {host: session, members: [session], bubble: false, duel, stake, size: duel ? DUEL_LOBBY_SIZE : LOBBY_SIZE};
    session.arenaLobby = lobby;
    // [1, 1, script def, 0]: QuestManager.handleQuestJoinResponse
    // ("custSettings"), which opens the private adventure window.
    session.sendXt("qjc", session.room.id, 1, 1, ARENA_DEF, 0);
    sendWaiting(lobby);
    if (stake) {
      tell(session, `Your duel is for ${stakeWords(stake)}.`);
    }
  };

  const joinLobby = (session, cmd, host) => {
    const lobby = host && host.arenaLobby;
    if (!lobby || lobby === session.arenaLobby || lobby.members.length >= lobby.size || lobby.queued || !session.room || !freeUp(session)) {
      session.sendXt(cmd, -1, 0, lobby && lobby.members.length >= lobby.size ? "FULL" : "NV");
      return;
    }
    const problem = lobby.stake ? crystals.stakeProblem(session, lobby.stake) || crystals.pairProblem(session.account, lobby.host.account) : null;
    if (problem) {
      session.sendXt(cmd, -1, 0, "NV");
      tell(session, `This duel is for ${lobby.stake.toLocaleString()} Earth Crystals each. ${problem}`);
      return;
    }
    lobby.members.push(session);
    session.arenaLobby = lobby;
    // as qj's: [1, 1, script def, difficulty], which opens the waiting
    // window ("custParty") with the host's lobby in it.
    session.sendXt(cmd, session.room.id, 1, 1, ARENA_DEF, 0);
    sendWaiting(lobby);
    if (lobby.members.length >= lobby.size && lobby.bubble && lobby.host.room) {
      // full: the bubble goes for the others. not for the host: their game
      // takes its own bubble's "off" to mean the lobby is over, and closes
      // the lobby window.
      lobby.bubble = false;
      for (const other of lobby.host.room.sessions) {
        if (other !== lobby.host) {
          other.sendXt("uc", lobby.host.room.id, lobby.host.id, "off", BUBBLE);
        }
      }
    }
    if (lobby.stake) {
      askStake(lobby, session);
    }
    else {
      tell(lobby.host, `${session.account.username} joined your arena lobby. Press Play when you're ready.`);
    }
  };

  // whoever joins a staked duel is told the stake and asked to stay in it:
  // yes, and the host may start it; no, and they are out of the lobby.
  const askStake = (lobby, session) => {
    session.arenaAccepted = false;
    ask(session, `This duel is for ${stakeWords(lobby.stake)}. Stay in ${lobby.host.account.username}'s duel?`, () => {
      if (session.arenaLobby !== lobby) {
        return;
      }
      session.arenaAccepted = true;
      tell(session, `You're in. ${lobby.host.account.username} starts the duel.`);
      tell(lobby.host, `${session.account.username} accepted the ${lobby.stake.toLocaleString()} Earth Crystal stake. Press Play to start.`);
    }, () => {
      if (session.arenaLobby === lobby) {
        leaveLobby(session);
        tell(lobby.host, `${session.account.username} didn't want to duel for ${lobby.stake.toLocaleString()} Earth Crystals.`);
      }
    });
  };

  // the match of a lobby whose host pressed Play. a staked duel's stakes
  // are asked for again: either may have spent their crystals meanwhile.
  // the host's lobby window closes with its bubble's "off".
  const launch = lobby => {
    const {host} = lobby;
    const members = lobby.members.filter(live);
    if (lobby.stake) {
      const problem = crystals.stakeProblem(host, lobby.stake) || crystals.stakeProblem(members[1], lobby.stake)
        || crystals.pairProblem(host.account, members[1].account);
      if (problem) {
        tell(host, `The duel can't start. ${problem}`);
        tell(members[1], `The duel can't start. ${problem}`);
        reopen(lobby);
        return;
      }
    }
    for (const member of members) {
      member.arenaLobby = null;
    }
    lobby.bubble = false;
    bubbleOff(host);
    startMatch(lobby.duel ? members.map(member => [member]) : [members.slice(0, TEAM_SIZE), members.slice(TEAM_SIZE)], lobby.stake);
  };

  // the host's lobby window again (the game closes it at Play, whatever
  // comes of it): as at qjc, and who is in it
  const reopen = lobby => {
    if (lobby.host.room) {
      lobby.host.sendXt("qjc", lobby.host.room.id, 1, 1, ARENA_DEF, 0);
      sendWaiting(lobby);
    }
  };

  // someone out of a lobby: they leave it, or are kicked, or it ends.
  const leaveLobby = (session, told = true) => {
    const lobby = session.arenaLobby;
    if (!lobby) {
      return;
    }
    if (lobby.queued) {
      unqueue(lobby.entry);
    }
    if (lobby.host === session) {
      if (lobby.bubble) {
        bubble(session, "off");
      }
      for (const member of lobby.members) {
        member.arenaLobby = null;
        if (member !== session || told) {
          member.sendXt("qjx", -1, 1);
        }
      }
      return;
    }
    lobby.members = lobby.members.filter(member => member !== session);
    session.arenaLobby = null;
    if (told) {
      session.sendXt("qjx", -1, 1);
    }
    sendWaiting(lobby);
  };

  // ---- the queue ----

  const unqueue = entry => {
    const at = queue.indexOf(entry);
    if (at !== -1) {
      queue.splice(at, 1);
    }
    for (const member of entry.members) {
      member.arenaQueued = null;
    }
    if (entry.lobby) {
      entry.lobby.queued = false;
      entry.lobby.entry = null;
    }
  };

  const enqueue = (members, lobby = null, duel = false, stake = 0) => {
    const entry = {members, lobby, duel, stake, since: Date.now()};
    for (const member of members) {
      member.arenaQueued = entry;
    }
    if (lobby) {
      lobby.queued = true;
      lobby.entry = entry;
    }
    queue.push(entry);
    matchmake();
  };

  // two teams out of the queue, oldest first: a team that came together,
  // or two who came alone. duels: the two who have waited longest.
  const matchmake = () => {
    // duels: two queued for the same stake who may play each other for it
    for (;;) {
      const waiting = queue.filter(entry => entry.duel);
      let pair = null;
      for (const [at, one] of waiting.entries()) {
        const other = waiting.slice(at + 1).find(entry => entry.stake === one.stake
          && (!one.stake || !crystals.pairProblem(one.members[0].account, entry.members[0].account)));
        if (other) {
          pair = [one, other];
          break;
        }
      }
      if (!pair) {
        break;
      }
      pair.forEach(unqueue);
      startMatch(pair.map(entry => entry.members), pair[0].stake);
    }
    for (;;) {
      const teams = [];
      const used = [];
      const pool = queue.filter(entry => !entry.duel);
      const solos = pool.filter(entry => entry.members.length === 1);
      for (const entry of pool) {
        if (teams.length === 2 || used.includes(entry)) {
          continue;
        }
        if (entry.members.length === TEAM_SIZE) {
          teams.push(entry.members);
          used.push(entry);
        }
        else {
          const partner = solos.find(other => other !== entry && !used.includes(other));
          if (partner) {
            teams.push([...entry.members, ...partner.members]);
            used.push(entry, partner);
          }
        }
      }
      if (teams.length < 2) {
        return;
      }
      for (const entry of used) {
        unqueue(entry);
        if (entry.lobby) {
          for (const member of entry.lobby.members) {
            member.arenaLobby = null;
          }
          if (entry.lobby.bubble) {
            bubble(entry.lobby.host, "off");
          }
        }
      }
      startMatch(teams);
    }
  };

  // ---- a match ----

  const roomName = match => `quest_arena_${match.id}__${ROOM.room}`;
  const everyone = match => match.players.filter(player => live(player.session) && player.session.arenaMatch === match);
  const toAll = (match, cmd, ...fields) => {
    for (const player of everyone(match)) {
      player.session.sendXt(cmd, -1, ...fields);
    }
  };
  const say = (player, ...fields) => {
    if (live(player.session) && player.session.arenaMatch === player.match) {
      player.session.sendXt("xar", -1, ...fields);
    }
  };
  const sayAll = (match, ...fields) => toAll(match, "xar", ...fields);
  // everyone's arena level, for the score bar: [id, level for each]
  const sayLevels = match => sayAll(match, "levels", ...match.players.flatMap(player => [player.session.id, arenaLevelOf(player.session.account)]));

  // battle XP, the arena's own; none in a match of players too far apart.
  // the arena (swf-src/Arena.as) is told the new level when it changes.
  const awardXp = (player, amount) => {
    const {session} = player;
    if (!live(session) || amount <= 0 || player.match.forFun) {
      return;
    }
    const level = arenaLevelOf(session.account);
    session.account.arenaXp = arenaXpOf(session.account) + amount;
    accounts.save(session.account);
    player.xp += amount;
    if (arenaLevelOf(session.account) > level) {
      say(player, "level", arenaLevelOf(session.account), 1);
      sayLevels(player.match);
    }
  };

  // battle XP lost: as much of `amount` as the account has above the start
  // of its arena level, so a loss never takes a level away.
  const takeXp = (player, amount) => {
    const {session} = player;
    if (!live(session) || player.match.forFun) {
      return;
    }
    const before = arenaXpOf(session.account);
    const taken = Math.min(amount, before - levelXp(arenaLevelOf(session.account) - 1));
    if (taken <= 0) {
      return;
    }
    session.account.arenaXp = before - taken;
    accounts.save(session.account);
    player.xp -= taken;
  };

  // [who, percent]: the start of the game's health messages
  const health = player => [player.session.id, Math.floor(player.hearts * 100 / HEARTS)];
  const toldHealth = (match, player, change) => toAll(match, "quhp", ...health(player), HP(change), HP(player.hearts), HP(HEARTS));

  const startMatch = (teams, stake = 0) => {
    const match = {id: nextMatch++, state: "loading", round: 0, score: [0, 0], players: [], started: Date.now(), stateAt: Date.now(), plays: new Map(), nextPlay: 1,
      stake, game: stake ? crystals.newGame("duel") : null, settled: !stake};
    // players too far apart in arena level play for fun (no battle XP)
    const levels = teams.flat().map(session => arenaLevelOf(session.account));
    match.forFun = Math.max(...levels) - Math.min(...levels) > LEVEL_GAP;
    if (stake && !crystals.hold(match.game, teams.flat().map(session => session.account), stake)) {
      for (const session of teams.flat()) {
        tell(session, "The duel didn't start: one of you no longer has the Earth Crystals for it.");
      }
      return;
    }
    teams.forEach((members, team) => members.forEach((session, slot) => {
      match.players.push({session, team, slot, match, loaded: false, deck: null, hearts: HEARTS, elixir: ELIXIR_START, hurtAt: 0, healedAt: 0,
        down: false, gone: false, xp: 0, crystals: 0, plays: 0, damage: 0, returnTo: session.room ? session.room.name : null});
    }));
    matches.add(match);
    console.log(`[arena] match ${match.id}: ${teams.map(members => members.map(session => logText(session.account.username)).join(" + ")).join(" against ")}`);
    for (const player of match.players) {
      const {session} = player;
      session.arenaMatch = match;
      session.arenaLobby = null;
      session.arenaQueued = null;
      // QuestXtCommManager.questStartResponse, then the room
      session.sendXt("qs", session.room ? session.room.id : -1, ARENA_DEF, match.players.length, ACTORS.length, WRITTEN, ...ACTORS.flat());
      session.sendXt("qmusic", -1, ROOM.music);
      enterRoom(session, roomName(match), ROOM.room, ROOM.name, config.shards[0].id,
        {roomType: ROOM_TYPE_QUEST, secondaryDefId: ARENA_DEF, nameStringId: ROOM.nameStringId, joinFlags: [0, 1, 0, 1, 0]});
    }
    // who is on which team: [my team, then each player's id, team and name]
    for (const player of match.players) {
      say(player, "team", player.team, ...match.players.flatMap(other => [other.session.id, other.team, other.session.account.username]));
      if (stake) {
        say(player, "stake", stake);
      }
      // [arena level, 0], and whether this match gives battle XP
      say(player, "level", arenaLevelOf(player.session.account), 0, match.forFun ? 1 : 0);
    }
    sayLevels(match);
    match.timer = setInterval(() => {
      try {
        tick(match);
      }
      catch (err) {
        console.error(`[arena] match ${match.id}: ${err.stack}`);
      }
    }, TICK_MS);
    match.timer.unref();
  };

  const spawnAt = player => SPAWNS[player.team][player.slot];

  // the deck window: how long, then each weapon the player may choose,
  // [def, cost, damage, heal, ranged].
  const openDecks = match => {
    match.state = "deck";
    match.stateAt = Date.now();
    for (const player of match.players) {
      const cards = ownedCards(player.session.account);
      say(player, "deck", Math.round(DECK_MS / 1000), cards.length, ...cards.flatMap(card => [card.defId, card.cost, card.damage, card.heal, card.ranged ? 1 : 0]));
    }
  };

  const setDeck = (player, defIds) => {
    if (player.match.state !== "deck" || player.deck) {
      return;
    }
    const owned = ownedCards(player.session.account);
    const chosen = [];
    for (const defId of defIds.map(Number)) {
      const card = owned.find(one => one.defId === defId);
      if (card && !chosen.includes(card) && chosen.length < 4) {
        chosen.push(card);
      }
    }
    player.deck = defaultDeck(player.session.account, chosen);
    sendCards(player);
    if (player.match.players.every(other => other.deck || other.gone)) {
      startRound(player.match);
    }
  };

  // the deck as it will be played: [def, cost, damage, heal, ranged] a card.
  const sendCards = player => say(player, "cards", ...player.deck.flatMap(card => [card.defId, card.cost, card.damage, card.heal, card.ranged ? 1 : 0]));

  const startRound = match => {
    for (const player of match.players) {
      if (!player.deck) {
        player.deck = defaultDeck(player.session.account);
        sendCards(player);
      }
    }
    match.round++;
    match.plays.clear();
    for (const player of match.players) {
      if (player.gone) {
        continue;
      }
      player.hearts = HEARTS;
      player.elixir = ELIXIR_START;
      player.down = false;
      player.hurtAt = 0;
      player.sentElixir = null;
      const [x, y] = spawnAt(player);
      // [who, percent, hearts three times, x, y]: up again, where it says
      toAll(match, "qrspn", player.session.id, 100, HP(HEARTS), HP(HEARTS), HP(HEARTS), x, y);
      say(player, "spawn", x, y);
    }
    match.state = "count";
    match.stateAt = Date.now();
    match.counted = null;
    sayAll(match, "round", match.round, ...match.score, -1);
  };

  const teamDown = (match, team) => match.players.filter(player => player.team === team).every(player => player.down || player.gone);

  const endRound = (match, winner) => {
    match.state = "between";
    match.stateAt = Date.now();
    if (winner >= 0) {
      match.score[winner]++;
      for (const player of match.players.filter(one => one.team === winner)) {
        awardXp(player, XP_ROUND);
      }
    }
    sayAll(match, "round", match.round, ...match.score, winner);
    if (winner >= 0 && match.score[winner] >= WINS_NEEDED) {
      endMatch(match, winner);
    }
  };

  const endMatch = (match, winner) => {
    if (match.state === "over") {
      return;
    }
    match.state = "over";
    match.stateAt = Date.now();
    for (const player of match.players) {
      if (player.team === winner) {
        awardXp(player, XP_WIN);
      }
      else {
        takeXp(player, XP_LOST);
      }
      if (!player.gone) {
        crystals.finishedMatch(player.session.account);
      }
    }
    if (match.stake) {
      settleStakes(match, winner);
    }
    for (const player of match.players) {
      say(player, "end", winner, ...match.score, player.xp, player.crystals);
    }
    console.log(`[arena] match ${match.id}: team ${winner + 1} won, ${match.score.join(" to ")}`);
  };

  // a staked duel's end: the winner takes the stakes, or, if the loser
  // hardly played and both accounts are new, both get theirs back.
  const settleStakes = (match, winner) => {
    if (match.settled) {
      return;
    }
    match.settled = true;
    const won = match.players.find(player => player.team === winner);
    const lost = match.players.find(player => player.team !== winner);
    const thrown = lost.plays < THROWN_PLAYS || lost.damage === 0;
    const young = account => Date.now() / 1000 - account.createdAt < NEW_ACCOUNT_SECONDS;
    const names = [won.session.account.username, lost.session.account.username];
    if (thrown && young(won.session.account) && young(lost.session.account)) {
      crystals.refund(match.game, [won.session.account, lost.session.account], "the loser hardly played: stakes back");
      crystals.flag(match.game, names, `refunded: ${lost.session.account.username} played ${lost.plays} cards for ${lost.damage} damage`);
      for (const player of [won, lost]) {
        tell(player.session, "The duel's Earth Crystals went back to both of you: it didn't look like a real duel.");
      }
      return;
    }
    const got = crystals.settle(match.game, won.session.account, lost.session.account, match.stake);
    won.crystals = got - match.stake;
    lost.crystals = -match.stake;
    awardXp(won, Math.floor(match.stake / XP_PER_STAKE));
    if (thrown && !lost.gone) {
      crystals.flag(match.game, names, `${lost.session.account.username} lost having played ${lost.plays} cards for ${lost.damage} damage`);
    }
    console.log(`[arena] match ${match.id}: ${logText(names[0])} won ${match.stake} Earth Crystals from ${logText(names[1])}`);
  };

  const closeMatch = match => {
    clearInterval(match.timer);
    matches.delete(match);
    for (const player of match.players) {
      const {session} = player;
      if (live(session) && session.arenaMatch === match) {
        session.arenaMatch = null;
        if (session.room && session.room.name === roomName(match)) {
          joinRoom(session, player.returnTo || `${config.startupRoom}#${config.shards[0].id}`);
        }
      }
    }
  };

  const tick = match => {
    const now = Date.now();
    const since = now - match.stateAt;
    if (match.state === "loading") {
      if (match.players.every(player => player.loaded || player.gone) || since >= LOAD_MS) {
        openDecks(match);
      }
      return;
    }
    if (match.state === "deck") {
      if (since >= DECK_MS) {
        startRound(match);
      }
      return;
    }
    if (match.state === "count") {
      const left = COUNT_FROM - Math.floor(since / 1000);
      if (left > 0 && match.counted !== left) {
        match.counted = left;
        sayAll(match, "count", left);
      }
      if (left <= 0) {
        match.state = "fight";
        match.stateAt = now;
        for (const player of match.players) {
          player.elixirAt = now;
          player.hurtAt = now;
        }
        sayAll(match, "fight", Math.round(ROUND_MS / 1000));
      }
      return;
    }
    if (match.state === "between") {
      if (since >= BETWEEN_MS) {
        startRound(match);
      }
      return;
    }
    if (match.state === "over") {
      if (since >= END_MS) {
        closeMatch(match);
      }
      return;
    }
    // the fight
    for (const player of match.players) {
      if (player.gone || player.down) {
        continue;
      }
      // elixir fills
      if (player.elixir < ELIXIR_MAX) {
        player.elixir = Math.min(ELIXIR_MAX, player.elixir + (now - player.elixirAt) / ELIXIR_EVERY_MS);
      }
      player.elixirAt = now;
      const tenths = Math.floor(player.elixir * 10);
      if (tenths !== player.sentElixir) {
        player.sentElixir = tenths;
        say(player, "elx", tenths);
      }
      // and one out of the fight heals: unhurt and playing nothing a
      // while, with no one of the other team near
      const clear = !match.players.some(other => other.team !== player.team && !other.down && !other.gone
        && distance(player.session, other.session) < HEAL_CLEAR && player.session.pos && other.session.pos);
      if (player.hearts < HEARTS && clear && now - player.hurtAt >= HEAL_AFTER_MS && now - (player.playedAt || 0) >= HEAL_IDLE_MS
        && now - player.healedAt >= HEAL_EVERY_MS) {
        player.healedAt = now;
        player.hearts++;
        toldHealth(match, player, 1);
      }
    }
    for (const [id, play] of match.plays) {
      if (now - play.at > PLAY_MS) {
        match.plays.delete(id);
      }
    }
    if (since >= ROUND_MS) {
      // the round decided on the hearts left, or no one wins it
      const left = [0, 1].map(team => match.players.filter(player => player.team === team && !player.gone).reduce((sum, player) => sum + player.hearts, 0));
      endRound(match, left[0] === left[1] ? -1 : left[0] > left[1] ? 0 : 1);
    }
  };

  const playerOf = session => {
    const match = session.arenaMatch;
    return match ? match.players.find(player => player.session === session) || null : null;
  };

  // a weapon played: [slot, x, y]. it costs its elixir now; what it hits is
  // told afterwards ("hit"), by the play's number.
  const play = (player, [slot, x, y]) => {
    const {match} = player;
    const card = player.deck && player.deck[Number(slot)];
    if (match.state !== "fight" || player.down || player.gone || !card || ![x, y].every(value => /^-?\d{1,5}$/.test(value))) {
      say(player, "no", Number(slot) || 0, Math.floor(player.elixir * 10));
      return;
    }
    // too soon after the last (a client sending plays as fast as it can)
    if (player.elixir < card.cost || Date.now() - (player.playedAt || 0) < PLAY_EVERY_MS) {
      say(player, "no", Number(slot), Math.floor(player.elixir * 10));
      return;
    }
    player.elixir -= card.cost;
    player.plays++;
    player.playedAt = Date.now();
    player.sentElixir = Math.floor(player.elixir * 10);
    const id = match.nextPlay++;
    match.plays.set(id, {id, player, card, at: Date.now(), hit: new Set()});
    say(player, "play", id, Number(slot), card.defId, player.sentElixir);
    // a healing staff heals at once: its player and their teammate.
    if (card.heal > 0) {
      for (const friend of match.players.filter(one => one.team === player.team && !one.down && !one.gone)) {
        const healed = Math.min(card.heal, HEARTS - friend.hearts);
        if (healed > 0) {
          friend.hearts += healed;
          toldHealth(match, friend, healed);
        }
      }
    }
  };

  // down until the next round: the others see the animal fall (qpd). the
  // player themselves is told by the arena ("down"): the game's own qpd
  // would put up the adventures' "the Phantoms have put you in a deep
  // sleep" and wait for its Continue.
  const knockedOut = (match, player) => {
    for (const other of everyone(match)) {
      if (other !== player) {
        other.session.sendXt("qpd", -1, player.session.id);
      }
    }
    say(player, "down");
  };

  const distance = (one, other) => {
    if (!one.pos || !other.pos) {
      return 0; // not known: not held against the hit
    }
    return Math.hypot(Number(one.pos.x) - Number(other.pos.x), Number(one.pos.y) - Number(other.pos.y));
  };

  // [play, target]: the client saw its swipe or shot reach someone.
  const hit = (player, [playId, targetId]) => {
    const {match} = player;
    const play = match.plays.get(Number(playId));
    const target = match.players.find(one => one.session.id === Number(targetId));
    if (match.state !== "fight" || !play || play.player !== player || !play.card.damage || !target || target.team === player.team
      || target.down || target.gone || play.hit.has(target) || play.hit.size >= (play.card.ranged ? 1 : MELEE_TARGETS)
      || Date.now() - play.at > PLAY_MS || distance(player.session, target.session) > (play.card.ranged ? RANGED_REACH : MELEE_REACH)) {
      return;
    }
    play.hit.add(target);
    const critical = !FAST && Math.random() * 100 < play.card.crit; // none in the tests: their numbers are known
    const damage = Math.min(target.hearts, play.card.damage * (critical ? 2 : 1));
    target.hearts -= damage;
    player.damage += damage;
    target.hurtAt = Date.now();
    toldHealth(match, target, -damage);
    awardXp(player, damage * XP_PER_HEART);
    if (critical) {
      sayAll(match, "crit", target.session.id);
    }
    if (target.hearts <= 0) {
      target.down = true;
      knockedOut(match, target);
      awardXp(player, XP_DOWN);
      if (teamDown(match, target.team)) {
        endRound(match, player.team);
      }
    }
  };

  // a player out of the match: gone from its room, or from the game. a
  // team with no one left loses; a match with no one left is over.
  const leftMatch = session => {
    const match = session.arenaMatch;
    const player = playerOf(session);
    session.arenaMatch = null;
    if (!match || !player || player.gone) {
      return;
    }
    player.gone = true;
    player.down = true;
    knockedOut(match, player);
    sayAll(match, "gone", session.id);
    if (match.players.every(one => one.gone)) {
      clearInterval(match.timer);
      matches.delete(match);
      if (!match.settled) {
        match.settled = true;
        crystals.refund(match.game, match.players.map(one => one.session.account), "everyone left");
      }
      return;
    }
    if (match.state === "over") {
      return;
    }
    const team = player.team;
    if (match.players.filter(one => one.team === team).every(one => one.gone)) {
      endMatch(match, 1 - team);
    }
    else if (match.state === "deck" && match.players.every(one => one.deck || one.gone)) {
      startRound(match);
    }
    else if (match.state === "fight" && teamDown(match, team)) {
      endRound(match, 1 - team);
    }
  };

  const handlers = {
    // the client's own arena messages: "xar" [operation, ...]
    xar(session, roomId, [operation, ...fields]) {
      const player = playerOf(session);
      if (!player || player.gone || !session.room || session.room.name !== roomName(player.match)) {
        return;
      }
      if (operation === "deck") {
        setDeck(player, fields.slice(0, 4).filter(field => /^\d{1,6}$/.test(field)));
      }
      else if (operation === "play") {
        play(player, fields);
      }
      else if (operation === "hit" && fields.every(field => /^\d{1,9}$/.test(field))) {
        hit(player, fields);
      }
    },
    // a swipe ("qm") and a shot ("qp") the client shows its own player
    // making: [weapon, x, y, actor, who, colour]. the others see it too.
    qm(session, roomId, fields) {
      passOn(session, "qm", fields);
    },
    qp(session, roomId, fields) {
      passOn(session, "qp", fields);
    },
  };

  const passOn = (session, cmd, [weapon, x, y, , , colour]) => {
    const match = session.arenaMatch;
    if (!match || !session.room || session.room.name !== roomName(match) || ![weapon, x, y, colour].every(value => /^-?\d{1,10}$/.test(value))) {
      return;
    }
    for (const other of session.room.sessions) {
      if (other !== session) {
        other.sendXt(cmd, -1, Number(weapon), Number(x), Number(y), "", session.id, Number(colour));
      }
    }
  };

  return {
    ARENA_DEF,
    handlers,
    // adventures.js hands these on for the arena's script
    join(session, duel = false, stake = 0) {
      if (!session.room || !freeUp(session)) {
        session.sendXt("qj", -1, 0, "NV");
        return;
      }
      const problem = stake ? crystals.stakeProblem(session, stake) : null;
      if (problem) {
        tell(session, problem);
        return;
      }
      session.sendXt("qj", session.room.id, 1, 1, ARENA_DEF, 0);
      session.sendXt("qw", session.room.id, session.id);
      if (duel) {
        tell(session, stake ? `You are in the queue for a duel for ${stakeWords(stake)}.` : "You are in the queue for a duel, one against one.");
      }
      enqueue([session], null, duel, stake);
    },
    openLobby,
    // QuestXtCommManager.sendQuestJoinPrivate: [room, host]: from the
    // host's bubble, in the same room.
    joinPrivate(session, hostName) {
      const host = findOnline(String(hostName));
      joinLobby(session, "qjp", host && host.room === session.room ? host : null);
    },
    // ... sendQuestJoinBuddy: [room, buddy], from their card, anywhere:
    // into the lobby the buddy is in.
    joinBuddy(session, buddyName) {
      const buddy = findOnline(String(buddyName));
      joinLobby(session, "qjf", buddy && buddy.arenaLobby ? buddy.arenaLobby.host : null);
    },
    kick(session, name) {
      const lobby = session.arenaLobby;
      const member = lobby && lobby.host === session ? lobby.members.find(one => one !== session && one.account.username.toLowerCase() === String(name).toLowerCase()) : null;
      if (member) {
        leaveLobby(member);
        tell(member, "The host of the arena lobby took you out of it.");
      }
    },
    // Play in the private window
    start(session) {
      const lobby = session.arenaLobby;
      if (!lobby || lobby.host !== session || lobby.queued) {
        return;
      }
      const members = lobby.members.filter(live);
      if (members.length === lobby.size && lobby.stake && !members[1].arenaAccepted) {
        tell(session, `${members[1].account.username} hasn't accepted the stake yet.`);
        reopen(lobby);
      }
      else if (members.length === lobby.size) {
        launch(lobby);
      }
      else if (!lobby.duel && members.length === TEAM_SIZE) {
        for (const member of members) {
          tell(member, "Your team is looking for another team to play.");
        }
        enqueue(members, lobby);
      }
      else {
        tell(session, lobby.duel ? "A duel needs one more player in your lobby."
          : "The arena needs four in your lobby for a match of your own, or two to look for another team.");
        reopen(lobby);
      }
    },
    cancel(session) {
      if (session.arenaQueued && !session.arenaQueued.lobby) {
        unqueue(session.arenaQueued);
        session.sendXt("qjx", -1, 1);
      }
      else {
        leaveLobby(session);
      }
    },
    playing: session => Boolean(session.arenaMatch),
    // may this position update ("au") stand? in the arena's room: walking
    // only while fighting and up; a jump ("teleport", a right click) only to
    // where the round puts the player. a refused one is not passed on.
    allowMove(session, coords, teleport) {
      const match = session.arenaMatch;
      if (!match || !session.room || session.room.name !== roomName(match)) {
        return true;
      }
      const player = playerOf(session);
      // the first, as the room loads: where the game put them
      if (!player || !session.pos) {
        return true;
      }
      const [x, y] = coords.slice(-2);
      if (teleport) {
        const [sx, sy] = spawnAt(player);
        return Math.hypot(x - sx, y - sy) <= 12;
      }
      return match.state === "fight" && !player.down && !player.gone;
    },
    // "!arena leave": out of any lobby or queue
    leave(session) {
      const was = Boolean(session.arenaLobby || session.arenaQueued);
      if (freeUp(session)) {
        tell(session, was ? "You left the arena lobby." : "You weren't in an arena lobby or queue.");
      }
    },
    loaded(session) {
      const player = playerOf(session);
      if (player) {
        player.loaded = true;
        const [x, y] = spawnAt(player);
        say(player, "spawn", x, y);
      }
    },
    exit(session) {
      const match = session.arenaMatch;
      const player = playerOf(session);
      leftMatch(session);
      if (match && player) {
        joinRoom(session, player.returnTo || `${config.startupRoom}#${config.shards[0].id}`);
      }
    },
    bubble,
    showBubble,
    // world.js: a player has left a room (for another, or the game)
    roomLeft(session, room) {
      if (session.arenaMatch && room && room.name === roomName(session.arenaMatch)) {
        leftMatch(session);
      }
      if (session.arenaLobby && session.arenaLobby.host === session && session.arenaLobby.bubble && room) {
        for (const other of room.sessions) {
          other.sendXt("uc", room.id, session.id, "off", BUBBLE);
        }
      }
    },
    // ... and the game
    loggedOut(session) {
      if (session.arenaQueued) {
        const entry = session.arenaQueued;
        unqueue(entry);
        for (const member of entry.members.filter(one => one !== session)) {
          tell(member, "Your teammate left, so your team is out of the arena queue.");
        }
      }
      leaveLobby(session, false);
      leftMatch(session);
    },
    // for the tests
    cardOf,
  };
};

Object.assign(module.exports, {ARENA_DEF, cardOf, HEARTS});
