# chores-of-splorr
In which you play as a cleaning lady, because that's obviously fun, right?

Made with Defold for GlamJam 2025 (January 2025; the Defold project was removed on November 8, 2026 and is in git history at commit e85bf85). Ported to Odin and WebAssembly in November 2026 (`odin/`, `web/`), with an AI agent (Claude Code) at the author's direction; the differences are in `QUIRKS.md`.

- Play: https://playdeezgames.github.io/chores-of-splorr/ (latest) or https://thegrumpygamedev.itch.io/chores-of-splorr
- Build: `tools/build.sh`, then serve `build/web` (for example `python3 -m http.server -d build/web`). Tests: `tools/test.sh`. Needs Odin.
