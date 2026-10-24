#!/bin/bash
# Portrait promo (1080x1920, 30fps) rendered straight off store/src/promo.html.
# record.mjs drives headless Chrome frame by frame (deterministic seek, not a
# screen capture) and ffmpeg encodes the sequence. Keep the cut under 30s.
#
# Usage: build-promo.sh <promo.html> <out.mp4> [bgm]
#   bgm: defaults to bgm.m4a next to promo.html (source:
#        https://www.youtube.com/watch?v=N_8kU6UoDMs). "none" = silent.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
PAGE="${1:?promo.html}"; OUT="${2:?out mp4}"; SRC="$(cd "$(dirname "$PAGE")" && pwd)"
BGM="${3:-$SRC/bgm.m4a}"; FPS=30
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

node "$HERE/record.mjs" "$PAGE" "$TMP/frames" "$FPS"

ffmpeg -v error -y -framerate "$FPS" -i "$TMP/frames/f%05d.png" \
  -c:v libx264 -crf 20 -preset medium -pix_fmt yuv420p -r "$FPS" "$TMP/video.mp4"

DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$TMP/video.mp4")
if [ "$BGM" != none ] && [ -f "$BGM" ]; then
  ffmpeg -v error -y -i "$TMP/video.mp4" -stream_loop -1 -i "$BGM" \
    -filter_complex "[1:a]atrim=0:$DUR,asetpts=PTS-STARTPTS,afade=t=in:d=1,afade=t=out:st=$(echo "$DUR - 2" | bc):d=2[a]" \
    -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 128k -shortest "$OUT"
else
  cp "$TMP/video.mp4" "$OUT"
fi
printf 'built %s (%.1fs)\n' "$OUT" "$DUR"
awk -v d="$DUR" 'BEGIN { if (d > 30) print "WARNING: over 30s — WhatsApp Status will cut it" }'
