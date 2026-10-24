#!/bin/bash
# Drives the ad-free screenshot build on an Android emulator and captures one raw
# PNG per store card into <out-dir>, then strips the system bars.
# Usage: capture.sh <out-dir>
# Edit: PKG, ACTIVITY, the tap coordinates (take a screencap, read pixel positions), crop margins.
set -euo pipefail
OUT="${1:?out dir}"; mkdir -p "$OUT"
SRC="$(cd "$(dirname "$0")" && pwd)"
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
PKG=com.example.app; ACTIVITY=$PKG/.MainActivity
t() { adb shell input tap "$1" "$2"; sleep "${3:-1.5}"; }
shot() { sleep 1; adb exec-out screencap -p > "$OUT/$1.png"; }
swipe_up() { adb shell input swipe 540 1900 540 "${1:-800}" 400; sleep 1; }

# Clean status bar (demo mode) and a fresh install state.
adb shell settings put global sysui_demo_allowed 1
for c in "enter" "clock -e hhmm 0900" "battery -e level 100 -e plugged false" \
         "network -e wifi show -e level 4 -e fully true" "notifications -e visible false"; do
  adb shell am broadcast -a com.android.systemui.demo -e command $c >/dev/null
done
adb shell pm clear $PKG >/dev/null
adb shell pm grant $PKG android.permission.POST_NOTIFICATIONS 2>/dev/null || true
adb shell am start -n $ACTIVITY >/dev/null; sleep 6

# ---- flow: one shot per card. Cold-launch between flows if back-presses drift. ----
shot home
# t 540 2272; shot tab2
# swipe_up 1300; shot scrolled

adb shell am broadcast -a com.android.systemui.demo -e command exit >/dev/null
adb shell am force-stop $PKG
# Strip the clock (top) and gesture pill (bottom). Pixel 1080x2424 @420dpi: 100 / 70.
for f in "$OUT"/*.png; do python3 "$SRC/crop.py" "$f" "$f" 100 70; done
echo "captured into $OUT"
