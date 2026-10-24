#!/usr/bin/env python3
"""Strip the status and navigation bars off a raw device screencap.

Usage: crop.py <in.png> <out.png> <top> <bottom>

The app draws edge to edge, so the system bars sit on top of the game's own
background — cropping is about removing the clock and the gesture pill, not
about finding a letterbox.
"""
import sys
from PIL import Image

src, dst, top, bottom = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
im = Image.open(src)
im.crop((0, top, im.width, im.height - bottom)).save(dst)
print(f"{dst} {im.width}x{im.height - top - bottom}")
