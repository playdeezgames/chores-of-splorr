#!/usr/bin/env bash
# Native tests of the rules, view and saves, then the real wasm build (odin check skips the vet flags).
# One thread: the tests share package globals.
set -euo pipefail
cd "$(dirname "$0")/.."
ODIN="${ODIN:-odin}"
mkdir -p build
"$ODIN" test odin -define:ODIN_TEST_THREADS=1 -vet-unused -vet-shadowing -out:build/chores-tests
"$ODIN" build odin -target:js_wasm32 -out:build/check.wasm -vet-unused -vet-shadowing
rm -f build/check.wasm
