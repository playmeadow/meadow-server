"use strict";

// the eight games two buddies play against each other from a player's card
// (client side: game.pVP_*). each has a protocol of its own, which the
// official server spoke and nothing else records; what is here was read off
// each game's `message` method and the code inside its scene file (the
// "theGame" layer of roomDefs/pvp_*/room_main).
//
// half of them the server referees, since the clients only draw what they
// are told: Tic Tac Toe, Four Gems, Rock Paper Scissors, the Shell Game and
// Pairs. the other half run on both clients at once, each simulating the
// same thing from the same inputs, and the server only passes the inputs
// across and says when both are ready to go on: Bowling, Marbles, Scooped.
//
// A game here is given `match`: {ids: [sfsUserId, sfsUserId] in the order
// of the start message, send(player, ...fields), broadcast(...fields),
// over()} and keeps what it likes on `match.state`. `player` is 0 or 1.
// every handler is entered with words that came from a client, so each
// checks what it is given; a message that makes no sense is dropped.

const other = player => 1 - player;
const coin = () => (Math.random() < 0.5 ? 0 : 1);
const whole = (text, min, max) => {
  const value = /^-?\d{1,9}$/.test(String(text)) ? Number(text) : NaN;
  return Number.isInteger(value) && value >= min && value <= max ? value : null;
};
const number = text => {
  const value = /^-?\d{1,7}(\.\d{1,20})?(e-?\d{1,3})?$/i.test(String(text)) ? Number(text) : NaN;
  return Number.isFinite(value) ? value : null;
};
const ROUNDS_TO_WIN = 2; // Rock Paper Scissors and the Shell Game: first to win two rounds

// is there a run of `length` of `player`'s marks through (x, y)? `at(x, y)`
// gives who holds a cell, undefined off the board.
const DIRECTIONS = [[1, 0], [0, 1], [1, 1], [1, -1]];
const hasLine = (at, x, y, player, length) => DIRECTIONS.some(([dx, dy]) => {
  let run = 1;
  for (const sign of [1, -1]) {
    for (let step = 1; at(x + sign * step * dx, y + sign * step * dy) === player; step++) {
      run++;
    }
  }
  return run >= length;
});

// tic Tac Toe and Four Gems share their messages: "round" [whose turn, the
// two players] opens, a "mark" is answered to both with [who, where..., won,
// tied, whose turn next], and "invalid" [whose turn] hands the turn on
// after a move that cannot be made or a turn that ran out of time. the
// first player of the start message plays X.
const boardGame = ({width, height, connect, cellOf}) => ({
  ready(match) {
    match.state = {cells: new Map(), turn: coin()};
    match.broadcast("round", match.state.turn, ...match.ids);
  },
  messages: {
    mark(match, player, params) {
      const {state} = match;
      const at = (x, y) => state.cells.get(`${x},${y}`);
      const cell = state && player === state.turn ? cellOf(params, at) : null;
      if (!state) {
        return;
      }
      if (!cell || cell.x < 0 || cell.x >= width || cell.y < 0 || cell.y >= height || at(cell.x, cell.y) !== undefined) {
        match.send(player, "invalid", state.turn);
        return;
      }
      state.cells.set(`${cell.x},${cell.y}`, player);
      const won = hasLine(at, cell.x, cell.y, player, connect);
      const tied = !won && state.cells.size === width * height;
      state.turn = won || tied ? state.turn : other(player);
      match.broadcast("mark", player, ...cell.sent, won ? 1 : 0, tied ? 1 : 0, state.turn);
      if (won || tied) {
        match.over();
      }
    },
    time(match, player) {
      const {state} = match;
      if (state && player === state.turn) {
        state.turn = other(player);
        match.broadcast("invalid", state.turn);
      }
    },
  },
});

const ticTacToe = boardGame({
  width: 3, height: 3, connect: 3,
  // [x, y], each 0 to 2 (the scene's cells are p<x>_<y>)
  cellOf([x, y]) {
    const cell = {x: whole(x, 0, 2), y: whole(y, 0, 2)};
    return cell.x === null || cell.y === null ? null : {...cell, sent: [cell.x, cell.y]};
  },
});

const fourGems = boardGame({
  width: 7, height: 6, connect: 4,
  // [column], 0 to 6; the gem drops to the lowest free row
  cellOf([column], at) {
    const x = whole(column, 0, 6);
    if (x === null) {
      return null;
    }
    let y = 0;
    while (y < 6 && at(x, y) !== undefined) {
      y++;
    }
    return {x, y, sent: [x]};
  },
});

