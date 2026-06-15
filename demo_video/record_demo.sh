#!/usr/bin/env bash
# =============================================================================
# DisasterAid.pk V2.1 — Full Platform Demo Recording Script
# =============================================================================
# Usage:
#   ./record_demo.sh all           # record all roles + stitch
#   ./record_demo.sh ngo           # record NGO journey only
#   ./record_demo.sh donor         # record DONOR journey only
#   ./record_demo.sh volunteer     # record VOLUNTEER journey only
#   ./record_demo.sh coordinator   # record COORDINATOR journey only
#   ./record_demo.sh beneficiary   # record BENEFICIARY journey only
#   ./record_demo.sh stitch        # stitch already-recorded clips into final video
#
# Requirements:
#   - adb (Android Debug Bridge)
#   - scrcpy 1.25+ (for host-side screen recording)
#   - ffmpeg 6+ (for title cards + stitching)
#   - Device: Vivo V2229 (serial 10FCBM01BZ0001B) connected via USB
#   - Backend running on port 3000 (adb reverse active)
#   - Font: /usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf
# =============================================================================

set -euo pipefail

DEVICE="10FCBM01BZ0001B"
ADB="adb -s $DEVICE"
APP_PKG="com.example.reliefnet_app"
APP_ACTIVITY="com.example.reliefnet_app.MainActivity"

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLIPS="$BASE/clips"
PROCESSED="$BASE/processed"
TITLES="$BASE/titles"
FINAL="$BASE/final_demo.mp4"
FONT="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

# Resolution the device outputs (720p portrait)
W=720; H=1600

# ffmpeg video quality settings
CRF=22
PRESET="fast"

SCRCPY_PID=""
CURRENT_ROLE=""

# =============================================================================
# UTILITIES
# =============================================================================

log()  { echo -e "\033[1;34m[$(date +%H:%M:%S)]\033[0m $*"; }
ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }
err()  { echo -e "\033[1;31m[ERR]\033[0m $*" >&2; }
step() { echo -e "\033[1;33m  →\033[0m $*"; }

t()    { $ADB shell input tap $1 $2; }       # tap x y
s()    { $ADB shell input swipe $1 $2 $3 $4 ${5:-400}; }  # swipe x1 y1 x2 y2 [ms]
p()    { sleep ${1:-2}; }                    # pause (default 2s for viewer)
back() { $ADB shell input keyevent 4; }
esc()  { $ADB shell input keyevent 111; }
txt()  { $ADB shell input text "$1"; }
enter(){ $ADB shell input keyevent 66; }

cap() {
  # cap [label] — take screenshot, pull to /tmp, print path
  local label="${1:-check}"
  $ADB shell screencap /data/local/tmp/cap.png
  $ADB pull /data/local/tmp/cap.png "/tmp/${label}.png" 2>/dev/null
  echo "/tmp/${label}.png"
}

# =============================================================================
# DEVICE SETUP
# =============================================================================

dnd_on() {
  # Enable Do-Not-Disturb so WhatsApp/SMS can't intercept taps during recording
  $ADB shell settings put global zen_mode 3    # total silence
  $ADB shell settings put global zen_mode_config_etag '""'
  log "DND enabled (total silence)"
}

dnd_off() {
  $ADB shell settings put global zen_mode 0
  log "DND disabled"
}

setup_device() {
  log "Setting up device..."
  $ADB reverse tcp:3000 tcp:3000
  # Keep screen on during recording
  $ADB shell svc power stayon true 2>/dev/null || true
  # Unlock screen if needed
  $ADB shell input keyevent 224    # wake
  sleep 1
  $ADB shell input keyevent 82     # menu (unlock if PIN-less)
  sleep 1
  ok "Device ready"
}

teardown_device() {
  $ADB shell svc power stayon false 2>/dev/null || true
  dnd_off
}

# =============================================================================
# APP LIFECYCLE
# =============================================================================

