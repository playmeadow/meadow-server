"use strict";

const accounts = require("./accounts.js");
const achievements = require("./achievements.js");
const bans = require("./bans.js");
const dens = require("./dens.js");
const config = require("../config.js");
const {CURRENCIES} = require("./player.js");

// moderation: kick, ban, silence, clear a den, grant gems, message a player.
// these are done from the admin panel (lib/panel.js). no game account has
// them: the client's own moderator requests (FacilitatorXtCommManager) are
// always refused.

const PERMANENT = -1;
const SECONDS_PER_MINUTE = 60;
const CURRENCY_GEMS = 0;
// ItemXtCommManager.currencyUpdateResponse: with this as the reason the
// client says "You earned N ..." in a popup when the amount went up.
const REASON_ANNOUNCE = 3;

// a warning's reason, and the client's own warning popup for it
// (FacilitatorXtCommManager.showContextualWarningPopup, "fw"): its artwork
// and its words, which this server's strings already say in its own name.
const WARNINGS = {
  behavior: 4, // "Inappropriate Behavior"
  bullying: 1, // "Bullying"
  personal: 3, // "Personal Information"
  scamming: 9, // "Scamming"
  // in the staff member's own words: its note is what the player is shown,
  // in a message box (there is no popup for it), and it cannot be left out.
  custom: null,
};
const CUSTOM_WARNING = "custom";
const MAX_WARNINGS_KEPT = 100;
const MAX_WARNING_NOTE = 200;
const SECONDS_PER_DAY = 86400;

const now = () => Math.floor(Date.now() / 1000);

// seconds of ban left, PERMANENT, or 0 when not banned.
const banRemaining = account => {
  if (account.bannedUntil === PERMANENT) {
    return PERMANENT;
  }
  return Math.max(0, (account.bannedUntil || 0) - now());
};

// the ban an account is under, for whoever may know why (the banned player,
// and whoever runs the server): {seconds, reason, by, since}, or null.
const banOf = account => {
  const seconds = banRemaining(account);
  return seconds === 0 ? null : {seconds, reason: account.banReason || bans.NO_REASON, by: account.bannedBy || "", since: account.bannedAt || null};
};

// the warnings an account has had in the last config.warningSilence.days
// (all of them when that is 0).
const recentWarnings = account => {
  const days = (config.warningSilence || {}).days || 0;
  const since = now() - days * SECONDS_PER_DAY;
  return (account.warnings || []).filter(entry => !days || entry.at >= since).length;
};

// the minutes of silence a warning brings when it is the Nth recent one
// (config.warningSilence.steps, [[N, minutes], ...]); 0 for none.
const silenceForWarning = count => {
  const step = ((config.warningSilence || {}).steps || []).find(([warnings]) => warnings === count);
  return step ? step[1] : 0;
};

const isSilenced = account => account.silencedUntil === PERMANENT || (account.silencedUntil || 0) > now();

// seconds of silence left, PERMANENT, or 0 when the account may chat.
const silenceRemaining = account => {
  if (account.silencedUntil === PERMANENT) {
    return PERMANENT;
  }
  return Math.max(0, (account.silencedUntil || 0) - now());
};

