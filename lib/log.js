"use strict";

// keeps the most recent lines the server printed, for the admin panel's log
// view. requiring this module is what starts the capture.

const MAX_LINES = 5000;
const MAX_LINE_LENGTH = 2000;
const TRIM_BATCH = 1000;

const lines = []; // {id, time, text}
let nextId = 1;

const capture = original => (...args) => {
  original(...args);
  const text = args.map(arg => (typeof arg === "string" ? arg : String(arg && arg.stack ? arg.stack : JSON.stringify(arg)))).join(" ");
  for (const line of text.split("\n")) {
    lines.push({id: nextId++, time: Date.now(), text: line.slice(0, MAX_LINE_LENGTH)});
  }
  // trimmed a batch at a time: trimming a line at a time moved all the
  // others along for every line printed.
  if (lines.length > MAX_LINES + TRIM_BATCH) {
    lines.splice(0, lines.length - MAX_LINES);
  }
};

console.log = capture(console.log.bind(console));
console.error = capture(console.error.bind(console));

// lines newer than id `after` whose text contains `filter` (any case), newest
// `limit` of them, oldest first.
const recent = (after = 0, filter = "", limit = 500) => {
  const wanted = filter.toLowerCase();
  return lines.filter(line => line.id > after && (!wanted || line.text.toLowerCase().includes(wanted))).slice(-limit);
};

module.exports = {recent, count: () => nextId - 1};
