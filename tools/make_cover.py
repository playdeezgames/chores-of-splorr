#!/usr/bin/env python3
"""Makes assets/cover.png (630 by 500) from a screenshot of the port: the first room as you find it,
drawn with the game's own tiles, under the title in DINOBYTE. No new art: like the page's current
cover, it is a picture of the game. Run tools/make_shots.sh first (it dumps build/shots/cover.txt)."""
import pathlib, subprocess, sys
from PIL import Image

ROOT = pathlib.Path(__file__).resolve().parent.parent
tmp = ROOT / "build/cover"
subprocess.run([sys.executable, str(ROOT / "tools/render_shots.py"), str(tmp)], check=True, stdout=subprocess.DEVNULL)
shot = Image.open(tmp / "cover.png").resize((480, 320), Image.NEAREST)  # back to 1x

W, H, BAND = 315, 250, 26
cover = Image.new("RGB", (W, H), (0, 0, 0))
# The room: board columns 90..390 with a margin, rows from the top of the board down.
cover.paste(shot.crop((82, 10, 82 + W, 10 + H - BAND)), (0, BAND))

font = Image.open(ROOT / "assets/dinobyte/dbyte_1x.png").convert("RGBA")
def text(s, y, rgb, scale):
    line = Image.new("RGBA", (len(s) * 6, 8))
    ink = Image.new("RGBA", font.size, rgb + (255,))
    ink.putalpha(font.getchannel("A"))
    for k, ch in enumerate(s.encode()):
        line.alpha_composite(ink.crop(((ch % 16) * 6, (ch // 16) * 8, (ch % 16) * 6 + 6, (ch // 16) * 8 + 8)), (k * 6, 0))
    line = line.resize((line.width * scale, line.height * scale), Image.NEAREST)
    cover.paste(line, ((W - line.width) // 2, y), line)

text("Chores of SPLORR!!", 5, (0xef, 0xdd, 0xf2), 2)
out = ROOT / "assets/cover.png"
cover.resize((W * 2, H * 2), Image.NEAREST).save(out)
print(out, Image.open(out).size)
