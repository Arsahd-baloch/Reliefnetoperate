# Agent Role Testing Playbook — DisasterAid.pk V2.1

Read this document fully before starting any role journey. It contains everything needed to automate
screenshot capture and feature testing for any role in the app. The donor journey was completed first
and serves as the reference implementation — replicate that pattern for each role.

---

## 1. Environment

### Device
- **Model**: Vivo V2229
- **ADB device ID**: `10FCBM01BZ0001B`
- **Physical resolution**: 720×1600 px
- **Usable content area**: 720×1524 px (gesture nav bar at y=1524–1600)
- **All ADB tap coordinates use physical pixels** (720×1600 space)

### Services (must be running before testing)
```bash
# Backend — check if running
ps aux | grep "nodemon\|tsx" | grep -v grep

# Start backend if needed
cd /home/arshad/finalfinal/arshi/Deploye_app/backend
npm run dev > /tmp/backend.log 2>&1 &

# ADB tunnel so device can reach localhost:3000
adb reverse tcp:3000 tcp:3000

# Verify device connected
adb devices
```

### Flutter App Package
```
com.example.reliefnet_app
```

---

## 2. Test User Credentials (all use password `password123`)

| Role | Email | Display Name |
|------|-------|--------------|
| DONOR | `rich@donor.pk` | Whale Donor |
| DONOR (alt) | `m1@donor.pk` | Micro Donor 1 |
| BENEFICIARY | `zia@needs.pk` | Zia Flood Victim |
| BENEFICIARY (alt) | `fatima@needs.pk` | Fatima Medical |
| VOLUNTEER | `ahmed@volunteer.pk` | Ahmed Khan |
| VOLUNTEER (alt) | `sara@volunteer.pk` | Sara Bibi |
| NGO | `contact@redcross.pk` | Red Cross PK |
| NGO (alt) | `info@edhi.org` | Edhi Foundation |
| COORDINATOR | `c1@field.pk` | Field Lead C1 |
| COORDINATOR (alt) | `c2@field.pk` | Audit Lead C2 |
| ADMIN | `admin@disasteraid.pk` | System Admin |
| ADMIN (finance) | `finance@disasteraid.pk` | Finance Admin |

> All passwords are `password123`. The login screen is at `/login`.

---

## 3. Build & Install Flutter App

Only rebuild when you change Flutter code. If the app is already installed and you haven't changed code,
skip directly to **Section 5 (Login)**. Auth tokens persist across reinstalls via `flutter_secure_storage`.

```bash
cd /home/arshad/finalfinal/arshi/Deploye_app/flutter_app

# Always run analyze first — must show 0 issues
flutter analyze

# Build debug APK (~75 seconds)
flutter build apk --debug

# Install on device
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## 4. Launch App

```bash
# Launch (causes full app restart — loses auth session if token was in memory only,
# but flutter_secure_storage persists, so usually stays logged in)
adb shell monkey -p com.example.reliefnet_app -c android.intent.category.LAUNCHER 1 2>/dev/null

# Wait for app to fully load
sleep 6
```

> **Warning**: After `monkey` launch the app sometimes shows the Campaigns screen immediately
> (if auth token is still valid) or the Login screen (if token expired or first install).

---

## 5. Login Automation

```bash
# Take a screenshot first to confirm which screen is showing
adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png /tmp/current.png

# Login flow: tap email field, type email, tab to password, type password, tap Sign In
adb shell input tap 360 600        # tap email field (approx — use UIAutomator if off)
sleep 0.5
adb shell input text "rich@donor.pk"
adb shell input keyevent 61        # TAB to password field
sleep 0.5
adb shell input text "password123"
adb shell input keyevent 111       # dismiss keyboard (KEYCODE_ESCAPE)
sleep 0.5

# Get exact Sign In button position first with UIAutomator, or try:
adb shell input tap 360 900        # approximate Sign In button position
sleep 4                            # wait for auth + navigation
```

> **Better approach**: Use UIAutomator to find exact field bounds (see Section 7).

---

## 6. Screenshot Capture

### Standard capture command
```bash
# IMPORTANT: /sdcard/ path FAILS on this device (exit code 1, empty file).
# Always use /data/local/tmp/ instead:
adb shell "screencap -p /data/local/tmp/cap.png" && adb pull /data/local/tmp/cap.png /path/to/output.png
```

> **Device-specific**: The Vivo V2229 does not allow writing to `/sdcard/` via ADB screencap.
> Using `/sdcard/screen.png` silently creates an empty file. Always use `/data/local/tmp/cap.png`.

### Create screenshot folder
```bash
mkdir -p /home/arshad/finalfinal/arshi/Deploye_app/<role>_screenshots/
```

### Naming convention
`01_screen_name.png`, `02_next_screen.png` — sequential with descriptive suffix.

### Wait for data to load
Always `sleep 2–4` after navigation before screenshotting. If you see shimmer/loading state,
wait longer and retake.

---

## 7. UIAutomator — Finding Exact Tap Coordinates

**Always use UIAutomator** when a button tap doesn't work. Visual position in screenshots
does NOT match actual touch bounds.

```bash
# Dump the UI tree (use /data/local/tmp/ — NOT /sdcard/ which may not be writable)
adb shell "uiautomator dump /data/local/tmp/ui.xml"
adb pull /data/local/tmp/ui.xml /tmp/ui.xml

