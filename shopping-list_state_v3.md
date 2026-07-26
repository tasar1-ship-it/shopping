# Shopping List App — State File (v3)
**Updated:** 26 July 2026
**Supersedes:** shopping-list_state_v2.md (26 July 2026) and shopping-list_state.md (9 July 2026)
**Live URL (permanent):** https://tasar1-ship-it.github.io/shopping/
**GitHub repo:** tasar1-ship-it/shopping (branch main, Pages from root)
**Local repo:** ~/Downloads/shopping/ — CONFIRMED present 26 July, contains index.html,
manifest.json, icon.svg, deploy.sh

---

## Where the work last stood

Two bugs found and fixed this session, both verified by execution, both in a single file
awaiting deploy: `index_ios_light.html`. Nothing is half-built. One deploy ships both.

---

## FIX 1 — accidental whole-list deletion (fixed, awaiting deploy)

**Symptom reported.** The entire Shopping list was wiped by an accidental tap, with no
confirmation step.

**Cause (CONFIRMED — read from the deployed index.html).** The muted grey "Clear list"
text-link at the bottom of the Shopping tab called `clearShop()` directly on a single tap,
deleting every active item immediately. Only recovery was a 3-second undo toast that is easy
to miss. `clearDone()` on the Completed tab had the identical problem. Both links sit at the
bottom of a scrolled list — exactly where a thumb lands.

**Ruled out as causes.** `chkOff()` and `delShop()` act on a single item only; `rstAll()` only
un-completes items and deletes nothing. No other single-tap path can wipe the list.

**Fix applied.** Both clear functions now route through a new `confirmClear()` modal:
- Centered white dialog on a dark backdrop — deliberately away from the bottom-of-screen link
  that was tapped.
