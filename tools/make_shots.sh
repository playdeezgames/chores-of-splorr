#!/usr/bin/env bash
# Renders the itch.io screenshots from real game states: the shots test dumps draw commands,
# render_shots.py draws them with the game's own art. Usage: tools/make_shots.sh
set -euo pipefail
cd "$(dirname "$0")/.."
ODIN="${ODIN:-odin}"
mkdir -p build
"$ODIN" build odin -build-mode:test -define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_NAMES=chores.test_dump_shots -out:build/shots-test
build/shots-test >/dev/null
python3 tools/render_shots.py assets/screenshots