# Search for a widget by keyword
grep -i "keyword" /tmp/ui.xml
# The bounds format is: bounds="[x1,y1][x2,y2]"
# Tap center: x = (x1+x2)/2, y = (y1+y2)/2
```

### Example — finding a submit button:
```bash
grep -i "submit\|sign in\|donate\|confirm" /tmp/ui.xml | grep "clickable=\"true\""
```

> **Note**: `uiautomator dump` on this device prints a Java exception about `/sys/board_info/user_cpu_freq`
> (EACCES) before the dump. This is a harmless Vivo system warning — the dump still succeeds.
> Look for "UI hierchary dumped to: /data/local/tmp/ui.xml" as confirmation.

---

## 8. Bottom Navigation Tab Coordinates

These are **confirmed physical pixel coordinates** from UIAutomator:

### DONOR role (5 tabs)
| Tab | Bounds | Center tap |
|-----|--------|------------|
| Campaigns (tab 1) | [0,1420][144,1524] | `adb shell input tap 72 1472` |
| Donations (tab 2) | [144,1420][288,1524] | `adb shell input tap 216 1472` |
| InKind (tab 3) | [288,1420][432,1524] | `adb shell input tap 360 1472` |
| Impact (tab 4) | [432,1420][576,1524] | `adb shell input tap 504 1472` |
| More (tab 5) | [576,1420][720,1524] | `adb shell input tap 648 1472` |

### VOLUNTEER role (5 tabs)
Tabs: Impact (Dashboard) | Discover (Tasks) | My Tasks | Messages | More  
Bounds follow same pattern: divide [0,1420][720,1524] into 5 equal slots of 144px each.
Center x values: 72, 216, 360, 504, 648 — all at y=1472.

### BENEFICIARY role (4 tabs)
Tabs: Home | Requests | Aid Board | More  
Divide 720px into 4 = 180px each. Center x values: 90, 270, 450, 630 — all at y=1472.

### NGO role (4 tabs)
Tabs: Dashboard | Campaigns | Impact | More  
Same 4-tab layout as Beneficiary. Center x values: 90, 270, 450, 630 — all at y=1472.

### COORDINATOR role (5 tabs)
Tabs: Tasks | Review | Intelligence | Volunteers | More  
Same 5-tab layout as Donor. Center x values: 72, 216, 360, 504, 648 — all at y=1472.

> **Always verify with UIAutomator** after first install — these may shift by 1–2 px.

### Campaign tabs (within Campaigns screen for Donor)
- Money tab (left): [0,165][360,257] → center `adb shell input tap 180 211`
- Goods (In-Kind) tab (right): [360,165][720,257] → center `adb shell input tap 540 211`

---

## 9. FAB Positions

| Role | FAB Label | When Visible | Confirmed Bounds |
|------|-----------|--------------|------------------|
| DONOR | "Donate Item" | InKind tab ONLY (guarded by route `/donor/inkind`) | [409,1285][690,1390] |
| BENEFICIARY | "New Request" | Home and Tasks tabs | Verify with UIAutomator |
| NGO | "New Campaign" | Campaigns tab | Verify with UIAutomator |

> FAB visual position in screenshots ≠ actual touch bounds. ALWAYS use UIAutomator to get
> actual bounds before tapping. The FAB was at [409,1285][690,1390] for donor even though
> it appeared visually lower.

---

## 10. Text Input — Handling Spaces

ADB `input text` encodes spaces as `%20`, causing garbled text.

### Wrong (produces "word1%20word2"):
```bash
adb shell input text "word1 word2"
```

### Correct (use KEYCODE_SPACE between words):
```bash
adb shell input text "word1"
adb shell input keyevent 62    # KEYCODE_SPACE
adb shell input text "word2"
```

### Useful keycodes
| Code | Effect |
|------|--------|
| `adb shell input keyevent 62` | Space |
| `adb shell input keyevent 111` | Escape (dismiss keyboard) |
| `adb shell input keyevent 4` | Back (dismisses keyboard if open, then navigates back) |
| `adb shell input keyevent 61` | Tab (move to next field) |
| `adb shell input keyevent 66` | Enter |

---

## 11. Keyboard Handling

The keyboard blocks buttons below it. When Submit/Continue is greyed or hidden:

1. **Try dismissing with Escape**: `adb shell input keyevent 111`
2. **Try tapping the keyboard's down-arrow**: Appears at approximately (108, 1492) when keyboard is shown
3. **Try pressing Back once**: `adb shell input keyevent 4` — dismisses keyboard if field is focused without navigating away
4. **Tap the button above the keyboard**: When keyboard is visible, buttons in the form shift up. Use UIAutomator dump to find button bounds WITH keyboard showing, then tap adjusted y position.

> The keyboard height is approximately 600px on this device. The viewport with keyboard = 1524 - 600 = ~924px usable.

---

## 12. Photo/Image Upload Testing

### How image upload works in this app
- Forms with image upload show an "Add Photo" / "Add Item Photo" area
- Tapping it opens the Android system photo picker (`com.google.android.providers.media.module`)
- Selected photo is uploaded as `multipart/form-data` to the backend
- Backend stores file at: `backend/uploads/<uuid>.jpg`
- Backend serves it at: `http://localhost:3000/api/media/files/<uuid>.jpg`
- URL is saved to the relevant DB column (e.g., `goods_donations.photo_url`)

### Automation steps
```bash
# 1. Tap the photo picker area (use UIAutomator to find exact bounds)
adb shell input tap 354 320    # approximate — verify with UIAutomator

# 2. Wait for picker to open
sleep 2

# 3. If "Backed up photos now included" Google Photos dialog appears:
#    Dismiss button is at [227,1080][392,1170]
adb shell input tap 309 1125

# 4. Wait for photos grid to load
sleep 2

# 5. Recent photos appear at bottom: first 3 at y=1292–1524
#    Photo 1: [0,1292][236,1524] → center (118, 1408)
#    Photo 2: [242,1292][478,1524] → center (360, 1408)
#    Photo 3: [484,1292][720,1524] → center (602, 1408)
adb shell input tap 118 1408

# 6. Wait for picker to close and photo to appear in form
sleep 3
```

