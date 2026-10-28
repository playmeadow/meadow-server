"use strict";

// Loaded only when a rule is read or saved. defpacks.js is imported while
// accounts.js is still defining its exports, so a top-level require here
// would retain that partial `{}` forever.
const accounts = () => require("./accounts.js");

// Clothing that staff have said must not be worn by certain animal types.
// This is deliberately its own small module: game code, def packs and the
// dashboards all ask the same source of truth, while itemcontrol.js owns
// validating dashboard input and removing existing uses.

const SETTING = "clothingWearRules";

let rules = null; // Map<clothing def id, Set<avatar type>>

const positiveInteger = value => Number.isSafeInteger(value) && value > 0;

const ruleMap = () => {
  if (rules) {
    return rules;
  }
  let saved = {};
  try {
    const parsed = JSON.parse(accounts().setting(SETTING) || "{}");
    saved = parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {};
  }
  catch {
    saved = {};
  }
  rules = new Map();
  for (const [id, types] of Object.entries(saved)) {
    const itemId = Number(id);
    if (!positiveInteger(itemId) || !Array.isArray(types)) {
      continue;
    }
    const blocked = new Set(types.map(Number).filter(positiveInteger));
    if (blocked.size) {
      rules.set(itemId, blocked);
    }
  }
  return rules;
};

const save = () => {
  const stored = {};
  for (const [id, types] of [...ruleMap()].sort(([one], [two]) => one - two)) {
    stored[id] = [...types].sort((one, two) => one - two);
  }
  accounts().setSetting(SETTING, JSON.stringify(stored));
};

const blockedTypes = itemId => [...(ruleMap().get(Number(itemId)) || [])].sort((one, two) => one - two);

const all = () => [...ruleMap()].map(([id]) => ({id, blocked: blockedTypes(id)})).sort((one, two) => one.id - two.id);

const mayWear = (itemId, avatarType) => !ruleMap().get(Number(itemId))?.has(Number(avatarType));

// `types` has already been checked against the avatar definitions by
// itemcontrol.js.  Keeping this module generic lets it also be used while a
// def pack is being made, without a defpacks <-> wearrules dependency cycle.
const setBlockedTypes = (itemId, types) => {
  const id = Number(itemId);
  if (!positiveInteger(id)) {
    return {changed: false, blocked: []};
  }
  const next = new Set((Array.isArray(types) ? types : []).map(Number).filter(positiveInteger));
  const before = blockedTypes(id);
  if (next.size) {
    ruleMap().set(id, next);
  }
  else {
    ruleMap().delete(id);
  }
  const after = blockedTypes(id);
  const changed = before.length !== after.length || before.some((type, index) => type !== after[index]);
  if (changed) {
    save();
  }
  return {changed, blocked: after};
};

// Custom clothing ids are never reused, but clearing their rule at deletion
// keeps the setting accurate and avoids showing a stale dashboard entry.
const forget = itemId => {
  if (ruleMap().delete(Number(itemId))) {
    save();
  }
};

module.exports = {blockedTypes, all, mayWear, setBlockedTypes, forget};
