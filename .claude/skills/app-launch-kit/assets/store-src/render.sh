#!/bin/bash
# Renders Play listing cards from cropped device captures.
# Usage: render.sh <raw-capture-dir> <out-dir>
# Edit the card list below: card <out> <raw.png> "<title|line2>" "<sub>" <device-width>
set -euo pipefail
SRC="$(cd "$(dirname "$0")" && pwd)"; RAW="$(cd "${1:?raw dir}" && pwd)"; OUT="${2:?out dir}"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
mkdir -p "$OUT"
enc() { python3 -c 'import sys,urllib.parse;print(urllib.parse.quote(sys.argv[1]))' "$1"; }
# --virtual-time-budget lets the Google Font land before the shot.
shot() { "$CHROME" --headless=new --disable-gpu --hide-scrollbars --allow-file-access-from-files --virtual-time-budget=4000 --window-size="$1" --screenshot="$2" "$3" 2>/dev/null; }
card() { [ -f "$RAW/$2" ] || { echo "skip $1 — no $2"; return; }
  shot 1080,1920 "$OUT/$1" "file://$SRC/frame.html?img=file://$RAW/$2&dw=$5&title=$(enc "$3")&sub=$(enc "$4")"; }
text() { shot 1080,1920 "$OUT/$1" "file://$SRC/card.html?title=$(enc "$2")&sub=$(enc "$3")&chip=$(enc "$4")"; }

# ---- phone (Play: 2-8, 16:9 or 9:16, 320-3840px) ----
card phone-1-home.png   home.png   "Headline|two lines" "Sub-claim under 60 chars" 640
card phone-2-x.png      x.png      "Headline"           "Sub-claim"                640
text phone-8-claim.png "100%|OFFLINE" "No account. No cloud." "FREE FOREVER"
# ---- tablet 7"/10" (reuse phone captures, wider device) ----
card tablet7-1-home.png home.png "Headline" "Built for big screens too" 760
for f in 1-home; do [ -f "$OUT/tablet7-$f.png" ] && cp "$OUT/tablet7-$f.png" "$OUT/tablet10-$f.png"; done
shot 1024,500 "$OUT/feature-graphic.png" "file://$SRC/feature.html"
shot 1080,1920 "$OUT/endcard.png" "file://$SRC/endcard.html"
sips -Z 512 "$SRC/icon.png" --out "$OUT/app_icon-512.png" >/dev/null
echo "rendered into $OUT"