### Verifying upload in backend
```bash
# Check uploads folder for new files
ls -la /home/arshad/finalfinal/arshi/Deploye_app/backend/uploads/

# Check DB (example for goods_donations)
PGPASSWORD=disasteraid_password psql -U disasteraid_user -d disasteraid \
  -c "SELECT id, photo_url, updated_at FROM goods_donations ORDER BY id DESC LIMIT 3;"
```

---

## 13. GPS / Location Testing

Forms with "Use Current Location" button:

```bash
# Tap the button (approximate y — verify with UIAutomator)
adb shell input tap 360 1010
sleep 4    # GPS takes 3–5 seconds

# Verify location was filled:
adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png /tmp/check.png
# Should show address text in the Pickup address field + "Location confirmed" with green checkmark
```

> The test device is in **Gujrat, Punjab, Pakistan**. GPS returns "Badshahi Road, New Shadman Colony, Gujrat..."

---

## 14. Backend Database Queries

```bash
# Template
PGPASSWORD=disasteraid_password psql -U disasteraid_user -d disasteraid -c "SELECT ..."

# Common queries
# All campaigns
SELECT id, title, type, status, raised_pkr, goal_pkr FROM campaigns ORDER BY id;

# Donations for a user
SELECT d.id, d.amount_pkr, d.status, c.title FROM donations d JOIN campaigns c ON d.campaign_id = c.id WHERE d.donor_id = 500;

# Tasks
SELECT id, title, status, assigned_volunteer_id FROM tasks ORDER BY id DESC LIMIT 10;

# Goods donations
SELECT id, item_name, photo_url, status, pickup_address FROM goods_donations ORDER BY id DESC LIMIT 5;

# InKind listings
SELECT id, title, category, status, donor_id FROM inkind_donations ORDER BY id DESC LIMIT 5;

# NGO withdrawals
SELECT id, amount_pkr, status, ngo_id FROM withdrawals ORDER BY id DESC LIMIT 5;
```

---

## 15. App Navigation — Role Home Routes

Each role lands on a different home screen after login:

| Role | Home Route | First Screen |
|------|-----------|--------------|
| DONOR | `/donor/campaigns` | Campaigns (Money tab) |
| BENEFICIARY | `/beneficiary/home` | Home dashboard |
| VOLUNTEER | `/volunteer/dashboard` | Impact/Activity dashboard |
| NGO | `/ngo/dashboard` | NGO dashboard |
| COORDINATOR | `/coordinator/tasks` | Tasks list |
| ADMIN | `/dashboard` | Admin dashboard |

---

## 16. More Sheet Contents (per role)

The "More" tab opens a bottom sheet. Contents vary by role.  
Confirmed for DONOR: Avatar + name/role → Activity Feed → Followed Campaigns → Sign out  
For other roles, tap More tab, dump UIAutomator to discover items.

### More sheet item approximate y-positions (bottom sheet starts ~y=950):
- User avatar/name row: y ≈ 1020
- First menu item: y ≈ 1120–1185
- Second menu item: y ≈ 1280–1340
- Third menu item (if exists): y ≈ 1380–1420
- Sign out: last item before bottom

---

## 17. Common Pitfalls

| Problem | Cause | Fix |
|---------|-------|-----|
| Tap does nothing | Wrong coordinates | Use UIAutomator dump to get real bounds |
| Text has `%20` | `input text` encodes spaces | Use `keyevent 62` between words |
| Submit button disabled | Required field empty | Fill all `*` fields first |
| Keyboard covers button | Soft keyboard open | Dismiss with `keyevent 4` or `keyevent 111` |
| App shows login after monkey | Session lost | Re-login with credentials |
| Photos not loading in picker | Google Photos dialog blocking | Tap Dismiss at (309, 1125) |
| Shimmer persists | Backend not running / 401 | Check backend PID, check token |
| FAB not responding | Tap inside gap above nav bar | Use UIAutomator to find real FAB bounds |
| Flutter overflow warning | Widget layout issue | Fix with Expanded/Flexible, rebuild APK |
| 403 on API call | Role not authorized | Check backend route's `authorize()` middleware |

---

## 18. Role-Specific Screen Sequences

For each role, capture these screens in order. Name them `01_...` to `NN_...`.

---

### BENEFICIARY (`zia@needs.pk` / `password123`)

Nav: Home | Requests | Aid Board | More  
FAB: "New Request" (on Home and Requests tabs)

| # | Screen | How to reach |
|---|--------|--------------|
| 01 | Login screen | Fresh launch |
| 02 | Home/Dashboard | After login — `/beneficiary/home` |
| 03 | My Requests (Requests tab) | Tab 2 |
| 04 | Create Task form | Tap FAB "New Request" |
| 05 | Task submitted confirmation | Submit form |
| 06 | Task detail | Tap a task card |
| 07 | Edit Task form | Tap edit on task detail |
| 08 | Aid Board (InKind listings) | Tab 3 — `/beneficiary/inkind` |
| 09 | Aid Board item detail | Tap an InKind listing |
| 10 | Emergency Request form | More sheet → Emergency Request |
| 11 | More sheet | Tab 4 |

---

