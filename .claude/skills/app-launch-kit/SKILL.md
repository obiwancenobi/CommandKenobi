---
name: app-launch-kit
description: >
  Produce the complete Google Play launch kit for a mobile app in one pass: store listing
  copy, screenshots and store cards rendered from a real ad-free build, feature graphic and
  icon, an animated portrait promo video (<30s), a release checklist audited against the
  code, and launch social content for 8 platforms. Use whenever the user says "store
  listing", "Play Store assets", "screenshots for the store", "promo video", "launch kit",
  "release checklist", "what do I need to publish", "prepare for launch", or asks for any
  two of those items together, even if they only name one. Also use when a release build
  exists and the user asks "what next". Flutter/Android first; the HTML/ffmpeg pipeline is
  framework-agnostic.
---

# App launch kit

One `store/` directory per project, built from bundled templates and the app's own theme.
Everything is regenerable from `store/src/`, so a UI change means "rerun", not "redo".

```
store/
├── copy/listing-en.md        ← title / short / full / what's new / settings
├── release_checklist.md      ← audited, ticked as you go
├── src/                      ← copied from this skill's assets/store-src, then edited
├── raw/en/*.png              ← cropped device captures
├── en/*.png                  ← phone-1..8, tablet7/10, feature-graphic, app_icon-512, endcard
└── promo/*.mp4
social-content/<app>-launch/  ← 8 platform files + summary.md
```

Read `references/pipeline.md` before step 3. Paths below are relative to the repo root;
`$SKILL` is this skill's directory.

## 0. Gather (no questions if the repo answers)

- App name, applicationId, platforms, positioning line, price/ads model. Sources: CLAUDE.md,
  README, spec docs, `pubspec.yaml`, `android/app/build.gradle*`.
- Brand tokens: colours, font, radius, shadow style. Source: the theme module. Map them onto
  the `:root` block in `store/src/shared.css`.
- Icon PNG (≥512). Voice profile (`~/.claude/voice.md` if present).
- A previous project's `store/` as a worked example if one is on disk (`pocket_tools`, `rotmeter`).
- Existing build flavours: is there an ad-free screenshot flavour or flag? Is there demo data?

## 1. Scaffold

```bash
mkdir -p store/copy store/raw/en store/en store/promo
cp -R $SKILL/assets/store-src/ store/src/     # templates + bgm
cp <icon.png> store/src/icon.png
```

Edit `store/src/shared.css` `:root` to the app's tokens (and the Google Font import).
Edit the text nodes in `feature.html` and `endcard.html`. Smoke-render before capturing:

```bash
store/src/render.sh store/raw/en store/en   # feature graphic + text card render without captures
```

View the PNGs. Fix layout before moving on.

## 2. Ad-free demo build

If the app has no screenshot flavour or the flavour shows empty data, add it now, in the app:
one flag that disables ads, grants rewarded unlocks, and routes the data seam to a
deterministic demo table. Pattern and pitfalls: `references/pipeline.md` § Ad-free demo build.
Keep it to one new file plus one-line guards. Add one test pinning the headline number.
Build release for the emulator's ABI, install, walk onboarding once by hand and screencap
each screen to learn tap coordinates.

## 3. Capture

Edit `store/src/capture.sh`: PKG, activity, one `shot <name>` per card, taps/swipes between.
Run it, then build a contact sheet of `store/raw/en/*.png` and look at it. Re-shoot anything
with a cut-off button, an empty state, or a notification icon.

## 4. Cards

Edit the card list in `store/src/render.sh`: one line per capture with title (`|` for a line
break), sub-claim, device width (640 phone, 760 tablet). Pills and headlines are read without
context: never a bare "NO ADS" / "FREE FOREVER" / "NO TRACKING" unless true for the whole app
(see `references/listing-template.md` § scope every claim). Last phone card is usually a text-only
claim (`text` helper). Render, contact-sheet, iterate. Play accepts 2-8 phone shots; ship 8.

## 5. Promo

Edit the `CONTENT` block at the bottom of `store/src/promo.html`: `BRAND` strings, `SHOTS`
(reuse the captures), `WALL` chips. Preview in Chrome (`open store/src/promo.html`), then:

```bash
$SKILL/scripts/build-promo.sh store/src/promo.html store/promo/promo-portrait-1080x1920.mp4
```

Extract 7-9 frames with ffmpeg and inspect them. Staggered elements must appear late, not at
frame zero. Under 30 seconds, or WhatsApp splits it.

## 6. Listing copy

Write `store/copy/listing-en.md` per `references/listing-template.md`. Facts only from the
repo. Count characters against the limits. Match the voice file.

## 7. Release checklist

Copy `references/release-checklist-template.md` to `store/release_checklist.md`, fill the
header, then **verify each blocker against the code** before ticking: grep for consent, list
the manifest permissions, stat the AAB against the last commit, check the demo flag's guard.
Record what you found under Notes. An unticked box with a reason beats a false tick.

## 8. Social content

Follow `references/social-brief.md`. Prefer the installed `generate-social-content`
command; otherwise write the eight files yourself. Align placeholder numbers, add `summary.md`.

## 9. Report

Lead with what is in `store/` and `social-content/`. Then the blockers the checklist audit
surfaced (these are the real deliverable). Then code changes made for the demo build. Then
what was skipped and why. Do not commit unless asked.

## Bundled files

- `scripts/record.mjs` headless-Chrome frame recorder (CDP, deterministic seek)
- `scripts/build-promo.sh <promo.html> <out.mp4> [bgm|none]`
- `scripts/crop.py <in> <out> <top> <bottom>`
- `assets/store-src/` shared.css · frame.html · card.html · feature.html · endcard.html ·
  promo.html · render.sh · capture.sh · bgm.m4a
- `references/` pipeline.md · listing-template.md · release-checklist-template.md · social-brief.md
