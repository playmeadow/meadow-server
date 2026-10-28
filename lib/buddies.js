"use strict";

const accounts = require("./accounts.js");
const achievements = require("./achievements.js");
const limits = require("./limits.js");
const {activeAvatar} = require("./player.js");

// buddy lists and blocking (client side: BuddyXtCommManager, BuddyManager).
// buddies are mutual and stored on both accounts as lowercased usernames.

const MAX_BUDDIES = 1337;
const MAX_BLOCKED = 1000; // as on the account page (lib/world.js)

// BuddyManager.buddyAddRequestResponseHandler status codes
const REQUEST_INCOMING = 0;
const REQUEST_SENT = 1;
const REQUEST_TARGET_FULL = 2;
const REQUEST_NOT_ACCEPTING = 3;
const REQUEST_OWN_LIST_FULL = 4;
const REQUEST_UNBLOCK_FIRST = 5;

// BuddyManager.buddyStatusResponseHandler buddyFlag values
const STATUS_UPDATE = 0;
const STATUS_ACCEPTED_YOUR_REQUEST = 1;

const USERNAME_SHOWN = 1; // userNameModeratedFlag: > 0 shows the real name

// requests waiting for an answer are kept on the asked account, as
// `buddyRequests`: lowercased usernames of who asked. someone not in the
// game is shown theirs when they next arrive.
const MAX_WAITING_REQUESTS = 50;

const key = account => account.username.toLowerCase();
// requests one account may send: enough for anyone making friends, too few
// to fill other players' waiting lists with.
const requestsPerTenMinutes = limits.limiter(20, 600000);

// BuddyCard.buddyRoomResponseHandler shows this on the buddy's card: the
// name the room goes by on screen. it tells a den by the word "Den" in it,
// and reads a hosted party's name as three string ids.
const roomTitle = room => room.displayName;

