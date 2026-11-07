Page: https://thegrumpygamedev.itch.io/chores-of-splorr
Jam: GlamJam 2025 (January 2025). Original release: a Defold HTML5 build, uploaded by hand. This is the November 2026 browser port.
Pasted in by hand; nothing here is published by the repo. Everything above "Notes (not for the page)" is for the page.

**Short description**

You play as a cleaning lady. Sweep, wash the dishes, do the laundry. Thankless chores! Now saves in your browser.

**Description**

This is a game.

That I wrote.

Or really, its just a demo now.

But you can interact with it.

And that's not nothing.

**Controls:**

Arrow keys, WASD or ZQSD to move (hold to walk). Space closes a message. Click the speaker to mute, the arrow to start over. On a phone or tablet, tap the room to step towards where you tapped.

**New: rebuilt for the browser**

The metaphor has been rebuilt in Odin and WebAssembly. The house, the dirt, the dust bunnies, the dishes and the laundry are the original's, with a few fixes:

- It saves as you play, in this browser, and picks up where you left off.
- The last KEY in the laundry room always appears now (it could fail to, which left you stuck).
- When one step says two things, you see both (the first used to be overwritten).
- The washing machine and dryer no longer flicker, and a full inventory says so.
- It works with taps and clicks as well as keys.

The full list is in QUIRKS.md in the source.

**AI use**

This browser version was written with Claude Code (Anthropic's AI coding assistant) at my direction: the port, its tests, the cover (a screenshot of the port) and this text. The metaphor, its design, its text, its art and its sounds are the original's, and the January 2025 original was made without AI.

**Credits**

A production of TheGrumpyGameDev for GlamJam 2025, with "help" from the malcontents and ne'er-do-wells that watch him stream. Source: https://github.com/playdeezgames/chores-of-splorr

Font: DINOBYTE by mby, https://mby.itch.io/dinobyte, CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/), unmodified. Icons (speaker, rotation): game-icons.net, CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/).

---

**Notes (not for the page)**

- The short description is 113 characters (itch.io allows 120).
- The five lines from "This is a game." to "And that's not nothing." are the page's current text, kept as they are.
- **AI disclosure, decided November 7, 2026:** the page is tagged `no-ai`, and its cover was swapped in January 2025 from an AI-art image (`ss/cover.png`) to a game screenshot (`ss/non_ai_cover.png`). The user decided to ship the AI-written port to this page, disclosed: on ship day remove the `no-ai` tag and set the AI disclosure to Yes (Code), with the "AI use" section above (as for Clumsy Oaf of SPLORR!!).
- **GitHub Pages:** not live yet (needs the user's go-ahead to push and enable Pages; the repo is already public). When it is live, add at the top of the description: `**Latest version:** https://playdeezgames.github.io/chores-of-splorr/` and the same URL as an external link.
- **Ship day:** `./shippit.sh --push` creates the `html` channel (the 2025 build was uploaded by hand, so butler has no channel for this page). Then in the dashboard: delete the old Defold HTML5 upload (else the page has two builds), mark the new `html` upload "This file will be played in the browser", embed size 960 by 680 (the 960 by 640 canvas plus the footer; it scales down to fit). There are no Windows, macOS or Linux downloads to remove.
- Upload `assets/cover.png` (a screenshot of the port's first room with the title, made by `tools/make_cover.py` from the game's own tiles and the DINOBYTE font; no new art) and the screenshots in `assets/screenshots/` (rendered from real game states by `tools/make_shots.sh`).
- The icons look like game-icons.net's `speaker`, `speaker-off` and `anticlockwise-rotation` (by Delapouite on that site, as far as can be told from the names and style); the credit above is written to be right either way.
