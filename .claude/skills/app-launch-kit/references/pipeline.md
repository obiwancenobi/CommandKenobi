# Screenshot + promo pipeline notes

## Ad-free demo build

Play screenshots must not show ads, and a fresh install shows empty screens. Solve both in the app, not in Photoshop:

- A dedicated flavor/flag (`screenshots` flavor, or `--dart-define=SCREENSHOT_MODE=true`) that (a) disables every ad load in the ads facade, (b) grants rewarded unlocks instantly, (c) feeds deterministic demo data through the same data-access seam production uses.
- Demo data lives in one file (`lib/platform/demo_<source>.dart` or similar): fixed tables, no randomness, a comment on what the numbers produce on screen ("Sat = 101m → score 74"). Guard every call site with one `if (demo)` line. Leave one test that pins the headline number.
- Anything that anchors to install day (streaks, "first day" logic) needs a demo bypass too, or history hides.
- Grant runtime permissions over adb (`pm grant <pkg> android.permission.POST_NOTIFICATIONS`) so permission-health screens show green.

## Emulator hygiene

- Pixel-class AVD, 1080×2424 @420dpi is the current default. `adb shell wm size` to confirm.
- Status bar via SystemUI demo mode (already in `capture.sh`): fixed clock 9:00, full battery, wifi with `-e fully true` (else a "!" shows), no notification icons. `exit` at the end.
- `pm clear` then relaunch gives a deterministic onboarding start every run.
- Tap coordinates: take a screencap, read positions off it (Read tool shows scaled coordinates; multiply back). Cold-launch between flows instead of counting back presses.
- Buttons hidden under a floating nav: `swipe_up` before the shot.
- Crop with `crop.py <in> <out> <top> <bottom>`: strip the clock and gesture pill only. Edge-to-edge apps draw their own bar colour under the status bar, so a small extra band of app-bar colour is fine.

## Cards

- `render.sh` needs an absolute raw dir; it `cd`s to make one. Titles use `|` for line breaks.
- Headless Chrome needs `--virtual-time-budget` or the Google Font misses the shot.
- Check a contact sheet (PIL: resize each card to ~320 wide, paste in a row) before calling it done. Look for: overlapping shapes on text, cut-off device, wrong aspect.
- Tablet cards: phone captures at `dw=760` pass Play review; swap in real tablet captures only if flagged.

## Promo

- Everything is CSS animation on a 1080×1920 stage; `record.mjs` seeks frame by frame over CDP and pins `document.getAnimations()` to the exact time, so output is deterministic.
- Restart animations with `getAnimations().forEach(a => { a.cancel(); a.play(); })`, never by resetting `style.animation` (that wipes inline `animation-delay`, so staggered elements all appear at frame zero).
- Keep under 30s (WhatsApp Status splits longer clips). Typical cut: 3.2s hook + 7×1.9s shots + 3.4s wall + 2.4s claim + 3.4s end ≈ 25.7s.
- Verify by extracting frames: `ffmpeg -ss <t> -i out.mp4 -frames:v 1 f.png` at the hook start, mid-climb, stamp, one shot, wall, claim mid-wipe, end. Stagger must be visible.
- bgm.m4a is bundled and credited in `build-promo.sh`; pass `none` for silent.

## Requirements

Chrome at `/Applications/Google Chrome.app`, Node 22+ (global WebSocket), ffmpeg, python3 + Pillow, `sips` (macOS), adb in `~/Library/Android/sdk/platform-tools`.
