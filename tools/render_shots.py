#!/usr/bin/env python3
"""Renders build/shots/*.txt (draw commands dumped by odin/shots_test.odin) into PNGs at 960 by 640,
using the game's own tile sheet, icons and the DINOBYTE font, exactly as web/index.html draws them.
Usage: tools/render_shots.py OUT_DIR"""
import pathlib, sys
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
IMG = ROOT / "assets/images"
TILES = Image.open(IMG / "costileset.png").convert("RGBA")
FONT = Image.open(ROOT / "assets/dinobyte/dbyte_1x.png").convert("RGBA")
ICONS = [Image.open(IMG / n).convert("RGBA") for n in ("speaker.png", "speaker-off.png", "anticlockwise-rotation.png")]
SCALE = 2


def tinted(color, cache={}):
    if color not in cache:
        rgb = tuple(int(color[i:i + 2], 16) for i in (0, 2, 4))
        solid = Image.new("RGBA", FONT.size, rgb + (255,))
        solid.putalpha(FONT.getchannel("A"))
        cache[color] = solid
    return cache[color]


def render(src, dst):
    im = Image.new("RGBA", (480, 320), (0, 0, 0, 255))
    for line in src.read_text().splitlines():
        kind, rest = line[0], line[2:]
        if kind == "R":
            x, y, w, h, c = rest.split()
            im.paste(tuple(int(c[i:i + 2], 16) for i in (0, 2, 4)) + (255,), (int(x), int(y), int(x) + int(w), int(y) + int(h)))
        elif kind == "T":
            t, x, y = map(int, rest.split())
            i = t - 1
            tile = TILES.crop(((i % 16) * 12, (i // 16) * 12, (i % 16) * 12 + 12, (i // 16) * 12 + 12))
            im.alpha_composite(tile, (x, y))
        elif kind == "I":
            n, x, y, w, h = map(int, rest.split())
            im.alpha_composite(ICONS[n].resize((w, h), Image.LANCZOS), (x, y))
        elif kind == "S":
            x, y, c, text = rest.split(" ", 3) if rest.count(" ") >= 3 else (*rest.split(" "), "")
            sheet = tinted(c)
            for k, ch in enumerate(text.encode("latin-1", "replace")):
                if ch != 32:
                    g = sheet.crop(((ch % 16) * 6, (ch // 16) * 8, (ch % 16) * 6 + 6, (ch // 16) * 8 + 8))
                    im.alpha_composite(g, (int(x) + k * 6, int(y)))
    im.convert("RGB").resize((480 * SCALE, 320 * SCALE), Image.NEAREST).save(dst)


out = pathlib.Path(sys.argv[1])
out.mkdir(parents=True, exist_ok=True)
for f in sorted((ROOT / "build/shots").glob("*.txt")):
    render(f, out / (f.stem + ".png"))
    print(out / (f.stem + ".png"))