fresh_launch() {
  # Force-stop + clear app data → lands on login screen every time
  step "Cold-starting app (clearing auth state)..."
  $ADB shell "am force-stop $APP_PKG" 2>/dev/null || true
  sleep 1
  $ADB shell "pm clear $APP_PKG" >/dev/null 2>&1 || true
  sleep 1
  $ADB shell "am start -n $APP_PKG/$APP_ACTIVITY" >/dev/null
  sleep 6   # wait for splash + login screen
  step "App on login screen"
}

login_as() {
  local email="$1"
  local pass="${2:-password123}"
  step "Logging in as $email"
  # Email field
  t 360 689; sleep 0.3
  txt "$email"
  # Password field
  t 360 810; sleep 0.3
  txt "$pass"
  esc; sleep 0.3
  # Sign In
  t 360 958
  sleep 7   # wait for role-based redirect + dashboard load
  step "Login complete"
}

# =============================================================================
# RECORDING (scrcpy host-side — no 3-minute limit)
# =============================================================================

start_recording() {
  local role="$1"
  local out="$CLIPS/${role}_journey.mp4"
  CURRENT_ROLE="$role"
  log "Starting recording → $out"
  # --no-display: mirror without showing window (headless)
  # --serial: target specific device
  scrcpy --serial "$DEVICE" --record "$out" --no-display \
         --max-fps 30 --bit-rate 4M \
         2>/dev/null &
  SCRCPY_PID=$!
  sleep 2   # let scrcpy initialise before we start tapping
  ok "Recording PID=$SCRCPY_PID"
}

stop_recording() {
  if [[ -n "$SCRCPY_PID" ]]; then
    log "Stopping recording (PID=$SCRCPY_PID)..."
    kill "$SCRCPY_PID" 2>/dev/null || true
    wait "$SCRCPY_PID" 2>/dev/null || true
    SCRCPY_PID=""
    sleep 2
    ok "Clip saved: $CLIPS/${CURRENT_ROLE}_journey.mp4"
  fi
}

# =============================================================================
# TITLE CARD & ROLE CARD GENERATION
# =============================================================================

make_intro() {
  local out="$1"; local title="$2"; local sub="$3"; local dur="${4:-4}"
  ffmpeg -y -loglevel error \
    -f lavfi -i "color=c=0x0D1B2A:s=${W}x${H}:r=30:d=$dur" \
    -vf "
      drawtext=fontfile=$FONT:text='ReliefNet':fontcolor=white:fontsize=38:x=(w-text_w)/2:y=h*0.28:alpha=0.5,
      drawtext=fontfile=$FONT:text='${title}':fontcolor=white:fontsize=52:x=(w-text_w)/2:y=h*0.38,
      drawtext=fontfile=$FONT:text='${sub}':fontcolor=0xAAAAAAFF:fontsize=28:x=(w-text_w)/2:y=h*0.50
    " \
    -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$out"
}

make_role_card() {
  local out="$1"; local role="$2"; local name="$3"
  local email="$4"; local hex_color="$5"; local dur="${6:-3}"
  ffmpeg -y -loglevel error \
    -f lavfi -i "color=c=0x${hex_color}:s=${W}x${H}:r=30:d=$dur" \
    -vf "
      drawtext=fontfile=$FONT:text='ROLE':fontcolor=0xFFFFFF88:fontsize=26:x=(w-text_w)/2:y=h*0.33,
      drawtext=fontfile=$FONT:text='${role}':fontcolor=white:fontsize=68:x=(w-text_w)/2:y=h*0.38,
      drawtext=fontfile=$FONT:text='${name}':fontcolor=white:fontsize=32:x=(w-text_w)/2:y=h*0.54,
      drawtext=fontfile=$FONT:text='${email}':fontcolor=0xFFFFFFAA:fontsize=22:x=(w-text_w)/2:y=h*0.61
    " \
    -c:v libx264 -preset ultrafast -pix_fmt yuv420p "$out"
}

