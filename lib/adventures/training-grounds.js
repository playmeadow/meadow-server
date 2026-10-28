"use strict";

// the Training Grounds ("Adventure Tutorial", script def 15), written from
// a recording of the official game of 2026-10-12: one player, who talked
// to Liza four times, fed the four phantoms to the plants, crept past the
// rest unseen and opened the chest. everything sent here was seen sent
// there, in this order. not in the recording, so not here: being caught by
// a phantom.
//
// commands ("qcmd"): 1 sets an actor's [state, visible, needs a click];
// 3 has it talk (a string id); 38 is the line under the screen's top; 19
// ends the adventure. "qswfs" plays a state of an actor's artwork.

const liza = (q, name, ...artwork) => {
  for (const state of artwork) {
    q.send("qswfs", name, state);
  }
  q.send("qcmd", 1, name, 1, 1, 1);
};
const TALKS = {liza_1: 3149, liza_2: 3150, liza_3: 3155, liza_4: 3151};
const talk = name => q => q.send("qcmd", 3, 0, name, 1, TALKS[name]);
// Liza leaves in two steps and is put away a little later.
const leaves = (q, name, between, gone) => {
  q.send("qswfs", name, "disappear");
  q.send("qcmd", 1, name, 2, 1, 1);
  between();
  q.send("qcmd", 1, name, 3, 1, 0);
  q.after(gone, () => q.send("qcmd", 1, name, 4, 0, 0));
};
const TRAPPED_LINES = [3539, 3540, 3541];

