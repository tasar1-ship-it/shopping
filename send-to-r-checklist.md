# Send to R — Setup & Test Checklist
App: https://tasar1-ship-it.github.io/shopping/
Direction in this checklist: WIFE sends → RONALD receives. (For the reverse, swap every "your"/"her".)

---

## PART A — Confirm the fixed build is deployed (Mac, 1 minute)

**A1.** Terminal:
```
grep APP_V ~/Downloads/shopping/index.html
```
- ✅ Shows `APP_V='1751…'` (a long number) → new build deployed. Continue to Part B.
- ❌ Shows `APP_V='__BUILD__'` or "No such file" → deploy never completed. Re-run the restore block from the chat, download `index_ios_light.html`, run `deploy`, then repeat A1.

---

## PART B — Get BOTH phones onto the new build (2 minutes)

**B1.** On each phone: fully close the app — swipe it away in the app switcher (home-screen icon) or close the Safari tab completely.

**B2.** Reopen https://tasar1-ship-it.github.io/shopping/

**B3.** Proof the new build loaded: **Shopping and Completed are EMPTY** (the deploy auto-clears them — this is expected, not a bug). Template is untouched.
- ❌ Old items still visible → the phone is still on the cached old version. Close and reopen again.

> ⚠️ **NEVER use Settings → Safari → "Clear History and Website Data"** to force a refresh. It wipes the device ID and silently breaks the pairing — the #1 way this feature dies.

---

## PART C — Check cloud connection (both phones, 10 seconds)

**C1.** Look at the bar under the title: `● My ID: XXXXXX`
- ✅ **Green dot** on both phones → cloud connected. Continue.
- ❌ **Red dot** → Firebase problem. Go to console.firebase.google.com → Realtime Database → Rules → must be `.read: true, .write: true` → Publish. Then B1–B2 again.

---

## PART D — Pairing (the codes)

The rule: **the SENDER's phone stores the RECEIVER's code.** She sends to you → HER phone stores YOUR code.

**D1. Your phone:** read the 6-letter code in the header (`My ID: ______`). Write it down exactly.
> Codes never contain the letters I, L, O or the digits 0, 1 — if you think you see one, you're misreading it.

**D2. Her phone:** go to the **Shopping tab** and **add one item first** (e.g. "test") — the Send buttons only appear when the list has at least one item.

**D3. Her phone:** tap **"Setup Send to R"** (first time) or the **gear icon** next to the Send button (already set up) → type YOUR code → **Save**.

**D4. Verify:** her header now shows `Paired: XXXXXX` — it must match YOUR header's `My ID` **letter for letter**. If it doesn't match → D3 again.

---

## PART E — Live test (30 seconds)

**E1. Your phone:** app open, on screen, Shopping tab.

**E2. Her phone:** with 1–2 test items in Shopping, tap **"Send to R (2)"**.
- ✅ Her phone toasts **"2 items sent!"**
- ❌ "Send failed" → her dot is red → back to Part C.

**E3. Your phone, within ~5 seconds:** toast **"2 items received!"**, items appear in Shopping.
- Nothing after 10 s → press home button, then reopen the app (this triggers a forced inbox check).
- Still nothing → fully close and reopen the app. Items sent are waiting safely in the cloud and are delivered at startup — they are not lost.

**E4.** Still nothing after E3? Take a screenshot of BOTH phones' header bars (dot + My ID + Paired) and send them to Claude. That pinpoints the remaining cause in one look.

---

## Facts to remember

- Items sent while your app is closed are **not lost** — they arrive the next time you open the app. (No push notification possible — it's a web app.)
- Every `deploy` wipes Shopping + Completed on BOTH phones at their next open. Template, pairing, and language always survive.
- Sent items **merge** into the receiver's list — nothing on the receiving phone is overwritten. Duplicates are possible if you both added the same thing.
- Each phone keeps its own lists. Sending copies items; it does not sync lists.
