"use strict";

// an animal's adventure level (avatar.questLevel) and the XP behind it
// (avatar.questXp), shared by the adventures and the arena.
//
// the recordings show three levels: 50 XP to level 1, 200 more to level 2,
// and about 450 more to level 3 (5 XP into level 2 shown as 1%, 55 as 12%).
// that is 50 times the level squared, and the levels after are taken to go
// on so: level 2 to 3 takes 450, 29 to 30 takes 45,000, 99 to 100 500,000.

const MAX_LEVEL = 100;

// the XP a level starts at
const levelXp = level => 50 * level * (level + 1) * (2 * level + 1) / 6;
const levelFor = xp => {
  let level = 0;
  while (level < MAX_LEVEL && xp >= levelXp(level + 1)) {
    level++;
  }
  return level;
};
const xpOf = avatar => Math.max(avatar.questXp || 0, levelXp(avatar.questLevel || 0));
// how far through its level, in percent (QuestManager.handleXpUpdate). at
// the top level there is no next one: 100.
const percent = xp => {
  const level = levelFor(xp);
  if (level >= MAX_LEVEL) {
    return 100;
  }
  return Math.round((xp - levelXp(level)) * 100 / (levelXp(level + 1) - levelXp(level)));
};

// the arena's own level (lib/arena.js), apart from the adventures': kept
// on the account as arenaXp, on the same curve, from level 1 (0 XP) to 100.
const arenaXpOf = account => (Number.isFinite(account.arenaXp) && account.arenaXp > 0 ? account.arenaXp : 0);
const arenaLevelOf = account => Math.min(MAX_LEVEL, levelFor(arenaXpOf(account)) + 1);

module.exports = {MAX_LEVEL, levelXp, levelFor, xpOf, percent, arenaXpOf, arenaLevelOf};