module.exports = {
  defId: 15,
  title: "Training Grounds",
  rooms: {start: {room: "adventures.room_adventure_tutorial", name: "Adventure Tutorial", nameStringId: 18326, music: "ajq_mustutorial"}},
  written: "2018-03-14 22:04:55",
  objective: 3152, // "TALK to Liza."

  // name, type, def, state, visible, needs a click, path, artwork state
  actors: [
    ["queststart", 18, 0, 0, 1, 1, "", ""],
    ["checkpoint", 16, "ajq_spawnpointlp", 0, 1, 1, "", ""],
    ["portal", 16, "ajq_portalgatelp", 0, 0, 1, "", ""],
    ["lizatimer_1", 8, 0, 0, 0, 1, "", ""],
    ["liza_1", 1, 21, 0, 0, 1, "", ""],
    ["liza_2", 1, 21, 0, 0, 1, "", ""],
    ["lizatimer_2", 8, 0, 0, 0, 1, "", ""],
    ["lizatimer_3", 8, 0, 0, 0, 1, "", ""],
    ["lizatrig_1", 3, 0, 0, 1, 1, "", ""],
    ["blockvol_1", 5, 0, 0, 1, 1, "", ""],
    ["blockvol_2", 5, 0, 0, 1, 1, "", ""],
    ["blockvol_3", 5, 0, 0, 1, 1, "", ""],
    ["block_1", 2, 0, 0, 1, 1, "", ""],
    ["block_2", 2, 0, 0, 1, 1, "", ""],
    ["block_3", 2, 0, 0, 1, 1, "", ""],
    ["phantom_1", 11, 2, 0, 1, 1, "", ""],
    ["phantom_2", 11, 2, 0, 1, 1, "", ""],
    ["phantom_3", 11, 2, 0, 1, 1, "", ""],
    ["phantom_4__a", 11, 2, 0, 1, 1, "", ""],
    ["phantom_4__b", 11, 2, 0, 1, 1, "", ""],
    ["plant_0", 21, 100, 0, 1, 1, "", ""],
    ["plant_1", 21, 100, 0, 1, 1, "", ""],
    ["plant_2", 21, 100, 0, 1, 1, "", ""],
    ["plant_3", 21, 100, 0, 1, 1, "", ""],
    ["plant_4", 21, 100, 0, 1, 1, "", ""],
    ["phantom_5", 11, 2, 0, 1, 1, "path_5", ""],
    ["phantom_6", 11, 2, 0, 1, 1, "path_6", ""],
    ["phantom_7", 11, 2, 0, 1, 1, "path_7", ""],
    ["phantom_8", 11, 2, 0, 1, 1, "path_8", ""],
    ["phantom_9", 11, 2, 0, 1, 1, "path_9", ""],
    ["phantom_10", 11, 2, 0, 1, 1, "path_10", ""],
    ["phantom_11", 11, 2, 0, 1, 1, "path_11", ""],
    ["phantom_12", 11, 2, 0, 1, 1, "path_12", ""],
    ["phantom_13", 11, 2, 0, 1, 1, "path_13", ""],
    ["phantom_14", 11, 2, 0, 1, 1, "path_14", ""],
    ["treasure_1", 13, 39, 0, 0, 1, "", ""],
    ["exitblock", 5, 0, 0, 1, 1, "", ""],
    ["exit", 2, 0, 0, 1, 1, "", ""],
    ["exitvol", 3, 0, 0, 1, 1, "", ""],
    ["liza_3", 1, 21, 0, 0, 1, "", ""],
    ["lizatimer_4", 8, 0, 0, 0, 1, "", ""],
    ["lizatrig_3", 3, 0, 0, 1, 1, "", ""],
    ["liza_4", 1, 21, 0, 0, 1, "", ""],
    ["lizatimer_5", 8, 0, 0, 0, 1, "", ""],
    ["trap_count", 7, 0, 0, 0, 1, "", ""],
    ["traptimer", 8, 0, 0, 0, 1, "", ""],
    ["path_5", 20, 0, 0, 1, 1, "", ""],
    ["path_6", 20, 0, 0, 1, 1, "", ""],
    ["path_7", 20, 0, 0, 1, 1, "", ""],
    ["path_8", 20, 0, 0, 1, 1, "", ""],
    ["path_9", 20, 0, 0, 1, 1, "", ""],
    ["path_10", 20, 0, 0, 1, 1, "", ""],
    ["path_11", 20, 0, 0, 1, 1, "", ""],
    ["path_12", 20, 0, 0, 1, 1, "", ""],
    ["path_13", 20, 0, 0, 1, 1, "", ""],
    ["path_14", 20, 0, 0, 1, 1, "", ""],
    ["diff_level", 7, 0, 0, 1, 1, "", ""],
    ["live_players", 7, 0, 1, 0, 1, "", ""],  ],

  on: {
    loaded(q) {
      q.vars.trapped = 0;
      q.after(1700, () => liza(q, "liza_1", "facesw", "appear"));
    },

    // walked into, or clicked
    trigger: {
      liza_1: talk("liza_1"),
      liza_2: talk("liza_2"),
      liza_3: talk("liza_3"),
      liza_4: talk("liza_4"),
      lizatrig_1(q) {
        liza(q, "liza_2", "facesw", "appear");
        q.send("qcmd", 1, "lizatrig_1", 1, 0, 0);
      },
      lizatrig_3(q) {
        liza(q, "liza_4", "appear");
        q.send("qposturi", "/adventure0-tutorial/#20-sneakpastthephantoms/#0#001");
        q.send("qcmd", 1, "lizatrig_3", 1, 0, 0);
      },
      // QuestActor.handleTriggerTreasure: [actor, 3, gems, 0, 1]
      treasure_1(q) {
        q.send("qatt", "treasure_1", 3, 250, 0, 1);
        q.send("qposturi", "/adventure0-tutorial/#30-exit/#0#001");
      },
      exitvol(q) {
        q.send("qcmd", 19);
      },
    },

    // a talk read to its end
    answer: {
      liza_1(q) {
        q.send("qposturi", "/adventure0-tutorial/#00-start/#0#001");
        q.send("qcmd", 1, "block_1", 1, 1, 0);
        q.send("qcmd", 1, "blockvol_1", 1, 0, 0);
        q.send("qcmd", 38, 3157);
        leaves(q, "liza_1", () => {}, 2200);
      },
      liza_2(q) {
        q.send("qcmd", 1, "blockvol_2", 1, 0, 0);
        q.send("qcmd", 1, "block_2", 1, 1, 0);
        leaves(q, "liza_2", () => {}, 2950);
        q.send("qcmd", 38, 3538);
      },
      liza_3(q) {
        q.send("qcmd", 1, "block_3", 1, 1, 0);
        q.send("qcmd", 1, "blockvol_3", 1, 0, 0);
        q.send("qcmd", 38, 3542);
        leaves(q, "liza_3", () => {}, 2580);
      },
      liza_4(q) {
        q.send("qcmd", 1, "treasure_1", 1, 1, 1);
        leaves(q, "liza_4", () => q.send("qcmd", 38, 3543), 2700);
        // the recording's animal was level 0 and got 50 XP here, which made
        // it level 1. guessed: that this is for a first time only.
        if (q.level() === 0) {
          q.after(690, () => q.xp(50, "lizatimer_5"));
        }
      },
    },

    // A plant ate a phantom: [actor, 50, 1, x, y, ""] has it die there.
    eaten(q, plant, phantom, x, y) {
      if (!/^phantom_\w+$/.test(phantom) || q.vars.trapped >= 4) {
        return;
      }
      q.vars.trapped++;
      q.send("qad", phantom, 50, 1, x, y, "");
      q.send("qcmdVT", 1, "trap_count", q.vars.trapped, 0, 0);
      if (q.vars.trapped < 4) {
        q.send("qcmd", 38, TRAPPED_LINES[q.vars.trapped - 1]);
      }
      else {
        q.send("qposturi", "/adventure0-tutorial/#10-trapthephantoms/#0#001");
        q.send("qcmd", 38, 3152);
        q.after(500, () => liza(q, "liza_3", "facesw", "appear"));
      }
      q.xp(1, phantom);
    },

    // the chest, opened
    opened: {
      treasure_1(q) {
        if (q.vars.opened) {
          return;
        }
        q.vars.opened = true;
        q.gems(250);
        q.xp(1, "treasure_1");
        q.send("qcmd", 1, "exitblock", 1, 0, 0);
        q.send("qcmd", 1, "exit", 1, 1, 0);
        q.send("qcmd", 1, "portal", 1, 1, 0);
        q.send("qposturi", "/adventure0-tutorial/#30-exit/#0#001");
      },
    },
  },
};