- Shows the count ("Clear all 14 items?") so the scope of the action is visible.
- Cancel (grey) + destructive action (red #FF3B30). Backdrop tap cancels.
- Bilingual EN/KO.
- Existing 3-second bulk undo unchanged and still applies afterward — recovery is now two
  layers, not one.

---

## FIX 2 — Firebase CDN failure killed the entire app (fixed, awaiting deploy)

**Symptom reported.** Console error: `Uncaught ReferenceError: firebase is not defined`.

**Cause (CONFIRMED by executing both scripts with the firebase global absent).** The two
gstatic `<script src>` tags load the Firebase SDK. If they fail — offline, CDN blocked,
network restriction, or any non-HTTPS/file:// preview context — the firebase global does not
exist, and the unguarded `firebase.initializeApp(...)` at the top of the script threw
immediately. That killed the WHOLE script: no `ld()`, no `R()`, blank app. The lists live in
localStorage and need no network at all, so a cloud outage was taking down functionality that
never depended on the cloud.

**Not caused by Fix 1** — the Firebase code was byte-identical between the original and the
tap-fix file (verified by diff).

**Fix applied.** New `fbUp` flag; every Firebase entry point guarded:
- Init wrapped in try/catch, sets `fbUp=false` instead of throwing.
- `ld()` returns to a local-only render path when the cloud is down, so the list still appears.
- `sv()` mirrors to cloud only when up; localStorage always writes.
- `listenInbox()`, the inbox clear in `applyInbox()`, and the visibilitychange foreground
  re-check all no-op when there is no connection.
- `sendToR()` toasts "Offline — cannot send" instead of throwing silently.

**Degraded behaviour when cloud is down:** full local list app — add, check off, delete,
photos, voice, undo, clear confirmation all work. Only cross-phone sending pauses. Red sync
dot signals the state. Reopening after connectivity returns resyncs.

**Verification (CONFIRMED, not asserted).** A test harness ran the app script with the firebase
global deliberately never defined:
- Original file: crashes, `firebase is not defined` — reproduces the reported error exactly.
- Fixed file: `fbUp=false`, `loadDone=true`, 3 items loaded from localStorage, both test items
  present in rendered HTML, `sync-off` (red dot) class present.

---

## Deploy state of these fixes

**Build stamp deliberately NOT changed.** `APP_V` remains `1783617397`, and the file contains
zero occurrences of `__BUILD__`, so `deploy.sh`'s sed step is a no-op. Consequence: this deploy
will NOT wipe either phone's list — chosen deliberately given a list was just lost. Pairing and
language also survive.

**Verification of this deploy is therefore NON-STANDARD.** The usual proof ("lists cleared on
open = new build") does NOT apply. Instead: tap "Clear list" — the confirmation dialog
appearing is the proof the new build is live.

**Deploy sequence:**
```
rm -f ~/Downloads/index*.html
```
download `index_ios_light.html` (lands in ~/Downloads), then:
```
deploy
```
Wait for `✅ Deployed build …`, then fully close + reopen the app on both phones.

---

## OPEN RISK — theme.js will silently revert BOTH fixes

These are JS-logic changes, not palette/font changes. The four design variants are regenerated
from the base `index.html` by `/home/claude/theme.js` (pure palette/font substitution). If
theme.js is re-run before the same changes are applied to the BASE index.html, both fixes
disappear from all variants with no error.

The base index.html and theme.js were NOT available in this session — only the deployed light
variant was uploaded. **Action required before any future theme.js run — port all of this into
the base file first:**
1. The `.confirm-box` / `.confirm-msg` / `.confirm-sub` / `.confirm-row` / `.confirm-cancel` /
   `.confirm-yes` CSS block.
2. The `confirmClear()` function and the rewritten `clearShop()` / `clearDone()`.
3. The `fbUp` flag, the guarded Firebase init block, and the guards at all seven `db.ref`
   call sites plus `listenInbox()`'s early return.

---

## Current design in use
**iOS Light** (Apple Reminders style: light grey #F2F2F7 background, white cards, iOS blue
#007AFF accent, black system-font title). Chosen for sunlight readability.

Four variants exist, functionally identical, palette/font only:
- `index_ios_light.html` — light, in use
- `index_ios_dark.html` — true black, iOS dark blue
- `index_glass.html` — frosted visionOS style (worst in sunlight)
- `index_tiffany.html` — original dark blue-teal (safety copy of the first design)

Never hand-edit a variant — edit the base, then rebuild.

---

## Feature state (all live in code)

**Two tabs only: Shopping + Completed.** Template tab removed. No quantity editor — items
default to x1; a sent "2x eggs" still parses to qty 2.

**Voice:** continuous mode, 350ms fast-commit. Guards against the pair/staircase bug:
extension-drop guard (dying session's extended repeat within 700ms is dropped) + fresh session
restart per item. Discipline: speak each item fluidly, pause only BETWEEN items. Single spoken
letters get resolved to lookalike words by iOS itself — unfixable, use real words.

**Photos:** compressed to 400px JPEG 0.6. Attach to next item, typed or spoken. Camera with no
name yet shows "Photo ready — type a name". Tap thumbnail = full-screen. Local-only (too large
for cloud).

**Clear buttons:** muted text-links at the bottom of each list — "Clear list" (Shopping, active
items only) and "Clear completed". **Both now require confirmation (Fix 1)**, then show a
3-second bulk Undo toast.

**Undo:** single-item undo (3s toast) after check-off, delete, completed-delete; plus the bulk
clear undo above.

**Send to R (Firebase inbox):** each device has a random 6-letter ID shown in header with sync
dot. Sender stores receiver's ID via "Setup Send to R" / gear. Send writes to inbox/{targetId};
receiver's realtime listener merges items + toasts "N received", then clears inbox. Race fix:
incoming items buffer until initial load completes; timestamp dedupe; foreground re-check on
visibilitychange. **Now fails gracefully offline (Fix 2).**

**? help button REMOVED.** Standalone /shopping/manual.html still in repo but OUTDATED
(pre-Firebase, mentions Template) — refresh or delete when convenient.

**Version-clear on deploy:** deploy.sh stamps APP_V with a unix timestamp on each deploy where
the placeholder `__BUILD__` is present; on next open each phone clears Shopping + Completed once
(pairing + language preserved). Firebase-resurrection guard prevents the cloud copy restoring
the cleared list. When active, this wipes BOTH phones' lists — including the partner's, mid-shop
if badly timed. The manual clear buttons cover mid-week resets without deploying.

**Icon:** glossy Rosso Corsa (#E00000 gradient) with a serif white-to-silver capital "S",
full-bleed sheen clipped to the rounded badge. Colour only — no marks, no trademark issue.
File: icon.svg.

---

## Firebase
- Project: shopping-list-app (Spark/free). DB: shopping-list-app-2bc50, europe-west1 (Belgium).
- databaseURL: https://shopping-list-app-2bc50-default-rtdb.europe-west1.firebasedatabase.app
- Rules: `.read: true, .write: true` (TEST MODE).
- **OPEN RISK:** test-mode rules expire ~30 days after setup. If the sync dot goes red and stays
  red, re-publish rules in console, or switch to non-expiring token-based rules / Anonymous Auth.
- SDK: firebase compat v9.23.0 from gstatic CDN, loaded via two `<script src>` tags. **This CDN
  is a single point of failure for all cloud features** — now guarded so it no longer takes the
  whole app down (Fix 2).
- Storage keys: localStorage sl3_s (shopping), sl3_l (lang), sl3_devid (device ID), sl3_target
  (send target), sl3_ver (build stamp). Migrates from old sl2_ keys. Firebase mirrors under
  devices/{devId} (text only, no photos).

**Diagnosing a red dot after this deploy:** red dot means cloud unreachable, and there are now
two distinct causes to separate — (a) SDK never loaded, which used to blank the app and now
degrades gracefully, or (b) SDK loaded but the database rejected the connection, which points
at the test-mode rules expiry above. A console check for `firebase is not defined` distinguishes
them: present = (a), absent = (b).

---

## iPhone Safari constraints (do NOT violate when editing)
- JS only runs when hosted on HTTPS — local files opened from Files won't work. A local/file://
  preview is also the most common benign source of the `firebase is not defined` console error.
- `var` only (no let/const), `function(){}` only (no arrow functions), no template literals,
  no `?.` / `??` / spread. Korean text as \uXXXX escapes. All functions at global scope
  (functions inside try{} break onclick). **Note:** the Fix 2 guards deliberately wrap only
  CALLS in try{}, never function declarations, to preserve this rule.
- **Standalone PWA mode was REMOVED** (apple-mobile-web-app-capable meta + manifest
  display:standalone → browser). Reason: iOS blocks Web Speech API in standalone PWAs, so
  dictation died from the home-screen icon. Cost: Safari's bottom bar shows. Do not re-add
  standalone mode or voice breaks again.
- iOS Safari tab storage and home-screen-icon storage are SEPARATE identities (different device
  IDs, different lists). Pick ONE way to open per phone (home-screen icon recommended) and stick
  to it, or pairing/sync land in the wrong context. This caused earlier Send-to-R failures.
- Never use Settings → Safari → "Clear History and Website Data" to force a refresh. It wipes
  the device ID and silently breaks pairing.

---

## Deploy workflow
1. Edit base `index.html`, run `node /home/claude/theme.js` to rebuild all 4 variants
   (Claude side).
2. Ronald: `rm -f ~/Downloads/index*.html` (clear strays — deploy picks NEWEST index*.html at
   Downloads top level, subfolders ignored; the copy inside shopping/ is correctly ignored).
3. Download the chosen variant → it lands in ~/Downloads.
4. `deploy` → stamps APP_V (only if `__BUILD__` present), copies to repo, commits, pushes.
   Must print "✅ Deployed build …".
   - "❌ No index*.html found in Downloads" → the download didn't land, repeat step 3.
   - "⚠️ No changes to deploy" → git saw an identical file, the download didn't overwrite.
   - Error on `cp` → repo missing from Downloads, see recovery below.
5. Both phones: fully close + reopen.

**Icon deploys differently** (not an index file — `deploy` ignores it):
```
cp ~/Downloads/icon.svg ~/Downloads/shopping/icon.svg
cd ~/Downloads/shopping && git add icon.svg && git commit -m "icon" && git push
```
Then DELETE + RE-ADD the home-screen icon on each phone (iOS reads icon only at add time).

**Repo has vanished from ~/Downloads twice** (Downloads cleanup casualty), though it was
CONFIRMED present on 26 July. Everything is pushed to GitHub, so a vanished local copy costs a
re-clone, never work. Recovery:
```
cd ~/Downloads && [ -d shopping/.git ] || git clone https://github.com/tasar1-ship-it/shopping.git
```
Then re-run the deploy.sh heredoc + `chmod +x`. Optional hardening: move the repo out of
~/Downloads — requires changing `REPO=` in deploy.sh AND the `deploy` alias in ~/.zshrc together
(the script lives inside the repo). Leave `DL=~/Downloads` alone; that's where the browser drops
the file and is correct.

---

## Open items / next steps
1. **Deploy `index_ios_light.html`** — carries BOTH fixes. Highest priority: the list-loss bug
   and the blank-app-on-CDN-failure bug are both live in production until this ships. Verify by
   tapping "Clear list" and seeing the dialog (NOT by checking whether lists cleared).
2. **Port both fixes into the BASE index.html** before theme.js is ever re-run — see the
   three-item porting list under OPEN RISK above.
3. **If the sync dot is red after deploying**, use the (a)/(b) diagnosis under Firebase above.
   Likely the test-mode rules expiry — resolve by re-publishing rules or moving to Anonymous
   Auth / token rules.
4. Deploy the glossy S `icon.svg` (icon workflow above) + re-add home-screen icons.
5. manifest.json theme_color/background_color still iOS-blue/grey from a prior design;
   optionally match to the red icon.
6. /shopping/manual.html is outdated — refresh or delete.
7. Send-to-R end-to-end: last live test not yet confirmed passing after the race fix + identity
   cleanup. Re-run the pairing checklist (send-to-r-checklist.pdf) once both phones are on one
   identity each. Pairing survives this deploy, so the test can run immediately after.

---

## Deliverables produced this session (in outputs)
- `index_ios_light.html` — clear-confirmation gate + Firebase hardening, awaiting deploy
- `shopping-list_state_v3.md` — this file, supersedes v2 and the 9 July original
