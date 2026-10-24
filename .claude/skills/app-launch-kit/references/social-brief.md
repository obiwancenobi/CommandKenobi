# Social content hand-off

Prefer the existing `generate-social-content` command/skill if it is installed (Claude: `/generate-social-content`, Kilo: workflow of the same name, OpenCode: `/generate-social-content` if present). Pass a brief with everything below so its platform writers never guess. If it is not installed, write the seven files yourself using its section structure, then do a humanizer pass and a `summary.md` with a two-week calendar.

## Brief fields

- Product one-liner + positioning sentence.
- Platform, price model, ads/IAP, store.
- Feature list, five to eight bullets, with the one or two numbers that make the product concrete.
- Voice file (`~/.claude/voice.md` if present) and which mode: product (launch) vs personal (weekend project).
- Facts sources: spec file, listing copy, the code file for any headline formula.
- Assets with exact paths and dimensions: cards (carousel-ready), promo video (length, portrait, bgm, no voiceover, beat list with timings), feature graphic.
- Store link placeholder `[PLAY LINK]`.
- Timezone for post timing.
- Honest limitations to disclose (Reddit will find them).

## After generation

- Grep the set for one inconsistent placeholder number (the "my score was N" line) and align it.
- Cross-check any cadence/limit claims the writers made against the code (the Reddit writer once caught a stale spec line this way).
- Write `summary.md`: overview table, Week 0 (listing video first so the link resolves), Week 1 launch, Week 2 follow-ups, cross-platform tips.
