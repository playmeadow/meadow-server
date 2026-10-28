"use strict";

// features this server does not have, answered with the "nothing here" reply
// each one's client code expects, so that the client carries on instead of
// waiting on a spinner. each entry names the client method that reads it.

module.exports = {
  // ReferAFriendXtCommManager.referralHasAssociateResponse: 0 = no referrer.
  refh(session) {
    session.sendXt("refh", -1, 0);
  },
};
