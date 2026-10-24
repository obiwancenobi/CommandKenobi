# Release Checklist — Google Play

App: <name> (`<applicationId>`) · Flutter <ver> · first submit at `<version>` · <platforms>.

Tick as you go. Anything unticked in **Blockers** means don't upload yet.

## 1. Blockers — code & config

- [ ] Keystore + AdMob ids + google-services.json gitignored (`git check-ignore -v <file>` for each).
- [ ] **Upload keystore backed up off-machine.** Enrol in Play App Signing as the second net.
- [ ] **Privacy policy URL** live, covering every SDK (AdMob, Firebase) and every sensitive permission.
- [ ] **UMP consent flow** before the first ad request (`grep -rn consent lib/`). Publish GDPR + US-state messages in AdMob → Privacy & messaging.
- [ ] Real AdMob ids in the production build; none start with `ca-app-pub-3940256099942544` (Google test prefix).
- [ ] R8 minify + shrink on release.
- [ ] `targetSdk` meets Play's current floor (check, don't assume).
- [ ] No PII/usage data in release logs (`grep -rn "print(\|log(" lib`).
- [ ] Screenshot/demo build flag can never be on in production (grep the flavor guard).

## 2. Build

- [ ] AAB is newer than the last commit (`stat` it vs `git log -1`). Rebuild with `--obfuscate --split-debug-info=build/symbols`.
- [ ] Upload `build/symbols` to Crashlytics.
- [ ] 16 KB page alignment on the AAB (`android-16kb-compliant` skill).
- [ ] Install the signed production build on a real device (`bundletool build-apks --connected-device`); run the manual pass: onboarding → permissions → every tab → every ad placement → background job survives reinstall.
- [ ] Bump `version: +N` per upload attempt.

## 3. Store assets (`store/`)

- [ ] Title / short / full description — `store/copy/listing-en.md`.
- [ ] Icon 512 — `store/en/app_icon-512.png`.
- [ ] Feature graphic 1024×500 — `store/en/feature-graphic.png`.
- [ ] Screenshots phone ×N, tablet 7"/10" — `store/en/`. Pipeline: `store/src/capture.sh` → `store/src/render.sh`.
- [ ] Promo video — `store/promo/*.mp4` (<30s). Upload to YouTube, paste link.
- [ ] Support email, developer contact, marketing opt-out.
- [ ] Localised listings (only if the UI is localised).

## 4. Google Play console

- [ ] **Data safety form** — must match §5 and the SDKs actually bundled.
- [ ] **Advertising ID declaration** — yes if the Mobile Ads SDK is in.
- [ ] **Sensitive permission declarations** (usage access, accessibility, SMS, location, exact alarm, overlay) with a one-line core-use justification each; screen recording ready if asked.
- [ ] Content rating (IARC).
- [ ] Target audience 13+.
- [ ] Ads declaration. IAP declaration.
- [ ] Category, tags.
- [ ] Play App Signing.
- [ ] Countries.
- [ ] `app-ads.txt` on the developer domain lists the AdMob publisher id.
- [ ] **Internal testing track first**, production after approval.
- [ ] Account deletion URL (N/A if no accounts).

## 5. Post-launch (deferred)

- Mediation after traffic. Localisation. ASO pass after two weeks of data (`aso` skill).

## 6. Notes

- <date>: findings from the code audit that the checklist boxes above depend on.
