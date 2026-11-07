# CLAUDE.md

"Chores of SPLORR!!" by TheGrumpyGameDev: a tile game in which you play as a cleaning lady (Defold/Lua, GlamJam 2025, January 2025), ported to Odin and `js_wasm32` on November 7, 2026. The vault at `/home/yermom/git/bok-of-splorr/splorr/` documents it (`Games/Chores of SPLORR!!.md`) and holds the standing rules; read its `Home.md` first.

## Layout

- `odin/`: package `chores`. `world.odin` is the pure game (rooms, features, the move rules, the original's text; no platform imports, the RNG is in the World), `view.odin` turns a World into draw commands on the original's 480 by 320 screen, `app.odin` keys and taps, `save.odin` the save (the World's bytes behind a header; World must stay plain data), `web.odin` the wasm entry points (`#+build js`). Tests are `*_test.odin` (`#+build !js`); `shots_test.odin` dumps draw commands for the screenshots.
- `web/index.html`: the page (2D canvas, tile and font blits, Web Audio, localStorage, footer with credits and back links).
- `tools/`: `build.sh`, `test.sh` (tests plus the real wasm build), `ship.sh` (itch.io, pushes only with `--push`), `pages.sh` (GitHub Pages into `docs/`), `make_shots.sh` with `render_shots.py`, `make_cover.py`. `shippit.sh` is the one-line wrapper for `tools/ship.sh`.
- `ChoresOfSPLORR/`: the Defold original, the specification, and the source of the art (`assets/images/costileset.png`, the icons) and sounds (`assets/sfx/*.wav`), which the build copies as they are. `QUIRKS.md` lists every deliberate difference.
- Release material per the vault's Release standard: `ITCH_DESCRIPTION.md`, `assets/cover.png`, `assets/screenshots/`, `devlog/YYYYMMDD/`.

## Rules

- Never `git push`, `tools/ship.sh --push`, `shippit.sh --push` or `butler push` unless the user says so ("push" means git, "ship" means itch.io). One itch.io release a day, booked in Coxswain.
- The itch page was tagged `no-ai`. The user decided (November 7, 2026) to ship the port there disclosed: remove the tag and set the AI disclosure to Yes (Code) on ship day (see `ITCH_DESCRIPTION.md`).
- Keep the text and the deliberate design (the dust bunnies, the exploding washer, spoiled laundry, the magic keys, "Tomorrow, you can do them again!"); fixes go in `QUIRKS.md`.
- `int` is 32 bits on `js_wasm32`: run the wasm build as well as the tests (`tools/test.sh` does both).
- `ChoresOfSPLORR/manifest.private.der` is the Defold project's signing key, committed in January 2025 in this public repo. It only signs Defold live-update manifests; it was left as it is.