generate_all_title_cards() {
  log "Generating title cards..."
  make_intro "$TITLES/00_intro.mp4"  "DisasterAid.pk V2.1"  "Full Platform Demo — All Roles" 5
  make_role_card "$TITLES/01_ngo_card.mp4"         "NGO"         "Red Cross PK"     "contact@redcross.pk"   "8B1A2A" 3
  make_role_card "$TITLES/02_donor_card.mp4"       "DONOR"       "Whale Donor"      "rich@donor.pk"         "1A4A8B" 3
  make_role_card "$TITLES/03_volunteer_card.mp4"   "VOLUNTEER"   "Ahmed Khan"       "ahmed@volunteer.pk"    "1A6B3A" 3
  make_role_card "$TITLES/04_coordinator_card.mp4" "COORDINATOR" "Field Lead C1"    "c1@field.pk"           "5B1A8B" 3
  make_role_card "$TITLES/05_beneficiary_card.mp4" "BENEFICIARY" "Zia Flood Victim" "zia@needs.pk"          "8B4A1A" 3
  make_intro "$TITLES/99_outro.mp4"  "DisasterAid.pk V2.1"  "github.com/disasteraid-pk" 4
  ok "Title cards done"
}

# =============================================================================
# ROLE JOURNEYS
# =============================================================================

journey_ngo() {
  log "=== NGO JOURNEY ==="
  fresh_launch
  start_recording "ngo"
  p 2

  # Login
  login_as "contact@redcross.pk"
  p 2

  # --- Screen 1: NGO Dashboard ---
  step "NGO Dashboard"
  p 3
  # Scroll hero stats into view
  s 360 900 360 600 500; p 2
  s 360 600 360 900 500; p 1

  # --- Screen 2: Campaigns tab ---
  step "Campaigns tab"
  t 270 1520; p 3
  # Scroll down to see all campaigns
  s 360 1100 360 600 600; p 2

  # --- Screen 3: Active filter ---
  step "Active filter"
  t 180 211; p 2   # Active tab

  # --- Screen 4: Draft filter ---
  step "Draft filter"
  t 450 211; p 2   # Draft tab

  # --- Screen 5: All campaigns (scroll back to All) ---
  t 90 211; p 1    # scroll filter left
  s 360 211 500 211 200; p 1  # swipe filter tabs to find All
  t 90 211; p 2

  # --- Screen 6: Open Campaign Report ---
  step "Campaign report"
  # Scroll up to see first campaign
  s 360 600 360 1100 600; p 1
  # Tap Report button on first visible campaign (Orphan Education Fund)
  t 301 348; p 3   # Report button
  # Scroll report
  s 360 1000 360 600 600; p 2
  s 360 600 360 1000 600; p 1
  back; p 2

  # --- Screen 7: Create Campaign (FAB) ---
  step "Create Campaign"
  t 630 1472; p 1  # ensure on campaigns tab via nav
  t 265 1472; p 2  # campaigns tab
  t 620 1472; p 2  # FAB "New Campaign" — approx right side
  # Actually tap the FAB which appears bottom-right on campaigns screen
  t 630 1430; p 2
  p 1; back; p 2

  # --- Screen 8: Impact tab ---
  step "Impact Dashboard"
  t 450 1520; p 3
  s 360 1100 360 600 600; p 2
  s 360 600 360 1100 600; p 1

  # --- Screen 9: Donation Verification (from Dashboard) ---
  step "Donation Verification"
  t 90 1520; p 2   # Dashboard tab
  p 1
  t 360 560; p 3   # Donation Verification card (2nd Quick Action)
  s 360 1100 360 700 600; p 2
  back; p 2

  # --- Screen 10: Request Withdrawal ---
  step "Withdrawal Requests"
  t 90 1520; p 2   # Dashboard tab
  t 360 760; p 3   # Request Withdrawal card (4th Quick Action)
  p 2; back; p 2

  # --- Screen 11: More sheet ---
  step "More sheet"
  t 630 1520; p 2
  # Scroll sheet to see profile + sign out
  s 360 1200 360 800 500; p 2
  back; p 1

  stop_recording
}