module.exports = ({findOnline, onBlocked, onUnblocked, partyTimeLeft, worldOf, worldName}) => {
  // BuddyXtCommManager.buddyStatusResponse: [1, username, uuid, moderatedFlag,
  // online, accountType, buddyFlag, avatarName, perUserAvId, partyTimeLeft]
  const sendStatus = (to, account, buddyFlag) => {
    const avatar = activeAvatar(account);
    to.sendXt("bs", -1, 1, account.username, account.uuid, USERNAME_SHOWN, findOnline(account.username) ? 1 : 0,
      account.accountType, buddyFlag, avatar.name, avatar.perUserAvId, partyTimeLeft(account));
  };

  const announce = account => {
    for (const name of account.buddies) {
      const buddy = findOnline(name);
      if (buddy) {
        sendStatus(buddy, account, STATUS_UPDATE);
      }
    }
  };

  const hasOnlineBuddies = account => account.buddies.some(name => Boolean(findOnline(name)));

  const handlers = {
    // BuddyManager.buddyListResponseHandler: [0, onlineCount, (username, uuid,
    // moderatedFlag, accountType, partyTimeLeft)..., offlineCount, (username,
    // uuid, moderatedFlag, accountType)...], then blockedListResponseHandler:
    // [1, count, username...]
    bl(session) {
      const buddies = session.account.buddies.map(accounts.byName).filter(Boolean);
      const online = buddies.filter(buddy => findOnline(buddy.username));
      const offline = buddies.filter(buddy => !findOnline(buddy.username));
      session.sendXt("bl", -1, 0,
        online.length, ...online.flatMap(buddy => [buddy.username, buddy.uuid, USERNAME_SHOWN, buddy.accountType, partyTimeLeft(buddy)]),
        offline.length, ...offline.flatMap(buddy => [buddy.username, buddy.uuid, USERNAME_SHOWN, buddy.accountType]));
      session.sendXt("bl", -1, 1, session.account.blocked.length, ...session.account.blocked);
      // for the patched buddy list (gui.itemWindows.ItemWindowBuddyList):
      // when each offline buddy was last seen, as [count, (username, seconds)...].
      session.sendXt("xls", -1, offline.length, ...offline.flatMap(buddy => [buddy.username, buddy.lastSeen || buddy.lastLogin || 0]));
    },

    // [username]: ask someone to be a buddy. the requester and the target each
    // get a "ba" (buddyAddRequestResponse: [status, username, moderatedFlag]).
    ba(session, roomId, [username]) {
      const {account} = session;
      const target = accounts.byName(username);
      const targetSession = target && findOnline(target.username);
      const reply = status => session.sendXt("ba", -1, status, target ? target.username : username, USERNAME_SHOWN);
      if (!target || target === account || target.blocked.includes(key(account))
        || !accounts.featureOn(account, "buddies") || !accounts.featureOn(target, "buddies")
        || (!target.buddyRequests.includes(key(account)) && target.buddyRequests.length >= MAX_WAITING_REQUESTS)) {
        reply(REQUEST_NOT_ACCEPTING);
      }
      else if (account.blocked.includes(key(target))) {
        reply(REQUEST_UNBLOCK_FIRST);
      }
      else if (account.buddies.length >= MAX_BUDDIES) {
        reply(REQUEST_OWN_LIST_FULL);
      }
      else if (target.buddies.length >= MAX_BUDDIES) {
        reply(REQUEST_TARGET_FULL);
      }
      else if (!account.buddies.includes(key(target)) && !target.buddyRequests.includes(key(account)) && !requestsPerTenMinutes.allow(account.id)) {
        reply(REQUEST_NOT_ACCEPTING);
      }
      else if (!account.buddies.includes(key(target))) {
        if (!target.buddyRequests.includes(key(account))) {
          target.buddyRequests.push(key(account));
          accounts.save(account, target);
        }
        if (targetSession) {
          targetSession.sendXt("ba", -1, REQUEST_INCOMING, account.username, USERNAME_SHOWN);
        }
        reply(REQUEST_SENT);
      }
    },

    // [username, "1" accept | "0" decline]: answer a pending request.
    bc(session, roomId, [username, accept]) {
      const {account} = session;
      const requester = accounts.byName(username);
      if (!requester || !account.buddyRequests.includes(key(requester))) {
        return;
      }
      account.buddyRequests = account.buddyRequests.filter(name => name !== key(requester));
      accounts.save(account);
      const requesterSession = findOnline(requester.username);
      if (accept !== "1" || account.buddies.includes(key(requester))
        || account.buddies.length >= MAX_BUDDIES || requester.buddies.length >= MAX_BUDDIES) {
        if (requesterSession) {
          requesterSession.sendXt("ba", -1, REQUEST_NOT_ACCEPTING, account.username, USERNAME_SHOWN);
        }
        return;
      }
      account.buddies.push(key(requester));
      requester.buddies.push(key(account));
      achievements.add(account, achievements.VARS.buddiesAdded);
      achievements.add(requester, achievements.VARS.buddiesAdded);
      accounts.save(account, requester);
      sendStatus(session, requester, STATUS_UPDATE);
      if (requesterSession) {
        sendStatus(requesterSession, account, STATUS_ACCEPTED_YOUR_REQUEST);
      }
    },

    // [username]: end a buddyship. both sides get a "bd" naming the other.
    bd(session, roomId, [username]) {
      const {account} = session;
      const other = accounts.byName(username);
      if (other) {
        account.buddies = account.buddies.filter(name => name !== key(other));
        other.buddies = other.buddies.filter(name => name !== key(account));
        accounts.save(account, other);
        const otherSession = findOnline(other.username);
        if (otherSession) {
          otherSession.sendXt("bd", -1, account.username);
        }
      }
      session.sendXt("bd", -1, other ? other.username : username);
    },

    // BuddyManager.buddyBlockResponseHandler: [username, success]
    bb(session, roomId, [username]) {
      const {account} = session;
      const other = accounts.byName(username);
      const added = other && other !== account && !account.blocked.includes(key(other)) && account.blocked.length < MAX_BLOCKED;
      if (added) {
        account.blocked.push(key(other));
        accounts.save(account);
      }
      session.sendXt("bb", -1, username, other && other !== account && account.blocked.includes(key(other)) ? 1 : 0);
      if (added) {
        onBlocked(session, other);
      }
    },

    bu(session, roomId, [username]) {
      const {account} = session;
      const other = accounts.byName(username);
      const removed = other && account.blocked.includes(key(other));
      account.blocked = account.blocked.filter(name => name !== String(username).toLowerCase());
      accounts.save(account);
      session.sendXt("bu", -1, username, 1);
      if (removed) {
        onUnblocked(session, other);
      }
    },

    // [username]: is that player blocking me?
    bi(session, roomId, [username]) {
      const other = accounts.byName(username);
      session.sendXt("bi", -1, username, other && other.blocked.includes(key(session.account)) ? 1 : 0);
    },

    // [username]: where is that player? BuddyCard.buddyRoomResponseHandler
    // gets [roomName, displayName, displayNameStringId, cannotGoThere]; an
    // empty room means offline. the last field greys out the card's "go to"
    // button (BuddyCard.checkBuddyRoomAgainstMine), so it is 0: every room
    // here can be walked into. the room's name carries its world, and "go
    // to" joins it by that name, so it leads into the buddy's world, which
    // is named after the room when it is not the asker's. someone who
    // blocked the asker looks offline.
    br(session, roomId, [username]) {
      const target = findOnline(username);
      if (target && target.room && !target.account.blocked.includes(key(session.account))) {
        const world = worldOf(target.room.name);
        const elsewhere = world !== 0 && world !== session.worldId;
        session.sendXt("br", -1, target.room.name, `${roomTitle(target.room)}${elsewhere ? ` (${worldName(world)})` : ""}`, 0, 0);
      }
      else {
        session.sendXt("br", -1, "", "", 0, 0);
      }
    },
  };

  // shows a player who has just arrived the requests made while they were
  // away. they stay on the account until answered, so one the player did
  // not get to is asked again next time.
  const greet = session => {
    const {account} = session;
    const waiting = account.buddyRequests.map(accounts.byName)
      .filter(requester => requester && !account.buddies.includes(key(requester)) && !account.blocked.includes(key(requester)));
    account.buddyRequests = waiting.map(key);
    for (const requester of waiting) {
      session.sendXt("ba", -1, REQUEST_INCOMING, requester.username, USERNAME_SHOWN);
    }
  };

  return {handlers, announce, hasOnlineBuddies, greet};
};