### VOLUNTEER (`ahmed@volunteer.pk` / `password123`)

Nav tab coords: Impact(72,1472) | Discover(216,1472) | MyTasks(360,1472) | Messages(504,1472) | More(636,1472)  
FAB: None (volunteers don't have a FAB)

**Pre-requisite DB fix**: Ahmed may have status='BUSY' if he has multiple in-progress tasks.
```sql
UPDATE volunteer_profiles SET status = 'ACTIVE' WHERE user_id = 300;
```

**Image upload flow (no Cloudinary)**:
1. Tap Upload Proof on any IN_PROGRESS task
2. Tap Add Delivery Photos → Gallery option at bounds [0,1450][720,1524] → center (360,1487)
3. Photo picker opens — tap first photo at bounds [0,976][236,1212] → center (118,1094)
4. "Confirm & Submit Proof" button at bounds [30,1443][690,1524] → center (360,1483)
5. App POSTs to `/api/media/upload` (201) then `/api/deliveries` (201) → "Delivery Confirmed!" screen

**Completed journey** (screenshots in `volunteer_screenshots/`):

| # | Screen | How to reach | Screenshot |
|---|--------|--------------|------------|
| 01 | Login screen | Fresh launch | `01_login_screen.png` |
| 02 | Impact Dashboard | After login | `02_impact_dashboard.png` |
| 03 | Discover Tasks | Tab 2 | `03_discover_tasks.png` |
| 04 | Task detail (available) | Tap task card | `04_task_detail_available.png` |
| 05 | Task claimed | Tap "Claim This Task" | `05_task_claimed.png` |
| 06 | My Tasks (IN_PROGRESS) | Tab 3 | `08_my_tasks.png` |
| 07 | Active task detail | Tap task card title | `09b_task_detail.png` |
| 08 | Submit proof screen | "Upload Proof of Completion" button | `09_submit_proof_screen.png` |
| 09 | Proof ready (photo + GPS) | Select photo from Gallery | `10_proof_ready_to_submit.png` |
| 10 | Delivery Confirmed! | Tap "Confirm & Submit Proof" | `11_delivery_confirmed.png` |
| 11 | Task Submitted status | After "Done" | `12_task_submitted_status.png` |
| 12 | Chat screen | "Open Coordination Chat" | `13_chat_screen.png` |
| 13 | Chat with message sent | Type + send | `14_chat_message_sent.png` |
| 14 | Messages list | Tab 4 | `15_messages_list.png` |
| 15 | More sheet | Tab 5 | `16_more_sheet.png` |
| 16 | My Profile | More → My Profile | `17_my_profile.png` |
| 17 | Activity History | More → Activity Timeline | `18_activity_history.png` |
| 18 | Discover Tasks (loaded) | Tab 2 | `19_discover_tasks.png` |
| 19 | Task claim screen | Tap task → Claim This Task | `20_task_claim_screen.png` |
| 20 | Task claimed success | Tap Claim | `21_task_claimed.png` |

---

### NGO (`contact@redcross.pk` / `password123`)

Nav: Dashboard | Campaigns | Impact | More  
FAB: "New Campaign" (on Dashboard + Campaigns tabs only)  
Screenshots: `ngo_screenshots/`

#### Confirmed nav tab coordinates (from UIAutomator)
| Tab | Bounds | Center tap |
|-----|--------|------------|
| Dashboard | [0,1420][180,1524] | `adb shell input tap 90 1472` |
| Campaigns | [180,1420][360,1524] | `adb shell input tap 270 1472` |
| Impact | [360,1420][540,1524] | `adb shell input tap 450 1472` |
| More | [540,1420][720,1524] | `adb shell input tap 630 1472` |

#### Campaigns screen — inner filter tabs (from UIAutomator)
| Tab | Bounds | Center tap |
|-----|--------|------------|
| All | [0,165][180,257] | `adb shell input tap 90 211` |
| Active | [180,165][360,257] | `adb shell input tap 270 211` |
| Paused | [360,165][540,257] | `adb shell input tap 450 211` |
| Draft | [540,165][720,257] | `adb shell input tap 630 211` |

#### FAB position
`[370,1285][690,1390]` → center `adb shell input tap 530 1337`

#### Dashboard Quick Action confirmed bounds
| Action | Bounds | Center tap |
|--------|--------|------------|
| My Campaigns | [30,531][690,698] | `adb shell input tap 360 614` |
| Donation Verification | [30,716][690,866] | `adb shell input tap 360 791` |
| Detailed Impact Dashboard | [30,885][690,1052] | `adb shell input tap 360 968` |
| Request Withdrawal | [30,1071][690,1221] | `adb shell input tap 360 1146` |
| NGO Settings | [30,1239][690,1406] | `adb shell input tap 360 1322` |

#### Bugs fixed during NGO journey
| File | Bug | Fix |
|------|-----|-----|
| `flutter_app/lib/core/shell/dashboard_shell.dart` | More sheet role label used `role?.name` (Dart enum name = "ngo") → displayed as "Ngo" | Changed to `role?.value` with smart title-case: words ≤3 chars keep uppercase (NGO), longer words title-cased (Coordinator, Volunteer) |
| `flutter_app/lib/core/shell/dashboard_shell.dart` | NGO FAB showed on Settings/Withdrawal/Report screens, overlapping the Save button | Added route guard: `if (!loc.startsWith('/ngo/campaigns') && !loc.startsWith('/ngo/dashboard')) return null` |
| `flutter_app/lib/screens/ngo/ngo_dashboard_screen.dart` | Quick Action taps used `context.push()` — shell FAB state not updated on navigation, causing FAB to persist on sub-screens | Changed all Quick Action nav calls to `context.go()` so shell properly re-evaluates `matchedLocation` |

#### Full screen sequence (15 screenshots)

| # | Screen | How to reach | Key tap | Screenshot |
|---|--------|--------------|---------|------------|
| 01 | Login screen | Fresh launch / sign out | — | `01_login_screen.png` |
| 02 | NGO Dashboard (stats loaded) | After login → `/ngo/dashboard` | auto-route | `02_ngo_dashboard.png` |
| 03 | Campaigns list (Active tab) | Tap Campaigns nav tab | `adb shell input tap 270 1472` | `03_campaigns_list.png` |
| 03b | Campaigns list (All tab) | Tap All filter tab | `adb shell input tap 90 211` | `03b_campaigns_all_tab.png` |
| 04 | Create Campaign form (empty) | Tap "+ New Campaign" FAB | `adb shell input tap 530 1337` | `04_create_campaign_form.png` |
| 05 | Campaign created (snackbar) | Fill form + tap Create Campaign | fill + `adb shell input tap 354 940` | `05_campaign_created.png` |
| 06 | Campaign Report | Tap Report on a campaign card | `adb shell input tap 581 886` (Orphan Education Fund) | `06_campaign_report.png` |
| 07 | Dispatch Task form | Campaign Report → "+ Dispatch Task" | `adb shell input tap 531 669` | `07_dispatch_task_form.png` |
| 08 | Impact Dashboard | Tap Impact nav tab | `adb shell input tap 450 1472` | `08_impact_dashboard.png` |
| 08b | Impact Dashboard scrolled (Export Summary) | Scroll down | `adb shell input swipe 360 1200 360 700 400` | `08b_impact_share.png` |
| 09 | Donation Verification | Dashboard → Donation Verification | `adb shell input tap 360 791` | `09_donation_verification.png` |
| 10 | Withdrawal Requests | Dashboard → Request Withdrawal | `adb shell input tap 360 1146` | `10_withdrawal_requests.png` |
| 11 | NGO Settings (no FAB) | Dashboard → NGO Settings | `adb shell input tap 360 1322` | `11_ngo_settings.png` |
| 12 | More sheet ("NGO" label fixed) | Tap More nav tab | `adb shell input tap 630 1472` | `12_more_sheet.png` |
| 13 | Campaigns — Draft tab | Campaigns → Draft tab | `adb shell input tap 630 211` | `13_campaigns_draft_tab.png` |

#### Notes
- Campaign creation flow: fill Title + Goal (min Rs 1,000) → "Create Campaign" → navigates to Campaigns list with green snackbar "Campaign created! It is pending admin approval." New campaign appears with "Draft" status badge.
- Campaign Report screen shows: Raised/Spent/Remaining stats, Fund Utilization %, Task Fulfillment grid (Completed/In Progress/Total), Transparency Rating score.
- Donation Verification: shows pending BANK_TRANSFER donations with Manual Transfer Ref. NGO taps "Confirm Receipt" or "Reject". Filter tabs: Confirmed | Rejected.
- Withdrawal Requests: NGO enters Amount + Bank Account Details → "Request Withdrawal". Existing requests show status badge (Approved/Pending).
- NGO Settings: shows Pending Verification banner (admin must verify NGO). Fields: Org Name, Bank/Provider Name, Account Title, Account Number/Mobile.

---

### COORDINATOR (`c1@field.pk` / `password123`)

Nav: Tasks | Review | Intelligence | Volunteers | More  
FAB: None  
Screenshots: `coordinator_screenshots/`  
User DB ID: 600

#### Confirmed nav tab coordinates (from UIAutomator)
| Tab | Bounds | Center tap |
|-----|--------|------------|
| Tasks | [0,1420][144,1524] | `adb shell input tap 72 1472` |
| Review | [144,1420][288,1524] | `adb shell input tap 216 1472` |
| Intelligence | [288,1420][432,1524] | `adb shell input tap 360 1472` |
| Volunteers | [432,1420][576,1524] | `adb shell input tap 504 1472` |
| More | [576,1420][720,1524] | `adb shell input tap 648 1472` |

#### Confirmed login field coordinates
| Field | Bounds | Center tap |
|-------|--------|------------|
| Email field | [45,654][675,750] | `adb shell input tap 360 702` |
| Password field | [45,780][675,876] | `adb shell input tap 360 828` |
| Sign In button | [45,928][675,1026] | `adb shell input tap 360 977` |

#### Login sequence
```bash
adb shell input tap 360 702          # tap email field
sleep 0.5
adb shell input text "c1@field.pk"
adb shell input tap 360 828          # tap password field
sleep 0.5
adb shell input text "password123"
adb shell input keyevent 111         # dismiss keyboard
sleep 0.5
adb shell input tap 360 977          # Sign In
sleep 4
```

#### Tasks tab — inner tabs
| Tab | Bounds | Center tap |
|-----|--------|------------|
| All | [0,165][240,257] | `adb shell input tap 120 211` |
| Active | [240,165][480,257] | `adb shell input tap 360 211` |
| Completed | [480,165][720,257] | `adb shell input tap 600 211` |

#### Pre-requisites / known DB state
- Tasks 15 ("Food and water needed") and 16 ("Medical supplies needed") were submitted by Ahmed Khan
  (user 300) and had `coordinator_id = NULL`. Backend was fixed to include these in the coordinator's
  task list and to allow any coordinator to verify them.
- After delivery verification, "Baby Formula and Diapers Needed" and "Deliver 50kg Flour to Zia" show
  status COORDINATOR_VERIFIED in the Tasks → All list.

#### Bugs fixed before this journey (coordinator-specific)
| File | Bug | Fix |
|------|-----|-----|
| `backend/src/modules/tasks/tasks.service.ts` | `getCoordinatorTasks()` only returned tasks where `coordinator_id = userId`, hiding SUBMITTED tasks with `coordinator_id IS NULL` | Added `OR (t.status = 'SUBMITTED' AND t.coordinator_id IS NULL)` to WHERE clause |
| `backend/src/modules/deliveries/deliveries.service.ts` | `verifyDelivery()` jurisdiction check: `WHERE id = $1 AND coordinator_id = $2` blocked coordinators from verifying tasks with `coordinator_id IS NULL` → 403 "Jurisdiction error" | Changed to `AND (coordinator_id = $2 OR coordinator_id IS NULL)` |
| `flutter_app/lib/screens/coordinator/coordinator_tasks_screen.dart` | TabBar `labelColor` and `indicatorColor` both set to `Theme.of(context).colorScheme.primary` (blue) — invisible on blue AppBar | Fixed to `labelColor: Colors.white`, `unselectedLabelColor: Colors.white60`, `indicatorColor: Colors.white` |
| `flutter_app/lib/screens/coordinator/coordinator_delivery_review_screen.dart` | "Volunteer Notes:" section showed blank when `delivery['notes']` was null | Changed to show "No notes provided." in grey italic when notes is null or empty |
| `flutter_app/lib/screens/coordinator/coordinator_broadcast_screen.dart` | Dropdown showed "TASK", "CAMPAIGN", "NGO" in uppercase; label said "Target TASK" | Changed DropdownMenuItem children to `Text('Task')`, `Text('Campaign')`, `Text('NGO')` and label to title-case via `_scope[0] + _scope.substring(1).toLowerCase()` |

#### Full screen sequence (all 22 screenshots captured)

| # | Screen | How to reach | Key tap | Screenshot |
|---|--------|--------------|---------|------------|
| 01 | Login screen | Fresh launch | — | `01_login_screen.png` |
| 02 | Tasks list — All tab (3 tasks) | After login | auto-routes to `/coordinator/tasks` | `02_tasks_all.png` |
| 03 | Tasks list — Active tab | Tap Active tab | `adb shell input tap 360 211` | `03_tasks_active.png` |
| 04 | Tasks list — Completed tab | Tap Completed tab | `adb shell input tap 600 211` | `04_tasks_completed.png` |
| 05 | Task detail — In Progress task | Tap "Urgent Insulin for Fatima" card from All tab | `adb shell input tap 360 370` | `05_task_detail_in_progress.png` |
| 05b | Task detail scrolled (actions) | Scroll down in task detail | `adb shell input swipe 360 1200 360 700 400` | `05b_task_detail_scrolled.png` |
| 06 | Review Inbox (1 pending) | Tap Review tab | `adb shell input tap 216 1472` | `06_review_inbox.png` |
| 07 | Review Submission detail | Tap "Food and water needed" card | `adb shell input tap 360 365` | `07_task_review_detail.png` |
| 08 | Approve Delivery dialog | Tap "Approve Delivery" button | `adb shell input tap 360 991` | `08_approve_delivery_dialog.png` |
| 09 | Delivery verified (review inbox back, 0 or 1 pending) | Tap "Send" in dialog | — | `09_delivery_verified_success.png` |
| 10 | Intelligence Dashboard | Tap Intelligence tab | `adb shell input tap 360 1472` | `10_intelligence_dashboard.png` |
| 10b | Intelligence actions (scrolled) | Scroll down on Intelligence | `adb shell input swipe 360 1200 360 700 400` | `10b_intelligence_actions.png` |
| 11 | Broadcast Alert | Intelligence → Broadcast Alert | `adb shell input tap 360 [broadcast_y]` | `11_broadcast_alert.png` |
| 12 | Live Awareness | Intelligence → Live Awareness | Back → Intelligence → Live | `12_live_awareness.png` |
| 13 | Escalation History | Intelligence → Escalation History | Back → Intelligence → Escalation | `13_escalation_history.png` |
| 14 | Field Map | Intelligence → Field Map | Back → Intelligence → Field Map | `14_field_map.png` |
| 15 | Fraud Signals | Intelligence → Fraud Signals | Back → Intelligence → Fraud | `15_fraud_signals.png` |
| 16 | Emergency Escalation dialog | Intelligence → Emergency Escalation | tap → dialog opens | `16_emergency_escalation_dialog.png` |
| 17 | Volunteers list | Tap Volunteers tab | `adb shell input tap 504 1472` | `17_volunteers_list.png` |
| 18 | More bottom sheet | Tap More tab | `adb shell input tap 648 1472` | `18_more_sheet.png` |
| 19 | Messages / Chats list | More → Messages | tap Messages in sheet | `19_messages_chats.png` |
| 20 | Notifications | More → Notifications | tap Notifications in sheet | `20_notifications.png` |
| 21 | Escalate to Admin dialog | Escalation History → Escalate | — | `21_escalate_to_admin_dialog.png` |
| 22 | Task Chat | Messages → open conversation | tap chat with Ahmed Khan | `22_task_chat.png` |

#### Notes on the Review flow
- After the coordinator's first approval (from the previous session), the task "Medical supplies needed"
  (task 16) was VERIFY'd. In the new session, "Food and water needed" (task 15) remained SUBMITTED.
- The Review Inbox card shows `Submitted` status chip, volunteer name, and a "Review →" label.
- Review Submission screen shows: Task Info → Delivery Proof (photo carousel or "No notes provided.") → Operational Review text field → Approve/Flag/Reject buttons.
- Approve flow shows an AlertDialog: title "Verify Delivery", message "Are you sure you want to verify this delivery submission?" — tap "VERIFY" to confirm.
- On success: navigates back to Review Inbox, shows "Delivery VERIFY successful" snackbar.

---

### ADMIN (`admin@disasteraid.pk` / `password123`)

Admin uses the **web panel** at `http://localhost:5173` (React app), NOT the Flutter app.  
Admin panel login: same email/password credentials.

| # | Screen | How to reach |
|---|--------|--------------|
| 01 | Admin login page | `http://localhost:5173/login` |
| 02 | Admin dashboard | After login |
| 03 | Users list | Left nav → Users |
| 04 | Campaigns management | Left nav → Campaigns |
| 05 | Donations list | Left nav → Donations |
| 06 | Pending donations (approve/reject) | Donations → filter PENDING |
| 07 | Tasks management | Left nav → Tasks |
| 08 | Withdrawals approval | Left nav → Withdrawals |
| 09 | NGO management | Left nav → NGOs |

> Admin panel uses **Puppeteer** for web automation (see `UI_TEST_PLAYBOOK.md`).  
> For Flutter ADMIN testing, use the generic `/dashboard` route (limited access).

---

## 19. Quick Reference — ADB Command Cheatsheet

```bash
# Launch app
adb shell monkey -p com.example.reliefnet_app -c android.intent.category.LAUNCHER 1

# Screenshot (use /data/local/tmp/ — /sdcard/ fails on Vivo V2229)
adb shell "screencap -p /data/local/tmp/cap.png" && adb pull /data/local/tmp/cap.png /tmp/screen.png

# Tap at coordinates
adb shell input tap X Y

# Type text (no spaces)
adb shell input text "word"

# Space key
adb shell input keyevent 62

# Dismiss keyboard / Back
adb shell input keyevent 111   # Escape (soft dismiss)
adb shell input keyevent 4     # BACK (hard dismiss or navigate back)

# Scroll down (swipe up)
adb shell input swipe 360 1200 360 600 500

# Scroll up (swipe down)
adb shell input swipe 360 600 360 1200 500

# Find real widget bounds
adb shell "uiautomator dump /data/local/tmp/ui.xml" && adb pull /data/local/tmp/ui.xml /tmp/ui.xml && grep -i "keyword" /tmp/ui.xml

# Check backend logs
tail -50 /tmp/backend.log

# Install APK
adb install -r /home/arshad/finalfinal/arshi/Deploye_app/flutter_app/build/app/outputs/flutter-apk/app-debug.apk
```

---

## 20. Step-by-Step Workflow for a New Role

1. **Set up**: Confirm backend running (`ps aux | grep nodemon`), `adb reverse tcp:3000 tcp:3000`
2. **Create screenshot folder**: `mkdir -p /home/arshad/finalfinal/arshi/Deploye_app/<role>_screenshots/`
3. **Launch app**: `adb shell monkey ...` + `sleep 6`
4. **Check current screen**: Take screenshot to see if login or home is showing
5. **Login**: If on login screen, fill credentials for target role
6. **Start capture sequence**: Follow role's screen list from Section 18
7. **For each screen**:
   - Navigate (tap nav item or button)
   - `sleep 2–3`
   - Take screenshot
   - If shimmer visible, `sleep 3` more and retake
8. **Test image upload** (if role has forms with photos):
   - Tap photo area → dismiss Google Photos dialog → select recent photo → verify preview
   - Submit form → check `backend/uploads/` for new file → check DB for URL
9. **Test GPS** (if role has location forms):
   - Tap "Use Current Location" → `sleep 4` → confirm "Location confirmed" green check
10. **Fix any bugs found** → `flutter analyze` → `flutter build apk --debug` → `adb install -r` → re-run from step 3
11. **Verify backend**: Check DB for submitted data, check `backend/uploads/` for uploaded files

---

## 21. Known Bugs Fixed (do not reintroduce)

| File | Bug | Fix Applied |
|------|-----|-------------|
| `lib/screens/donor/donation_history_screen.dart` | PENDING explainer Row was third sibling in horizontal Row causing overflow | Moved inside left Column, wrapped Column in `Expanded`, text in `Flexible` |
| `lib/core/shell/dashboard_shell.dart` | Donor FAB showed on all tabs | Added `loc` param check: `if (!loc.startsWith('/donor/inkind')) return null;` |
| `lib/providers/follow_provider.dart` | Followed campaigns lost on logout | Rewrote to persist via `flutter_secure_storage` with JSON |
| `backend/src/modules/tasks/tasks.routes.ts` | GET /tasks/my returned 403 for DONOR | Added DONOR, VOLUNTEER, COORDINATOR to `authorize()` call |
| DB: campaigns | Campaign 102% funded but still ACTIVE | Created `trg_auto_close_campaign` trigger; manually closed id=5 |
| `lib/screens/beneficiary/create_task_screen.dart` | Task creation fails 400 — `campaign_id: null` sent explicitly but Zod `.optional()` rejects null | Changed to use collection-if: `if (widget.campaignId != null) 'campaign_id': widget.campaignId` and similarly for description/category/locationText |
| `backend/src/modules/tasks/tasks.schema.ts` | Same as above, backend side | Changed `campaign_id` and `beneficiary_id` from `.optional()` to `.nullish()` so both null and undefined are accepted |
| `lib/screens/volunteer/proof_upload_screen.dart` | Image upload blocked when Cloudinary not configured — early return with "Image upload not configured" | Replaced early-return with dual-path: direct Cloudinary upload if env vars set, else `POST /api/media/upload` backend fallback. Files land in `backend/uploads/` |
| `lib/screens/volunteer/proof_upload_screen.dart` | `POST /deliveries` 400 — wrong field name + missing required field | Changed `photo_urls` → `storage_keys` (correct field name); added `quantity_delivered: 1` (required by schema) |
| `lib/core/api/api_client.dart` | `client.post()` wrapper lacks `onSendProgress` parameter | Use `client.dio.post()` directly for multipart uploads that need progress tracking |
| `lib/core/socket/socket_service.dart` | `io.destroy(baseUrl)` — function doesn't exist in Dart's socket_io_client | Removed the `io.destroy(baseUrl)` call; `_socket?.dispose()` is sufficient |
| `backend/src/modules/deliveries/deliveries.service.ts` | `UPDATE tasks SET status = 'PARTIALLY_COMPLETED'` fails with pg enum error | `PARTIALLY_COMPLETED` not in `task_status` enum. Changed to `'SUBMITTED'`. Also updated status check from `PARTIALLY_COMPLETED` → `SUBMITTED` |
| `flutter_app/lib/core/shell/dashboard_shell.dart` | More sheet role label used `role?.name` (Dart enum name "ngo") → displayed as "Ngo" for NGO role | Changed to `role?.value` with length-guard: words ≤3 chars stay uppercase, longer words get title-case |
| `flutter_app/lib/core/shell/dashboard_shell.dart` | NGO FAB ("+ New Campaign") appeared on Settings/Withdrawal screens, overlapping Save button | Added route guard to `_buildFab`: returns null unless `loc` starts with `/ngo/campaigns` or `/ngo/dashboard` |
| `flutter_app/lib/screens/ngo/ngo_dashboard_screen.dart` | Quick Action taps used `context.push()` so shell's `matchedLocation` was not updated on navigation — FAB persisted on sub-screens | Changed all Quick Action nav to `context.go()` so shell re-evaluates `matchedLocation` correctly |
| `backend/src/modules/tasks/tasks.service.ts` | `getCoordinatorTasks()` WHERE clause `coordinator_id = $1` excluded SUBMITTED tasks with `coordinator_id IS NULL` — coordinator had no visible work items to review | Added `OR (t.status = 'SUBMITTED' AND t.coordinator_id IS NULL)` to include unowned SUBMITTED tasks |
| `backend/src/modules/deliveries/deliveries.service.ts` | `verifyDelivery()` jurisdiction check `WHERE id = $1 AND coordinator_id = $2` returned 0 rows for tasks with `coordinator_id IS NULL` → 403 "Jurisdiction error: You cannot verify this delivery" | Changed to `AND (coordinator_id = $2 OR coordinator_id IS NULL)` so any coordinator can verify unassigned tasks |
| `flutter_app/lib/screens/coordinator/coordinator_tasks_screen.dart` | TabBar `labelColor: Theme.of(context).colorScheme.primary` and `indicatorColor` same — both blue on blue AppBar, rendering tab labels invisible | Changed to `labelColor: Colors.white`, `unselectedLabelColor: Colors.white60`, `indicatorColor: Colors.white`, `indicatorWeight: 3`, `dividerColor: Colors.transparent` |
| `flutter_app/lib/screens/coordinator/coordinator_delivery_review_screen.dart` | "Volunteer Notes:" section showed blank/empty when `delivery['notes']` was null (volunteer submitted no notes) | Added null-check: shows "No notes provided." in grey italic when notes is null or empty string |
| `flutter_app/lib/screens/coordinator/coordinator_broadcast_screen.dart` | Scope dropdown displayed raw DB values "TASK", "CAMPAIGN", "NGO" in uppercase; label read "Target TASK" | Changed DropdownMenuItems to use title-case labels `Text('Task')`, `Text('Campaign')`, `Text('NGO')`, and label to `'Target ${_scope[0] + _scope.substring(1).toLowerCase()}'` |

---

## 22. Project File Locations

```
/home/arshad/finalfinal/arshi/Deploye_app/
├── flutter_app/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── router/app_router.dart          # All routes
│   │   │   └── shell/dashboard_shell.dart      # Nav bar + FAB per role
│   │   ├── providers/                          # Riverpod state
│   │   ├── screens/
│   │   │   ├── donor/                          # Donor screens
│   │   │   ├── beneficiary/                    # Beneficiary screens
│   │   │   ├── volunteer/                      # Volunteer screens (in features/tasks too)
│   │   │   ├── coordinator/                    # Coordinator screens
│   │   │   └── ngo/                            # NGO screens
│   │   └── features/                           # Feature-based screens (tasks, auth)
│   └── build/app/outputs/flutter-apk/          # Built APKs
├── backend/
│   ├── src/modules/                             # API modules
│   └── uploads/                                 # Local image uploads (fallback from Cloudinary)
├── admin-panel/                                 # React web panel (port 5173)
├── donor_screenshots/                           # Donor journey screenshots (done — 22 screens)
├── volunteer_screenshots/                       # Volunteer journey screenshots (done — 20 screens)
├── beneficiary_screenshots/                     # Beneficiary journey screenshots (done)
├── coordinator_screenshots/                     # Coordinator journey screenshots (done — 24 screens)
├── ngo_screenshots/                             # NGO journey screenshots (done — 15 screens)
└── AGENT_ROLE_TESTING_PLAYBOOK.md              # This file
```
