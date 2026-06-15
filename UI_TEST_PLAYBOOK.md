# DisasterAid.pk V2.1 — UI & UX Testing Playbook

This file is the authoritative guide for testing the full stack:  
**Backend API → Admin Panel (web) → Flutter Mobile App (USB)**

Use this file to verify new features, review existing screens, catch regressions,  
and identify UI/UX improvements. Every step is copy-paste ready.

---

## Table of Contents

1. [Starting the Stack](#1-starting-the-stack)
2. [Web Admin Panel — Automated Screenshots](#2-web-admin-panel--automated-screenshots)
3. [Flutter Mobile App — USB Device Testing](#3-flutter-mobile-app--usb-device-testing)
4. [Screen-by-Screen Review Checklist (Web)](#4-screen-by-screen-review-checklist-web)
5. [Screen-by-Screen Review Checklist (Flutter)](#5-screen-by-screen-review-checklist-flutter)
6. [What to Look For — UI/UX Review Criteria](#6-what-to-look-for--uiux-review-criteria)
7. [Diagnosing Failures](#7-diagnosing-failures)
8. [Known Gotchas & Environment Notes](#8-known-gotchas--environment-notes)

---

## 1. Starting the Stack

### Step 1 — Backend
```bash
cd /home/arshad/finalfinal/arshi/Deploye_app/backend
npm run dev
```
Verify it's up:
```bash
curl http://localhost:3000/api/health
# Expected: {"status":"ok"}
```

### Step 2 — Admin Panel
```bash
cd /home/arshad/finalfinal/arshi/Deploye_app/admin-panel
npm run dev
```
Verify it's up:
```bash
curl -s -o /dev/null -w "%{http_code}" http://localhost:5173/
# Expected: 200
```

### Step 3 — Flutter (USB device)
See Section 3. Flutter does not need a separate server — it connects to the backend via `adb reverse`.

### Quick health check (both services at once)
```bash
curl -s -o /dev/null -w "admin-panel:%{http_code} " http://localhost:5173/ && \
curl -s -o /dev/null -w "backend:%{http_code}\n" http://localhost:3000/api/health
# Expected: admin-panel:200 backend:200
```

---

## 2. Web Admin Panel — Automated Screenshots

### Prerequisites
Puppeteer is installed at `/tmp/node_modules/puppeteer` (re-install if `/tmp` was cleared):
```bash
mkdir -p /tmp/node_modules
cd /tmp && npm install puppeteer
```
Requires Google Chrome:
```bash
which google-chrome   # should return /usr/bin/google-chrome
```

### Full screenshot script
Save as `/tmp/screenshot_all.cjs` and run with `node /tmp/screenshot_all.cjs`.

```js
const puppeteer = require('/tmp/node_modules/puppeteer');

// ── CONFIG ────────────────────────────────────────────────────────────────────
const BASE      = 'http://localhost:5173';
const ADMIN_EMAIL    = 'admin@disasteraid.pk';
const ADMIN_PASSWORD = 'password123';
const OUT_DIR   = '/tmp';
// ─────────────────────────────────────────────────────────────────────────────

(async () => {
  const browser = await puppeteer.launch({
    executablePath: '/usr/bin/google-chrome',
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage'],
    headless: true,
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  // Collect console errors and network failures for diagnosis
  const consoleErrors = [];
  const netFails = [];
  page.on('console', msg => { if (msg.type() === 'error') consoleErrors.push(msg.text()); });
  page.on('pageerror', err => consoleErrors.push('PAGE: ' + err.message));
  page.on('requestfailed', req => netFails.push(req.url() + ' → ' + req.failure()?.errorText));
  page.on('response', resp => { if (resp.status() >= 400) netFails.push(resp.status() + ' ' + resp.url()); });

  // ── 1. Login page ───────────────────────────────────────────────────────────
  await page.goto(BASE + '/login', { waitUntil: 'networkidle2' });
  await page.screenshot({ path: OUT_DIR + '/web_01_login.png' });
  console.log('✓ 01_login');

  // ── 2. Authenticate ─────────────────────────────────────────────────────────
  const inputs = await page.$$('input');
  await inputs[0].type(ADMIN_EMAIL);
  await inputs[1].type(ADMIN_PASSWORD);
  await Promise.all([
    page.keyboard.press('Enter'),
    page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 8000 }).catch(() => {}),
  ]);
  await new Promise(r => setTimeout(r, 3000));
  console.log('Logged in, URL:', page.url());

  // ── 3. Pages to capture ─────────────────────────────────────────────────────
  const pages = [
    { url: '/dashboard',         file: 'web_02_dashboard.png'  },
    { url: '/donations',         file: 'web_03_donations.png'  },
    { url: '/withdrawals',       file: 'web_04_withdrawals.png'},
    { url: '/campaigns',         file: 'web_05_campaigns.png'  },
    { url: '/ngos/verification', file: 'web_06_ngo_verify.png' },
    { url: '/users',             file: 'web_07_users.png'      },
    { url: '/ledger',            file: 'web_08_ledger.png'     },
    { url: '/inkind',            file: 'web_09_inkind.png'     },
  ];

  for (const { url, file } of pages) {
    // Re-login if session expired
    if (page.url().includes('/login')) {
      const ins = await page.$$('input');
      await ins[0].type(ADMIN_EMAIL);
      await ins[1].type(ADMIN_PASSWORD);
      await Promise.all([
        page.keyboard.press('Enter'),
        page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 8000 }).catch(() => {}),
      ]);
      await new Promise(r => setTimeout(r, 2000));
    }

    await page.goto(BASE + url, { waitUntil: 'networkidle2', timeout: 12000 }).catch(() => {});
    await new Promise(r => setTimeout(r, 2500));
    await page.screenshot({ path: OUT_DIR + '/' + file, fullPage: true });
    console.log('✓', file, '—', page.url());
  }

  // ── 4. Print diagnostics ────────────────────────────────────────────────────
  if (consoleErrors.length) {
    console.log('\n⚠  CONSOLE ERRORS:');
    consoleErrors.forEach(e => console.log('  ', e));
  }
  if (netFails.length) {
    console.log('\n⚠  NETWORK FAILURES / 4xx-5xx:');
    netFails.forEach(f => console.log('  ', f));
  }
  if (!consoleErrors.length && !netFails.length) {
    console.log('\n✓ No console errors or network failures');
  }

  await browser.close();
  console.log('\nScreenshots saved to', OUT_DIR);
})();
```

### Reading the screenshots
After running, open each PNG with any image viewer:
```bash
eog /tmp/web_01_login.png          # GNOME image viewer
# or
feh /tmp/web_*.png                  # cycle through all
```
Or read them directly in Claude Code with the Read tool (it renders images).

### NGO user screenshots (separate login)
```bash
# Change ADMIN_EMAIL/ADMIN_PASSWORD in the script to an NGO account, e.g.:
# ngo_email = 'contact@redcross.pk'
# ngo_password = 'password123'
# NGO routes: /ngo/dashboard, /ngo/campaigns, /ngo/tasks, /ngo/profile
```

---

## 3. Flutter Mobile App — USB Device Testing

### Device: Vivo V2229 (USB)
- USB Vendor ID: `2d95`
- Requires udev rule for Linux USB access (one-time setup)

### One-time udev setup (if adb says "no permissions")
```bash
# Check if rule exists
cat /etc/udev/rules.d/51-android.rules

# If missing, create it (requires pkexec / sudo):
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="2d95", MODE="0666", GROUP="plugdev"' \
  | pkexec tee /etc/udev/rules.d/51-android.rules
sudo udevadm control --reload-rules && sudo udevadm trigger

# Re-plug USB cable, then verify:
adb devices
# Expected: <serial>  device   (NOT "no permissions" or "unauthorized")
```

### Phone setup (one-time)
1. Developer Options → Enable USB Debugging
2. When prompted on phone: "Allow USB debugging from this computer?" → tap **Always allow**

### Connect and verify
```bash
adb devices
# Should show your device as "device" (not "unauthorized")
```

### Tunnel backend to phone
The Flutter app calls `localhost:3000`. On a physical device, `localhost` means the phone itself.  
`adb reverse` maps the phone's port 3000 to your machine's port 3000:
```bash
adb reverse tcp:3000 tcp:3000
# No output = success

# Verify tunnel:
adb shell curl -s http://localhost:3000/api/health
# Expected: {"status":"ok"}
```

### Build & install Flutter app
```bash
cd /home/arshad/finalfinal/arshi/Deploye_app/flutter_app

# Install on connected device
flutter run --release           # Release build (faster, closer to production)
# or
flutter run                     # Debug build (shows debug banner, hot reload works)
```

If multiple devices are connected:
```bash
flutter devices                 # List devices
flutter run -d <device-id>
```

### Take screenshots from phone via adb
```bash
# Screenshot the current screen on device → pull to /tmp/
adb exec-out screencap -p > /tmp/flutter_screen.png

# Or use a loop to capture as you navigate:
adb exec-out screencap -p > /tmp/flutter_01_login.png
# (navigate on phone)
adb exec-out screencap -p > /tmp/flutter_02_dashboard.png
# etc.
```

### Flutter log output (diagnose crashes/errors)
```bash
adb logcat -s flutter          # Flutter-only logs
adb logcat | grep -i "flutter\|error\|exception"
```

### Check API calls from the device
```bash
# Watch all outgoing calls from the app hitting your backend:
# In the backend terminal, you'll see Winston logs for each request.
# Or watch access logs:
adb logcat -s flutter | grep -i "dio\|http\|api"
```

---

## 4. Screen-by-Screen Review Checklist (Web)

For each screen, verify **data loads, renders correctly, and actions work**.

### Login (`/login`)
- [ ] Page loads with dark blue gradient background
- [ ] DisasterAid.pk logo + heart icon visible
- [ ] "HUMANITARIAN RELIEF PLATFORM — ADMIN CONSOLE" subtitle
- [ ] Email + Password fields accept input
- [ ] Invalid credentials → red error alert appears inline
- [ ] Valid credentials → redirects to `/dashboard`

### Dashboard (`/dashboard`)
- [ ] All 4 stat cards load (Donations, Withdrawals, Campaigns, Users)
- [ ] PKR amounts display correctly (not 0 or NaN)
- [ ] Live Operational Map renders (Leaflet map, not blank or crashed)
- [ ] Task markers visible on map (blue pins)
- [ ] Operational Bottlenecks section shows hours, not "undefined"
- [ ] System Status row shows 3 green/blue alerts
- [ ] Sidebar shows grouped sections: Finance / Campaigns & NGOs / Platform

### Donations (`/donations`)
- [ ] Table loads with donor name + email, campaign, amount, status, date
- [ ] Status badges: PENDING=orange, CONFIRMED=green, REJECTED=red
- [ ] Search bar filters rows as you type
- [ ] Status dropdown filters by PENDING/CONFIRMED/REJECTED
- [ ] PENDING rows show Approve + Reject buttons
- [ ] CONFIRMED rows show Flag Dispute button
- [ ] Investigate button opens trace modal
- [ ] Download CSV button triggers file download

### Withdrawals (`/withdrawals`)
- [ ] Table loads with NGO name, amount, masked bank account (PK12****7890), status
- [ ] PENDING rows show Approve + Reject buttons
- [ ] APPROVED rows show no action buttons
- [ ] Download CSV button works

### Campaigns (`/campaigns`)
- [ ] Progress column shows antd Progress bars (not plain text)
- [ ] 100% funded campaigns show green bar
- [ ] Overfunded campaigns (>100%) show red bar + "X.X% — Overfunded" text
- [ ] DRAFT campaigns show grey 0% bar
- [ ] Campaign title shows tooltip on hover (full name)
- [ ] Status badges: ACTIVE=green, PAUSED=orange, DRAFT=blue, CLOSED=red
- [ ] Pause / Activate / Close buttons work with confirmation modal

### NGO Verification (`/ngos/verification`)
- [ ] Page loads (not redirected to login)
- [ ] If pending NGOs exist: table shows Org Name, Reg #, Representative, Submitted
- [ ] If no pending NGOs: empty state is shown (not a blank white space)
- [ ] Approve/Reject buttons trigger confirmation + API call

### Users (`/users`)
- [ ] Table loads with all roles (ADMIN, NGO, VOLUNTEER, COORDINATOR, DONOR)
- [ ] Role badges color-coded correctly
- [ ] Search bar filters by name or email
- [ ] Role dropdown filters by role
- [ ] ADMIN users have grayed-out Suspend button (cannot suspend admins)
- [ ] NGO users show "View NGO" button
- [ ] SUSPENDED users show "Reactivate" button instead

### Ledger (`/ledger`)
- [ ] Four tabs: Donations Ledger, Withdrawals Ledger, Campaign Financial Flow, Audit Logs
- [ ] Donations Ledger tab shows TXN reference numbers + amounts
- [ ] Switching tabs loads correct data

### InKind Records (`/inkind`)
- [ ] Page loads and shows goods donation records
- [ ] Campaign filter works

---

## 5. Screen-by-Screen Review Checklist (Flutter)

### Login Screen
- [ ] DisasterAid.pk branding visible
- [ ] Email + password fields accept input
- [ ] "Sign In" button shows loading spinner
- [ ] Invalid credentials → error snackbar/message appears
- [ ] Valid login → navigates to role-appropriate dashboard

### Role: VOLUNTEER
- [ ] Dashboard shows available tasks list
- [ ] Task card shows title, location, urgency tag
- [ ] Tap task → Task Detail screen loads
- [ ] Task Detail shows description, status, campaign name
- [ ] "Claim Task" button visible for OPEN tasks
- [ ] After claiming → status changes to CLAIMED

### Role: NGO
- [ ] NGO Dashboard loads with campaign stats
- [ ] My Campaigns list shows campaigns with progress
- [ ] Create Task flow works (form validation on empty fields)
- [ ] Beneficiary Requests list loads

### Role: DONOR
- [ ] Campaign list loads with progress bars
- [ ] Tap campaign → Campaign Detail with donation button
- [ ] Donation flow opens payment intent (Stripe sandbox)

### Role: COORDINATOR
- [ ] Task list shows all tasks in area
- [ ] Can verify delivery on a task

### General Flutter checks (all roles)
- [ ] Back navigation works correctly (no blank screens)
- [ ] Bottom nav bar switches tabs without page reload
- [ ] Loading skeletons shown while data fetches
- [ ] Error states shown when backend is unreachable
- [ ] Text is readable (not clipped, not overflowing buttons)
- [ ] Tap targets are large enough (minimum 44×44dp)
- [ ] Forms validate before submission
- [ ] Keyboard does not hide important form fields

---

## 6. What to Look For — UI/UX Review Criteria

When reviewing screenshots or live screens, check these categories:

### Data Integrity
- Numbers format correctly (PKR 1,400,000 not PKR1400000 or NaN)
- Dates show in local format (Jun 13, 2026 not 2026-06-13T10:38:00.000Z)
- Long text truncates with `...` and shows tooltip on hover
- Empty states are labeled (not just a blank box)
- Loading states use spinners/skeletons (not blank content)

### Visual Consistency
- All status badges use consistent colors across pages
  - PENDING → orange/gold, CONFIRMED/ACTIVE → green, REJECTED/CLOSED → red, DRAFT → blue
- Font sizes match hierarchy (title > label > secondary)
- Action buttons grouped logically (approve before reject, not random order)
- Destructive actions (Reject, Suspend, Close) are colored red/danger

### Responsiveness
- On 1440px (desktop): no horizontal scroll, no clipped buttons
- Sidebar collapses correctly with hamburger menu
- Table columns don't overflow the card container

### Antd 6 Specific (admin panel)
- No `valueStyle` on `<Statistic>` → must use `styles={{ content: ... }}`
- No `message=` on `<Alert>` used as a title → must use `title=`
- No `orientation="left"` on `<Divider>` → must use `titlePlacement="left"`
- No `visible=` on `<Modal>` → must use `open=`

### Flutter Specific
- Run `flutter analyze` → must show **0 issues**
- No `print()` calls → use `debugPrint()`
- No raw `const` warnings
- Text does not overflow `RenderFlex` (check logcat for overflow errors)

---

## 7. Diagnosing Failures

### White/blank screen on admin panel
1. Open browser DevTools console → check for JS errors
2. Check backend is running: `curl http://localhost:3000/api/health`
3. Check the route matches: look at `admin-panel/src/router/AppRouter.tsx`
4. Run Puppeteer with console error logging (the script above captures errors)

### Dashboard crash (map or stats)
- Most common cause: API returned `null` for coordinates → MapView crashes
- Fix: filter out null lat/lng before rendering markers (already applied)
- Check: `curl http://localhost:3000/api/admin/map-data | jq .`

### Flutter app shows "Connection refused" or blank data
1. Confirm `adb reverse tcp:3000 tcp:3000` was run **after** plugging in USB
2. Confirm backend is running: `adb shell curl http://localhost:3000/api/health`
3. Check `flutter_app/lib/core/api/api_constants.dart` — base URL must be `localhost:3000/api` (not `10.0.2.2` which is for Android emulator)

### Flutter "no permissions" for USB device
```bash
cat /etc/udev/rules.d/51-android.rules   # verify rule exists
adb kill-server && adb start-server       # restart adb
# Re-plug the USB cable
adb devices
```

### TypeScript build errors (admin panel)
```bash
cd admin-panel && npm run build 2>&1 | grep "error TS"
```
Common antd 6 issues:
- `Property 'valueStyle' does not exist` → change to `styles={{ content: ... }}`
- `Type '...' is not assignable` on table columns → add explicit interface for record type

### Backend TypeScript errors
```bash
cd backend && npm run build 2>&1 | grep "error TS"
```
Common issues:
- Missing method on a service class (add the method)
- Missing field in Zod schema (add it to the schema)
- ESM import missing `.js` extension

---

## 8. Known Gotchas & Environment Notes

### No Docker — local PostgreSQL only
- Docker is NOT installed on this machine
- PostgreSQL runs locally
- Connection string is in `backend/.env` — uses local socket or `localhost:5432`
- Migrations must be applied manually in order: `database/001_init.sql` → `014_ngo_bank_details.sql`

### ADB reverse must be re-run after each USB reconnect
Every time you unplug and re-plug the USB cable, run:
```bash
adb reverse tcp:3000 tcp:3000
```

### Puppeteer in /tmp is wiped on reboot
After a system restart, reinstall:
```bash
cd /tmp && npm install puppeteer
```

### The screenshot script handles session expiry
The full script in Section 2 detects if a page redirected to `/login` and re-authenticates.  
If you use a shorter script, add a check: `if (page.url().includes('/login')) { ... re-login ... }`

### Admin accounts cannot be created via API
Seed admin users directly in the database. The JWT only stores `userId`; role is always fetched from DB per request.

### Flutter API base URL
- **Physical USB device**: `localhost:3000/api` (via adb reverse tunnel)
- **Android emulator**: `10.0.2.2:3000/api`
- File: `flutter_app/lib/core/api/api_constants.dart`

### NGO Verification route
- Correct URL: `/ngos/verification` (not `/ngo-verification`)
- Menu key in `AdminLayout.tsx` must match the route exactly

### All 4 volunteer map markers have null coordinates in seed data
The backend `/api/admin/map-data` returns volunteers with `null` latitude/longitude.  
`MapView.tsx` already filters these out. If you add real volunteer GPS data, markers will appear.

### Ant Design 6 breaking changes summary
| Old prop | New prop | Component |
|---|---|---|
| `valueStyle={{ color: 'red' }}` | `styles={{ content: { color: 'red' } }}` | `<Statistic>` |
| `message="text"` (as heading) | `title="text"` | `<Alert>` |
| `orientation="left"` | `titlePlacement="left"` | `<Divider>` |
| `visible={bool}` | `open={bool}` | `<Modal>` |

---

*Last updated: 2026-06-14*  
*Stack: Node.js+Express backend (port 3000) · React+Vite admin panel (port 5173) · Flutter 3.41.5 (Vivo V2229 via USB)*
