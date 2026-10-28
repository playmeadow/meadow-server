// commit messages follow Conventional Commits ("fix(trades): keep offers
// after a rename"), checked by .github/workflows/commitlint.yml.
//
// the commits the private repository's tools/publish-public.sh makes ("Brought
// up to date with the private repository (abc1234)") are left alone: they are
// written by a script and carry no change of their own to describe.
export default {
  extends: ["@commitlint/config-conventional"],
  ignores: [message => /^Brought up to date with the private repository \([0-9a-f]+\)/.test(message)],
  rules: {
    // long links and file paths in a body or footer are fine
    "body-max-line-length": [0],
    "footer-max-line-length": [0],
  },
};
