"use strict";

const config = require("../config.js");

// Google Cloud Vision SafeSearch detects adult and racy material.  We keep
// this dependency-free and use its REST API so deploying the server needs no
// service-account files or Google SDK in node_modules.
const UNSAFE = new Set(["LIKELY", "VERY_LIKELY"]);
const TIMEOUT_MS = 10000;

// {blocked, error}; `error` deliberately fails closed when the scanner is
// enabled: accepting an image while the safety service is unavailable would
// make this protection easy to bypass.
const scan = async image => {
  if (!config.googleVision) {
    return {blocked: false};
  }
  if (!Buffer.isBuffer(image) || image.length === 0) {
    return {blocked: true, error: "That picture could not be checked for safety."};
  }
  const abort = new AbortController();
  const timer = setTimeout(() => abort.abort(), TIMEOUT_MS);
  try {
    const response = await fetch(config.googleVision.endpoint, {
      method: "POST",
      headers: {"Content-Type": "application/json"},
      signal: abort.signal,
      body: JSON.stringify({
        requests: [{image: {content: image.toString("base64")}, features: [{type: "SAFE_SEARCH_DETECTION"}]}],
      }),
    });
    const result = await response.json().catch(() => null);
    const safeSearch = result && result.responses && result.responses[0] && result.responses[0].safeSearchAnnotation;
    if (!response.ok || !safeSearch) {
      console.error(`[image-moderation] Google Vision request failed (${response.status})`);
      return {blocked: true, error: "Picture safety checking is temporarily unavailable. Please try again."};
    }
    if (UNSAFE.has(safeSearch.adult) || UNSAFE.has(safeSearch.racy)) {
      return {blocked: true, error: "That picture was blocked because it may contain nudity or other NSFW content."};
    }
    return {blocked: false};
  }
  catch (err) {
    console.error(`[image-moderation] Google Vision request failed: ${err.message}`);
    return {blocked: true, error: "Picture safety checking is temporarily unavailable. Please try again."};
  }
  finally {
    clearTimeout(timer);
  }
};

module.exports = {scan};
