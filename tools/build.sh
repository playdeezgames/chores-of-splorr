#!/usr/bin/env bash
# Builds the browser game into build/web. Pass --size for the shipping build.
set -euo pipefail
cd "$(dirname "$0")/.."
ODIN="${ODIN:-odin}"
opt=speed
[[ "${1:-}" == "--size" ]] && opt=size
rm -rf build/web
mkdir -p build/web/sfx
"$ODIN" build odin -target:js_wasm32 -out:build/web/game.wasm -o:$opt -vet-unused -vet-shadowing
cp "$("$ODIN" root)/core/sys/wasm/js/odin.js" build/web/
cp web/index.html build/web/
# The original's art and sounds, used as they are.
img=assets/images
cp "$img/costileset.png" build/web/tiles.png
cp "$img/speaker.png" "$img/speaker-off.png" "$img/anticlockwise-rotation.png" build/web/
cp assets/sfx/*.wav build/web/sfx/
cp assets/dinobyte/dbyte_1x.png build/web/
cp assets/dinobyte/dbyte-LICENSE.txt build/web/NOTICE-dinobyte.txt
echo "built build/web ($opt)"