module.exports = ({findOnline}) => {
  // FacilitatorXtCommManager.facilitatorDisciplineResponse: what the affected
  // player's client is told.
  const discipline = (session, ...fields) => session.sendXt("fd", -1, ...fields);

  // A "message from moderator" popup; also used to answer chat commands.
  const notify = (session, text) => discipline(session, "fp", text, 0);
  // a warning as the player sees it: the game's popup for its reason, or a
  // custom one's words.
  const showWarning = (session, entry) => {
    if (entry.reason === CUSTOM_WARNING && entry.note) {
      notify(session, `Warning: ${entry.note}`);
    }
    else {
      discipline(session, "fw", WARNINGS[entry.reason] ?? WARNINGS.behavior);
    }
  };

  const actions = {
    kick(target) {
      const session = findOnline(target.username);
      if (!session) {
        return false;
      }
      discipline(session, "fk", 0);
      session.close();
      return true;
    },

    // duration in seconds, or PERMANENT. the reason is for the banned
    // player and whoever runs the server, nobody else; `by` is who gave it.
    ban(target, duration, reason = "", by = "") {
      target.bannedUntil = duration === PERMANENT ? PERMANENT : now() + duration;
      target.banReason = bans.reasonText(reason);
      target.bannedBy = by;
      target.bannedAt = now();
      accounts.save(target);
      bans.record({account: target, action: "ban", seconds: duration, reason: target.banReason, by});
      const session = findOnline(target.username);
      if (session) {
        discipline(session, "fb", 1, duration);
        session.close();
      }
      return true;
    },

    unban(target, by = "") {
      const was = banRemaining(target) !== 0;
      delete target.bannedUntil;
      delete target.banReason;
      delete target.bannedBy;
      delete target.bannedAt;
      accounts.save(target);
      if (was) {
        bans.record({account: target, action: "unban", by});
      }
      return true;
    },

    // another reason for the ban they are under; its length stays.
    banReason(target, reason, by = "") {
      if (banRemaining(target) === 0) {
        return false;
      }
      target.banReason = bans.reasonText(reason);
      accounts.save(target);
      bans.record({account: target, action: "reason", reason: target.banReason, by});
      return true;
    },

    // duration in seconds, PERMANENT, or 0 to lift
    silence(target, duration) {
      target.silencedUntil = duration === PERMANENT ? PERMANENT : (duration > 0 ? now() + duration : 0);
      accounts.save(target);
      const session = findOnline(target.username);
      if (session) {
        // minutes, negative for "until further notice", 0 for "you may type again"
        discipline(session, "fs", duration === PERMANENT ? PERMANENT : Math.ceil(duration / SECONDS_PER_MINUTE));
      }
      return true;
    },

    // their username will not do: they are put out, every saved sign-in
    // ends, and the next sign-in asks for another name before it lets them
    // in (lib/http.js, lib/manage.js). the name itself stays until then.
    rejectName(target, by = "") {
      target.nameRejected = {by, at: now()};
      accounts.revokeTokens(target);
      accounts.save(target);
      actions.kick(target);
      return true;
    },

    // taken back: the name will do after all.
    acceptName(target) {
      delete target.nameRejected;
      accounts.save(target);
      return true;
    },

    clearDen(target) {
      dens.clearDen(target, findOnline);
      return true;
    },

    // every post they wrote on anyone's Jammer Wall (lib/walls.js), their
    // own included, and the replies to those, as deleting a post in the game
    // takes its replies. returns {posts, replies, walls}.
    clearWallPosts(author) {
      const changed = [];
      let posts = 0;
      let replies = 0;
      for (const owner of accounts.all()) {
        const {wall} = owner;
        const gone = new Set(wall.posts.filter(post => post.uid === author.id).map(post => post.x));
        if (!gone.size) {
          continue;
        }
        const kept = wall.posts.filter(post => !gone.has(post.x) && !gone.has(post.pp));
        posts += gone.size;
        replies += wall.posts.length - kept.length - gone.size;
        const left = new Set(kept.map(post => post.x));
        wall.posts = kept;
        wall.hidden = wall.hidden.filter(id => left.has(id));
        wall.modified = Date.now();
        changed.push(owner);
      }
      if (changed.length) {
        accounts.save(...changed);
      }
      return {posts, replies, walls: changed.length};
    },

    grantGems(target, amount) {
      return actions.grantCurrency(target, CURRENCY_GEMS, amount, false);
    },

    // adds to (or with a negative amount takes from) one of a player's
    // currencies: an index into CURRENCIES. `announce` has their game say so.
    grantCurrency(target, currencyType, amount, announce = true) {
      const name = CURRENCIES[currencyType];
      if (!name) {
        return false;
      }
      const before = target.currency[name] || 0;
      target.currency[name] = Math.max(0, before + amount);
      achievements.currencyChanged(target, name, target.currency[name] - before);
      accounts.save(target);
      const session = findOnline(target.username);
      if (session) {
        // ItemXtCommManager.currencyUpdateResponse: [currencyType, newAmount, reason]
        session.sendXt("cu", -1, currencyType, target.currency[name], announce ? REASON_ANNOUNCE : 0);
      }
      return true;
    },

    message(target, text) {
      const session = findOnline(target.username);
      if (!session) {
        return false;
      }
      notify(session, text);
      return true;
    },

    // a warning: kept on the account (who, when, why and a note for staff),
    // and shown with the game's own warning popup: now if they are in a
    // room, else once they are next (greet). the Nth warning within
    // config.warningSilence.days may also silence them for a while; a
    // longer silence already on them is left alone.
    // returns {count, online, silencedMinutes}, or null for a reason that
    // is not one (or a custom warning with nothing to say).
    warn(target, reason, by, note = "") {
      const text = String(note).trim().slice(0, MAX_WARNING_NOTE);
      if (!Object.hasOwn(WARNINGS, reason) || (reason === CUSTOM_WARNING && !text)) {
        return null;
      }
      const session = findOnline(target.username);
      const seen = Boolean(session && session.greeted);
      const entry = {at: now(), by, reason, note: text, seen};
      target.warnings = [...(target.warnings || []), entry].slice(-MAX_WARNINGS_KEPT);
      accounts.save();
      if (seen) {
        showWarning(session, entry);
      }
      let silencedMinutes = silenceForWarning(recentWarnings(target));
      const left = silenceRemaining(target);
      if (silencedMinutes && left !== PERMANENT && left < silencedMinutes * SECONDS_PER_MINUTE) {
        actions.silence(target, silencedMinutes * SECONDS_PER_MINUTE);
      }
      else {
        silencedMinutes = 0;
      }
      return {count: target.warnings.length, online: Boolean(session), silencedMinutes};
    },

    // takes back their latest warning (one given by mistake). a silence it
    // brought stays; that is lifted on its own (silence 0). returns the
    // warning taken back, or null when there is none.
    unwarn(target) {
      const list = target.warnings || [];
      if (!list.length) {
        return null;
      }
      const removed = list[list.length - 1];
      target.warnings = list.slice(0, -1);
      accounts.save();
      return removed;
    },
  };

  // the client's moderator requests, refused whoever sends them. each
  // expects [0] for failure; "fc" (clear den) has no reply at all.
  const refuse = reply => session => session.sendXt(reply, -1, 0);
  const handlers = {fk: refuse("fk"), fb: refuse("fb"), fs: refuse("fs"), fm: refuse("fm"), fg: refuse("fg"), fp: refuse("fp"), fc() {}};

  // the first room has loaded (lib/world.js): a warning given while they
  // were away is shown now, the latest only (the game has one warning
  // popup), and all of them count as seen.
  const greet = session => {
    const unseen = (session.account.warnings || []).filter(entry => entry.seen === false);
    if (!unseen.length) {
      return;
    }
    unseen.forEach(entry => { entry.seen = true; });
    accounts.save();
    showWarning(session, unseen[unseen.length - 1]);
  };

  return {handlers, actions, greet, banRemaining, banOf, isSilenced, silenceRemaining, PERMANENT, WARNINGS: Object.keys(WARNINGS)};
};

Object.assign(module.exports, {isSilenced, banRemaining, banOf});
