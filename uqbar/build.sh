#!/bin/bash

set -e

BASE_DIR=${XDG_CONFIG_HOME:-$HOME}
UQBAR_DIR=${UQBAR_DIR-"$BASE_DIR/.uqbar"}
UQBAR_REPO="$UQBAR_DIR/uqbarup"

pwd=$(pwd)
name=$(grep -o 'name = "[^"]*' ./Cargo.toml | sed 's/name = "//')

rm -rf "$pwd/wit"
cp -r "$UQBAR_REPO/wit" "$pwd"
mkdir -p "$pwd/target/bindings/$name"

cp "$UQBAR_REPO/target.wasm" "$pwd/target/bindings/$name/"
cp "$UQBAR_REPO/world" "$pwd/target/bindings/$name/"
cp "$UQBAR_REPO/wasi_snapshot_preview1.wasm" $pwd

mkdir -p "$pwd/target/wasm32-unknown-unknown/release"

# Build the module using Cargo
cargo build \
    --release \
    --no-default-features \
    --manifest-path="$pwd/Cargo.toml"\
    --target "wasm32-wasi"

# Adapt the module using wasm-tools
wasm-tools component new "$pwd/target/wasm32-wasi/release/$name.wasm" -o "$pwd/target/wasm32-wasi/release/${name}_adapted.wasm" --adapt "$pwd/wasi_snapshot_preview1.wasm"

# Embed "wit" into the component and place it in the expected location
wasm-tools component embed wit --world uq-process "$pwd/target/wasm32-wasi/release/${name}_adapted.wasm" -o "$pwd/target/wasm32-unknown-unknown/release/$name.wasm"
