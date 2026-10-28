"use strict";

const config = require("../config.js");

const send = async ({to, subject, text}) => {
  if (!config.recoveryMail) {
    return false;
  }
  try {
    const response = await fetch(config.recoveryMail.url, {method: "POST", headers: {
      "Content-Type": "application/json", "Authorization": `Bearer ${config.recoveryMail.token}`,
    }, body: JSON.stringify({to, subject, text})});
    return response.ok;
  }
  catch (err) {
    console.error("[recovery] email delivery failed");
    return false;
  }
};

module.exports = {available: () => Boolean(config.recoveryMail), send};
