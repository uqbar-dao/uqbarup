#!/bin/bash

# Use this script to upload a built uqbar app and start the process through rpc.

# Check if there are enough parameters provided.
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <url> <node-id>"
    exit 1
fi

URL="$1"
NODE="$2"
NAME=$(grep -o 'name = "[^"]*' ./Cargo.toml | sed 's/name = "//')
WASM_FILE="./target/wasm32-unknown-unknown/release/$NAME.wasm"

if [ ! -e "$WASM_FILE" ]; then
    echo "Could not find build. Try running uqbar build"
    exit 1
fi

# Put the payload in a temporary file (.wasm is too large otherwise).
JSON_PAYLOAD=$(echo -n '{"node": "'"$NODE"'", "process": "'"$PROCESS"'", "capabilities": [["http_bindings", "{\"messaging\": \"{\"Name\":\"http_bindings\"}\"}"]], "wasm": "'"$(base64 < "$WASM_FILE")"'"}')
echo -n "$JSON_PAYLOAD" > /tmp/temp_payload.json

# Upload the wasm file and start the process through rpc.
OUTPUT=$(curl -s "$URL/rpc/start-process" -H 'content-type: application/json' --data-binary @/tmp/temp_payload.json)

echo $OUTPUT

rm /tmp/temp_payload.json