#!/bin/sh
# builds Ruffle (the Flash player in WebAssembly, ruffle.rs) for the browser
# version of the game (public/play.html at /play) into <data>/ruffle, where
# the server serves it from at /play/ruffle/. about 15 MB, not kept in git.
#
#   tools/build-ruffle.sh [tag]      (default: the nightly below)
#
# Ruffle as released cannot run the game: a movie opened with
# Loader.loadBytes that imports another (the game's asset SWFs all import
# sharedFonts.swf) never finishes loading, and the game opens every room
# and asset that way. tools/ruffle-loadbytes-imports.patch fixes that, so
# Ruffle is built here, with it, from source.
#
# everything it needs (Rust, wasm-bindgen, binaryen, the source) goes in
# ~/.cache/burrow-ruffle (BURROW_RUFFLE_BUILD), and nothing else is
# touched; remove that folder to undo it. needs git, curl and Node 22 or
# later. the first build takes a while, later ones less. AJ_DATA_DIR is
# honoured as the server does.
set -eu
tag=${1:-nightly-2026-10-24}
here=$(cd "$(dirname "$0")" && pwd)
data=${AJ_DATA_DIR:-$here/../data}
build=${BURROW_RUFFLE_BUILD:-$HOME/.cache/burrow-ruffle}
export RUSTUP_HOME="$build/rustup" CARGO_HOME="$build/cargo"
export PATH="$build/cargo/bin:$build/binaryen-version_123/bin:$PATH"
mkdir -p "$build"
cd "$build"

if [ ! -x cargo/bin/rustup ]; then
  curl -fsSL https://sh.rustup.rs -o rustup-init.sh
  sh rustup-init.sh -y --no-modify-path --profile minimal --default-toolchain stable -t wasm32-unknown-unknown
fi
# the plain engine (below) builds Rust's standard library itself, from its source
rustup component add rust-src
if [ ! -d binaryen-version_123 ]; then
  curl -fsSL https://github.com/WebAssembly/binaryen/releases/download/version_123/binaryen-version_123-x86_64-linux.tar.gz | tar xz
fi

if [ ! -d src ]; then
  git clone --depth 1 --branch "$tag" https://github.com/ruffle-rs/ruffle.git src
fi
cd src
git fetch --depth 1 origin tag "$tag"
git checkout -q --force "$tag"
git apply "$here/ruffle-loadbytes-imports.patch"
# a full collection whenever the page's memory grows (see the patch): the
# game's rooms otherwise took a phone's browser past what it allows a page
git apply "$here/ruffle-gc-on-growth.patch"

# the wasm-bindgen-cli Ruffle's Cargo.lock asks for, exactly
bindgen=$(grep -A1 '^name = "wasm-bindgen"$' Cargo.lock | sed -n 's/^version = "\(.*\)"$/\1/p')
if [ "$(wasm-bindgen --version 2>/dev/null)" != "wasm-bindgen $bindgen" ]; then
  cargo install wasm-bindgen-cli --version "$bindgen" --locked
fi

cd web
npm ci --ignore-scripts --no-audit --no-fund
# both of Ruffle's engines: the one for browsers with the newer WebAssembly
# features, and the plain one Ruffle falls back to where any is missing
# (some phones' browsers). without the second, those said "Failed to load
# Ruffle WASM".
BUILD_WASM_MVP=true npm run build --workspace=ruffle-core
npm run build --workspace=ruffle-selfhosted
git -C .. checkout -q -- core/src/loader.rs core/src/player.rs

rm -rf "$data/ruffle"
mkdir -p "$data/ruffle"
cp packages/selfhosted/dist/*.js packages/selfhosted/dist/*.wasm packages/selfhosted/dist/*.map packages/selfhosted/dist/LICENSE_* "$data/ruffle/"
echo "Ruffle $tag, patched, in $data/ruffle"
