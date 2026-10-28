"use strict";

const {logText} = require("./logtext.js");
const crypto = require("crypto");
const accounts = require("./accounts.js");
const bans = require("./bans.js");
const config = require("../config.js");
const limits = require("./limits.js");
const {isUint} = require("./player.js");

// the client's own "Create Account" screens (createAccountFlow.CreateAccount).
// they log in to a guest zone with no credentials, check the chosen names
// with "la" and create the account with "lc".

const SIGNUP_ZONE = "sbiAccountZone";

// status codes CreateAccountGui.showLoginCreateResultMsg understands.
const OK = 1;
const FAILED = -1;
const USERNAME_TAKEN = -3;
const USERNAME_INVALID = -4;
const PASSWORD_INVALID = -5;

const STATUS = {
  username_taken: USERNAME_TAKEN,
  invalid_username: USERNAME_INVALID,
  invalid_password: PASSWORD_INVALID,
  weak_password: PASSWORD_INVALID, // the game's screens have one word for both
  name_not_allowed: USERNAME_INVALID,
};
// names asked about on one guest connection: the screens ask once or twice.
const MAX_NAME_CHECKS = 40;

// "la" check types
const CHECK_AVATAR_NAME = "1";

// SBCrypto.encrypt: AES-256-CBC under SHA-256 of the session's random key,
// sent as base64 of the IV followed by the ciphertext.
const decryptPassword = (encoded, sessionKey) => {
  try {
    const raw = Buffer.from(encoded, "base64");
    const key = crypto.createHash("sha256").update(sessionKey, "utf8").digest();
    const decipher = crypto.createDecipheriv("aes-256-cbc", key, raw.subarray(0, 16));
    return Buffer.concat([decipher.update(raw.subarray(16)), decipher.final()]).toString("utf8");
  }
  catch (err) {
    return null;
  }
};

const handlers = {
  // CreateAccountXtCommManager.sendLoginAvailableRequest: [checkType, name,
  // nameId1, nameId2, nameId3, language, deployVersion]. any animal name built
  // from the pickers is fine; usernames must be valid and free.
  la(session, roomId, [checkType, name]) {
    session.nameChecks = (session.nameChecks || 0) + 1;
    if (session.nameChecks > MAX_NAME_CHECKS) {
      session.close();
      return;
    }
    const problem = checkType === CHECK_AVATAR_NAME ? null : accounts.usernameProblem(String(name).trim());
    session.sendXt("la", -1, problem ? STATUS[problem] : OK);
  },

  // CreateAccountXtCommManager.sendLoginCreateRequest: [username,
  // encryptedPassword, birthday, gender, sgParams, nameId1, nameId2, nameId3,
  // avatarType, language, country, deployVersion]. the reply
  // (CreateAccount.handleLoginCreate) is [status, accountId].
  lc(session, roomId, [username, encryptedPassword, , , , name1, name2, name3, avatarType]) {
    const password = session.key ? decryptPassword(String(encryptedPassword), session.key) : null;
    if (password === null) {
      session.sendXt("lc", -1, FAILED, 0);
      return;
    }
    // checked before the sign-up limit so a mistyped form does not use it up.
    const problem = accounts.usernameProblem(String(username).trim());
    if (problem) {
      session.sendXt("lc", -1, STATUS[problem], 0);
      return;
    }
    // the game's own sign-up screens cannot show the terms, so on a public
    // server an account is made on the sign-up page or in the client.
    if (config.isPublic) {
      session.sendXt("lc", -1, FAILED, 0);
      return;
    }
    if (bans.addressBan(session.address)) {
      console.log("[signup] refused a sign-up from a banned address");
      session.sendXt("lc", -1, FAILED, 0);
      return;
    }
    if (!limits.registrationAllowed(session.address, limits.isTrustedLocal(session.address))) {
      console.log(`[signup] too many sign-ups from ${logText(session.address)}`);
      session.sendXt("lc", -1, FAILED, 0);
      return;
    }
    const avatarName = [name1, name2, name3].every(isUint) ? `${name1}|${name2}|${name3}` : undefined;
    const result = accounts.register(username, password, {type: avatarType, name: avatarName});
    if (result.error) {
      session.sendXt("lc", -1, STATUS[result.error], 0);
      return;
    }
    session.sendXt("lc", -1, OK, result.account.id);
  },

  // the first animal's look, sent alongside "lc"; the account already has it
  // and the client expects no reply.
  ln() {},
};

module.exports = {handlers, SIGNUP_ZONE};