journey_donor() {
  log "=== DONOR JOURNEY ==="
  fresh_launch
  start_recording "donor"
  p 2

  login_as "rich@donor.pk"
  p 2

  # --- Screen 1: Campaigns tab (money) ---
  step "Campaign list"
  p 3
  s 360 1100 360 600 600; p 2

  # --- Screen 2: Open a campaign to donate ---
  step "Campaign detail"
  t 360 500; p 3
  # Scroll detail
  s 360 1100 360 600 600; p 2
  s 360 600 360 1100 600; p 1
  back; p 2

  # --- Screen 3: InKind Donations tab ---
  step "InKind tab"
  t 360 1520; p 3   # 3rd nav tab
  s 360 1000 360 600 600; p 2

  # --- Screen 4: My Donations / Impact ---
  step "Donor Impact"
  t 504 1520; p 3
  s 360 1000 360 600 600; p 2

  # --- Screen 5: More sheet ---
  step "More sheet"
  t 648 1520; p 2
  s 360 1200 360 800 500; p 1
  back; p 1

  stop_recording
}

journey_volunteer() {
  log "=== VOLUNTEER JOURNEY ==="
  fresh_launch
  start_recording "volunteer"
  p 2

  login_as "ahmed@volunteer.pk"
  p 2

  # --- Screen 1: Impact Dashboard ---
  step "Volunteer Impact"
  p 3
  s 360 1000 360 600 600; p 2

  # --- Screen 2: Discover Tasks ---
  step "Discover Tasks"
  t 216 1520; p 3
  s 360 1000 360 600 600; p 2

  # --- Screen 3: Task Detail ---
  step "Task Detail"
  t 360 450; p 3
  s 360 1100 360 600 600; p 2
  # Claim button is near bottom
  s 360 600 360 1100 600; p 1
  back; p 2

  # --- Screen 4: My Tasks ---
  step "My Tasks"
  t 360 1520; p 3
  # If tasks present tap one
  t 360 450; p 2
  back; p 1

  # --- Screen 5: Messages ---
  step "Messages"
  t 504 1520; p 3
  p 2

  # --- Screen 6: More ---
  step "More sheet"
  t 648 1520; p 2
  back; p 1

  stop_recording
}

journey_coordinator() {
  log "=== COORDINATOR JOURNEY ==="
  fresh_launch
  start_recording "coordinator"
  p 2

  login_as "c1@field.pk"
  p 2

  # --- Screen 1: Tasks - All tab ---
  step "Tasks - All"
  p 3
  # TabBar: All=120, Active=360, Completed=600
  t 120 211; p 2
  s 360 1100 360 600 600; p 2

  # --- Screen 2: Active tab ---
  step "Tasks - Active"
  t 360 211; p 2
  # Tap a task
  t 360 410; p 3
  s 360 1100 360 600 600; p 2
  back; p 2

  # --- Screen 3: Review tab ---
  step "Delivery Reviews"
  t 216 1520; p 3
  # Tap a submission if present
  t 360 365; p 2
  back; p 1

  # --- Screen 4: Intelligence ---
  step "Intelligence Dashboard"
  t 360 1520; p 3
  s 360 1100 360 600 600; p 2
  s 360 600 360 1100 600; p 1

  # --- Screen 5: Broadcast Alert (from Intelligence) ---
  step "Broadcast Alert"
  # Look for FAB on intelligence screen
  t 660 1400; p 3
  p 2; back; p 2

  # --- Screen 6: Volunteers ---
  step "Volunteers"
  t 504 1520; p 3
  s 360 1000 360 600 600; p 2

  # --- Screen 7: More ---
  step "More sheet"
  t 648 1520; p 2
  back; p 1

  stop_recording
}

