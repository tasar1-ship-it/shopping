# Shopping List App — State File
**Updated:** 9 July 2026
**Live URL (permanent):** https://tasar1-ship-it.github.io/shopping/
**GitHub repo:** tasar1-ship-it/shopping (branch main, Pages from root)
**Local repo:** ~/Downloads/shopping/  (holds index.html, manifest.json, icon.svg, deploy.sh)

---

## Where the work last stood

All feature work for this session is complete and verified in code. The only outstanding action is on Ronald's side: deploy the latest files and, for the icon, re-add the home-screen shortcut. Nothing is half-built.

---

## Current design in use
**iOS Light** (Apple Reminders style: light grey #F2F2F7 background, white cards, iOS blue #007AFF accent, black system-font title). Chosen for sunlight readability.

Four design variants exist, all functionally identical — only palette/font differ. Switching = deploy the chosen file:
- `index_ios_light.html` — light, in use
- `index_ios_dark.html` — true black, iOS dark blue
- `index_glass.html` — frosted visionOS style (worst in sunlight)
- `index_tiffany.html` — original dark blue-teal (safety copy of the very first design)

All four are regenerated from the base by `/home/claude/theme.js` (pure palette/font substitution). Edit the base `index.html`, then run theme.js to rebuild all four — never hand-edit a variant.

---

## Feature state (all live in code)

**Two tabs only: Shopping + Completed.** Template tab was removed this session (Ronald never used it). No quantity editor anymore — items default to ×1; a sent "2x eggs" still parses to qty 2.

**Voice:** continuous mode, 350ms fast-commit (Ronald's preferred speed). Guards in place against the "pair/staircase" bug: extension-drop guard (a dying session's extended repeat of a just-committed phrase within 700ms is dropped) + fresh session restart per item. Discipline required: speak each item fluidly, pause only *between* items. Single spoken letters ("A","B","C") get resolved to lookalike words ("Beat","See") by iOS itself — unfixable, use real words.

**Photos:** compressed to 400px JPEG 0.6 (canvas). Attach to next item — works whether the name is typed OR spoken. If camera used with no name yet, a hint shows "Photo ready — type a name". Tap thumbnail = full-screen; tap to dismiss. Photos are local-only (too big for cloud).

**Clear buttons:** subtle muted text-links at the bottom of each list — "Clear list" (Shopping, active items only) and "Clear completed" (Completed). Both show a 3-second bulk "Undo" toast.

**Undo:** single-item undo (3s toast) after check-off, delete, completed-delete; plus the bulk clear undo above.

**Send to R (Firebase inbox):** each device has a random 6-letter ID shown in header with sync dot. Sender stores receiver's ID via "Setup Send to R" / gear. Send writes to inbox/{targetId}; receiver's realtime listener merges items + toasts "N received", then clears inbox. Race fix this session: incoming items buffer until initial load completes (previously the load could overwrite freshly received items); + timestamp dedupe; + foreground re-check on visibilitychange.

**? help button REMOVED** this session (and its showHelp overlay). Standalone /shopping/manual.html still exists in repo but is now OUTDATED (pre-Firebase, mentions Template) — refresh or delete when convenient.

**Version-clear on deploy:** deploy.sh stamps APP_V with a unix timestamp each deploy; on next open each phone clears Shopping+Completed once (Template n/a now, pairing + language preserved). Firebase-resurrection guard prevents the cloud copy restoring the cleared list. THIS WIPES BOTH PHONES' LISTS ON EVERY DEPLOY — including the wife's, mid-shop if timed badly. The manual clear buttons now cover mid-week resets without deploying.

**Icon:** glossy Rosso Corsa (#E00000 gradient, bright top / deep bottom) with a serif white-to-silver capital "S", full-bleed sheen clipped to the rounded badge. Ferrari *colour* only — no logo/marks, no trademark issue. File: icon.svg.

---

## Firebase
- Project: shopping-list-app (Spark/free). DB: shopping-list-app-2bc50, europe-west1 (Belgium).
- databaseURL: https://shopping-list-app-2bc50-default-rtdb.europe-west1.firebasedatabase.app
- Rules: `.read: true, .write: true` (TEST MODE).
- **OPEN RISK:** test-mode rules expire ~30 days after setup (~mid-May 2026 origin; may already be re-published). If the sync dot goes red and stays red, re-publish rules in console, or ask Claude for non-expiring token-based rules.
- SDK: firebase compat v9.23.0 from gstatic CDN.
- Storage keys: localStorage sl3_s (shopping), sl3_l (lang), sl3_devid (device ID), sl3_target (send target), sl3_ver (build stamp). Migrates from old sl2_ keys. Firebase mirrors under devices/{devId} (text only, no photos).

---

## iPhone Safari constraints (do NOT violate when editing)
- JS only runs when hosted on HTTPS — local files opened from Files won't work.
- `var` only (no let/const), `function(){}` only (no arrow functions), no template literals, no `?.` / `??` / spread. Korean text as \uXXXX escapes. All functions at global scope (functions inside try{} break onclick).
- **Standalone PWA mode was REMOVED** this session (apple-mobile-web-app-capable meta + manifest display:standalone → browser). Reason: iOS blocks Web Speech API in standalone PWAs, so dictation died from the home-screen icon. Cost: Safari's bottom bar now shows. Do not re-add standalone mode or voice breaks again.
- iOS Safari tab storage and home-screen-icon storage are SEPARATE identities (different device IDs, different lists). Pick ONE way to open per phone (home-screen icon recommended) and stick to it, or pairing/sync land in the wrong context. This caused earlier Send-to-R failures.

---

## Deploy workflow
1. Edit base `index.html`, run `node /home/claude/theme.js` to rebuild all 4 variants (Claude side).
2. Ronald: `rm -f ~/Downloads/index*.html` (clear strays — deploy picks NEWEST index*.html at Downloads top level, subfolders ignored).
3. Download the chosen variant → it lands in ~/Downloads.
4. `deploy` → stamps APP_V, copies to repo, commits, pushes. Must print "✅ Deployed build …".
5. Both phones: fully close + reopen. New build confirmed when Template tab is absent (it's gone now, so use: lists cleared on open = new build).

**Icon deploys differently** (not an index file — `deploy` ignores it):
```
cp ~/Downloads/icon.svg ~/Downloads/shopping/icon.svg
cd ~/Downloads/shopping && git add icon.svg && git commit -m "icon" && git push
```
Then DELETE + RE-ADD the home-screen icon on each phone (iOS reads icon only at add time; refresh won't update it).

**Repo has vanished from ~/Downloads twice** (Downloads cleanup casualty). deploy.sh is committed to the repo, so recovery is:
```
cd ~/Downloads && [ -d shopping/.git ] || git clone https://github.com/tasar1-ship-it/shopping.git
```
Then re-run the deploy.sh heredoc + `chmod +x`. Consider moving the repo out of ~/Downloads (would require updating the `deploy` alias in ~/.zshrc — change both together).

---

## Open items / next steps
1. Deploy the latest `index_ios_light.html` (clear/undo buttons, ? removed, voice guards, photo-on-voice) — most recent app change awaiting deploy.
2. Deploy the new glossy S `icon.svg` (icon workflow above) + re-add home-screen icons.
3. Firebase test-mode rules expiry — watch the sync dot; switch to token rules when it fails.
4. manifest.json theme_color/background_color still iOS-blue/grey from a prior design; optionally match to the red icon.
5. /shopping/manual.html is outdated — refresh or delete.
6. Send-to-R end-to-end: last live test not yet confirmed passing after the race fix + identity cleanup. Re-run the pairing checklist (send-to-r-checklist.pdf) once both phones are on one identity each.

---

## Deliverables produced this session (in outputs)
- index_ios_light.html / _ios_dark / _glass / _tiffany — 4 design variants
- icon.svg — glossy red S
- send-to-r-checklist.pdf + .md — pairing setup/test guide
- shopping-list-handover.md — earlier (pre-today) handover; this state file supersedes it