// Rock Paper Scissors and the Shell Game: no turns. "round" starts the
// clock on both clients; when it runs out each says "time" with what its
// player picked, and both are told "mark" [first player's pick, second
// player's pick, then "1", winner when the game is over, or "0", "1",
// winner when only the round is won, or "0", "0" for a round nobody won].
// both clients ask for the next round by saying "ready" again.
const pickGame = ({startRound, read, roundWinner}) => ({
  ready(match) {
    match.state = match.state || {wins: [0, 0]};
    match.state.picks = [undefined, undefined];
    match.state.round = startRound();
    match.broadcast("round", ...match.ids, ...match.state.round.sent);
  },
  messages: {
    time(match, player, params) {
      const {state} = match;
      if (!state || state.picks[player] !== undefined) {
        return;
      }
      state.picks[player] = read(params[0]);
      if (state.picks[other(player)] === undefined) {
        return;
      }
      const winner = roundWinner(state.picks, state.round);
      if (winner === null) {
        match.broadcast("mark", ...state.picks, 0, 0);
        return;
      }
      state.wins[winner]++;
      if (state.wins[winner] >= ROUNDS_TO_WIN) {
        match.broadcast("mark", ...state.picks, 1, winner);
        match.over();
      }
      else {
        match.broadcast("mark", ...state.picks, 0, 1, winner);
      }
    },
  },
});

const HANDS = ["rock", "paper", "scissors"]; // each beats the one before it
const NO_HAND = "off"; // nothing picked in time
const rockPaperScissors = pickGame({
  startRound: () => ({sent: []}),
  read: hand => (HANDS.includes(hand) ? hand : NO_HAND),
  roundWinner([first, second]) {
    if (first === second) {
      return null;
    }
    if (first === NO_HAND || second === NO_HAND) {
      return first === NO_HAND ? 1 : 0;
    }
    return (HANDS.indexOf(first) - HANDS.indexOf(second) + 3) % 3 === 1 ? 0 : 1;
  },
});

// the round opens with which of the three shells hides the gem; a pick is
// 1 to 3, 0 for none. whoever is right when the other is wrong wins the round.
const SHELLS = 3;
const shellGame = pickGame({
  startRound() {
    const shell = 1 + Math.floor(Math.random() * SHELLS);
    return {shell, sent: [shell]};
  },
  read: pick => whole(pick, 1, SHELLS) || 0,
  roundWinner([first, second], {shell}) {
    return (first === shell) === (second === shell) ? null : first === shell ? 0 : 1;
  },
});

// pairs: sixteen cards, four to a row, numbered 0 to 15 along the rows. A
// card's picture is its number in the list of 1 to 16, two of which make a
// pair when they differ by 8 (the scene folds 9-16 onto 1-8). "round" names
// the player who starts first, then the other, then the cards. the player
// whose turn it is turns up two ("c1", "c2", which the other is shown), both
// are told "results" [0, matched] and say "rp" when they have watched it,
// and "nextround" lets the game go on: the same player again after a match,
// the other after a miss or a "time". the last pair brings "results" [1,
// winner's id, 0 for a draw].
const CARDS = 16;
const pairs = {
  ready(match) {
    const cards = Array.from({length: CARDS}, (_, index) => index + 1);
    for (let index = cards.length - 1; index > 0; index--) {
      const swap = Math.floor(Math.random() * (index + 1));
      [cards[index], cards[swap]] = [cards[swap], cards[index]];
    }
    match.state = {cards, gone: new Set(), turn: coin(), first: null, found: [0, 0], watched: new Set(), showing: false};
    match.broadcast("round", match.ids[match.state.turn], match.ids[other(match.state.turn)], CARDS, ...cards);
  },
  messages: {
    c1(match, player, [card]) {
      const {state} = match;
      const index = whole(card, 0, CARDS - 1);
      if (state && !state.showing && player === state.turn && state.first === null && index !== null && !state.gone.has(index)) {
        state.first = index;
        match.send(other(player), "c1", index);
      }
    },
    c2(match, player, [card]) {
      const {state} = match;
      const index = whole(card, 0, CARDS - 1);
      if (!state || state.showing || player !== state.turn || state.first === null || index === null || index === state.first || state.gone.has(index)) {
        return;
      }
      match.send(other(player), "c2", index);
      const matched = (state.cards[index] - state.cards[state.first]) % (CARDS / 2) === 0;
      if (matched) {
        state.gone.add(index).add(state.first);
        state.found[player]++;
      }
      else {
        state.turn = other(player);
      }
      state.first = null;
      if (state.gone.size === CARDS) {
        const [mine, theirs] = [state.found[player], state.found[other(player)]];
        match.broadcast("results", 1, mine === theirs ? 0 : match.ids[mine > theirs ? player : other(player)]);
        match.over();
        return;
      }
      state.showing = true;
      state.watched.clear();
      match.broadcast("results", 0, matched ? 1 : 0);
    },
    time(match, player) {
      const {state} = match;
      if (state && !state.showing && player === state.turn) {
        state.turn = other(player);
        state.first = null;
        state.showing = true;
        state.watched.clear();
        match.broadcast("time");
      }
    },
    rp(match, player) {
      const {state} = match;
      if (state && state.showing && state.watched.add(player).size === 2) {
        state.showing = false;
        match.broadcast("nextround");
      }
    },
    emote: relayEmote,
  },
};