journey_beneficiary() {
  log "=== BENEFICIARY JOURNEY ==="
  fresh_launch
  start_recording "beneficiary"
  p 2

  login_as "zia@needs.pk"
  p 2

  # --- Screen 1: Home ---
  step "Beneficiary Home"
  p 3
  s 360 1000 360 600 600; p 2

  # --- Screen 2: My Requests ---
  step "My Requests"
  t 270 1520; p 3
  p 2

  # --- Screen 3: Aid Board ---
  step "Aid Board"
  t 450 1520; p 3
  s 360 1000 360 600 600; p 2

  # --- Screen 4: New Request (FAB) ---
  step "New Request form"
  t 90 1520; p 1   # back to Home
  p 1
  t 630 1400; p 3  # FAB
  s 360 1100 360 600 600; p 2
  back; p 2

  # --- Screen 5: More ---
  step "More sheet"
  t 630 1520; p 2
  back; p 1

  stop_recording
}

# =============================================================================
# STITCH FINAL VIDEO
# =============================================================================

stitch_all() {
  log "=== STITCHING FINAL VIDEO ==="

  local list="$BASE/concat.txt"
  > "$list"

  add() { echo "file '$1'" >> "$list"; }

  # Process each raw clip (normalise resolution + encode)
  for role in ngo donor volunteer coordinator beneficiary; do
    local raw="$CLIPS/${role}_journey.mp4"
    local proc="$PROCESSED/${role}_processed.mp4"
    if [[ -f "$raw" ]]; then
      log "Processing $role clip..."
      ffmpeg -y -loglevel error \
        -i "$raw" \
        -vf "scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2:black,fps=30" \
        -c:v libx264 -preset "$PRESET" -crf "$CRF" -pix_fmt yuv420p \
        -an "$proc"
      ok "  $proc"
    else
      err "Missing: $raw — skipping $role"
    fi
  done

  # Build concat list: intro → [rolecard + clip] × 5 → outro
  add "$TITLES/00_intro.mp4"
  for role in ngo donor volunteer coordinator beneficiary; do
    local card idx
    case $role in
      ngo)         idx=01 ;;
      donor)       idx=02 ;;
      volunteer)   idx=03 ;;
      coordinator) idx=04 ;;
      beneficiary) idx=05 ;;
    esac
    card="$TITLES/${idx}_${role}_card.mp4"
    local proc="$PROCESSED/${role}_processed.mp4"
    [[ -f "$card" ]] && add "$card"
    [[ -f "$proc" ]] && add "$proc"
  done
  add "$TITLES/99_outro.mp4"

  # Final encode
  ffmpeg -y -loglevel error \
    -f concat -safe 0 -i "$list" \
    -c:v libx264 -preset "$PRESET" -crf "$CRF" -pix_fmt yuv420p \
    "$FINAL"

  ok "Final video: $FINAL"
  du -sh "$FINAL"
}

# =============================================================================
# MAIN
# =============================================================================

trap 'stop_recording; dnd_off' EXIT INT TERM

mkdir -p "$CLIPS" "$PROCESSED" "$TITLES"

case "${1:-all}" in
  ngo)          setup_device; dnd_on; journey_ngo;         teardown_device ;;
  donor)        setup_device; dnd_on; journey_donor;       teardown_device ;;
  volunteer)    setup_device; dnd_on; journey_volunteer;   teardown_device ;;
  coordinator)  setup_device; dnd_on; journey_coordinator; teardown_device ;;
  beneficiary)  setup_device; dnd_on; journey_beneficiary; teardown_device ;;
  stitch)       generate_all_title_cards; stitch_all ;;
  all)
    setup_device
    dnd_on
    journey_ngo
    journey_donor
    journey_volunteer
    journey_coordinator
    journey_beneficiary
    dnd_off
    generate_all_title_cards
    stitch_all
    teardown_device
    ok "ALL DONE — $FINAL"
    ;;
  *)
    echo "Usage: $0 [all|ngo|donor|volunteer|coordinator|beneficiary|stitch]"
    exit 1
    ;;
esac