// the little faces Pairs and Bowling let players pull at each other.
function relayEmote(match, player, [emote]) {
  const face = whole(emote, 0, 1000);
  if (face !== null) {
    match.send(other(player), "emote", face);
  }
}

// Scooped: a race to build the same ice creams, the order of which both
// clients work out from the start message. each scoop is shown to the
// other player ("sc_click" and the name of the button pressed); whoever
// says "sc_done" first has won, and both are told who.
const scooped = {
  ready(match) {
    match.state = {done: false};
    match.broadcast("start");
  },
  messages: {
    sc_click(match, player, [button]) {
      if (match.state && !match.state.done && /^[A-Za-z]\w{0,30}$/.test(String(button))) {
        match.send(other(player), "sc_click", button);
      }
    },
    sc_done(match, player) {
      if (match.state && !match.state.done) {
        match.state.done = true;
        match.broadcast("sc_done", player);
        match.over();
      }
    },
  },
};

// Bowling: both clients roll every ball through the same simulation, the
// thrower's own and the other from the "ball" [angle, x, y] passed across.
// "round" names who bowls first. after each ball both say "rp" and are let
// on with "nextround"; a thrower who ran out of time says "time", which
// both are told. they keep the score and end the game themselves.
const bowling = {
  ready(match) {
    const first = coin();
    match.state = {watched: new Set()};
    match.broadcast("round", match.ids[first], match.ids[other(first)]);
  },
  messages: {
    ball(match, player, params) {
      const shot = params.slice(0, 3).map(number);
      if (match.state && shot.length === 3 && !shot.includes(null)) {
        match.send(other(player), "ball", ...shot);
      }
    },
    time(match) {
      if (match.state) {
        match.broadcast("time");
      }
    },
    rp(match, player) {
      if (match.state && match.state.watched.add(player).size === 2) {
        match.state.watched.clear();
        match.broadcast("nextround");
      }
    },
    emote: relayEmote,
  },
};

// marbles: the same arrangement. the start message picks one of the
// fourteen ways the marbles are laid out; "start" says who shoots first
// (as a place in the start message's list of players); the shooter's aim
// ("pos") and shot ("shoot" [from x, from y, force x, force y]) are passed
// to the other; and when both have said "endTurn", their marbles at rest,
// both are told so and change turns.
const MARBLE_PATTERNS = 14;
const marbles = {
  startData: () => [1 + Math.floor(Math.random() * MARBLE_PATTERNS)],
  ready(match) {
    match.state = {rested: new Set()};
    match.broadcast("start", coin());
  },
  messages: {
    pos(match, player, params) {
      const spot = params.slice(0, 2).map(value => whole(value, -10000, 10000));
      if (match.state && spot.length === 2 && !spot.includes(null)) {
        match.send(other(player), "pos", ...spot);
      }
    },
    shoot(match, player, params) {
      const shot = params.slice(0, 4).map(number);
      if (match.state && shot.length === 4 && !shot.includes(null)) {
        match.send(other(player), "shoot", ...shot);
      }
    },
    endTurn(match, player) {
      if (match.state && match.state.rested.add(player).size === 2) {
        match.state.rested.clear();
        match.broadcast("endTurn");
      }
    },
  },
};

// by the game's key in game.IncludeMinigames (`swf` in lib/games.json).
module.exports = {
  PVP_TicTacToe: ticTacToe,
  PVP_ConnectFour: fourGems,
  PVP_RockPaperScissor: rockPaperScissors,
  PVP_ShellGame: shellGame,
  PVP_Memory: pairs,
  PVP_Scooped: scooped,
  PVP_Bowling: bowling,
  PVP_Marbles: marbles,
};
