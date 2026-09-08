#!/usr/bin/env bash
set -euo pipefail

# android-screenshot.sh
# Open a deep link on an Android emulator (starting one if needed) and capture a PNG.
# Usually called by build-images.sh; the launch itself goes through open-deeplink.sh.
#
# Usage:
#   appeus/scripts/android-screenshot.sh --deeplink "myapp://screen/ItemList?variant=happy" \
#     [--output path.png] [--app-id com.example.app] [--serial emulator-5554] \
#     [--avd Medium_Phone_API_34] [--delay 8] [--reuse] [--window]
#
#   --serial   device to use; default: $APPEUS_DEVICE, else the first running emulator
#   --reuse    never start an emulator (fail if none is running)
#   --window   start the emulator with a window (default: headless)
#   --delay    seconds between launching the link and capturing (default: $APPEUS_SCREEN_DELAY or 8).
#              First paint after a cold start of a React Native release build can take 10–20 s;
#              warm the app once before a capture run, or raise this.
#
# Env defaults: APPEUS_ANDROID_AVD (Medium_Phone_API_34), APPEUS_SCREEN_DELAY (8), APPEUS_APP_ID, APPEUS_DEVICE

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AVD="${APPEUS_ANDROID_AVD:-Medium_Phone_API_34}"
APP_ID="${APPEUS_APP_ID:-}"
DELAY="${APPEUS_SCREEN_DELAY:-8}"
SERIAL="${APPEUS_DEVICE:-}"
DEEPLINK="" OUTPUT="screenshot.png" REUSE=0 HEADLESS=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deeplink) DEEPLINK="${2:-}"; shift 2 ;;
    --output) OUTPUT="${2:-}"; shift 2 ;;
    --app-id) APP_ID="${2:-}"; shift 2 ;;
    --avd) AVD="${2:-}"; shift 2 ;;
    --delay) DELAY="${2:-}"; shift 2 ;;
    --serial) SERIAL="${2:-}"; shift 2 ;;
    --reuse) REUSE=1; shift ;;
    --window) HEADLESS=0; shift ;;
    -h|--help) sed -n '/^# Usage:/,/^# Env defaults/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown flag: $1" >&2; exit 1 ;;
  esac
done
[[ -n "$DEEPLINK" ]] || { echo "Error: --deeplink is required" >&2; exit 1; }
command -v adb >/dev/null 2>&1 || { echo "Error: adb not found on PATH" >&2; exit 1; }

# First running emulator's serial, or empty.
first_emulator() {
  adb devices 2>/dev/null | awk 'NR>1 && $1 ~ /^emulator-/ && $2=="device" { print $1; exit }'
}

wait_for_boot() { # $1 = serial
  adb -s "$1" wait-for-device >/dev/null 2>&1 || true
  local tries=0
  while [[ "$(adb -s "$1" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
    sleep 1
    tries=$((tries + 1))
    [[ $tries -le 180 ]] || { echo "Error: timeout waiting for $1 to boot" >&2; exit 1; }
  done
}

start_emulator() {
  local emu=""
  if command -v emulator >/dev/null 2>&1; then emu="emulator"
  elif [[ -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/emulator/emulator" ]]; then emu="$ANDROID_HOME/emulator/emulator"
  elif [[ -n "${ANDROID_SDK_ROOT:-}" && -x "$ANDROID_SDK_ROOT/emulator/emulator" ]]; then emu="$ANDROID_SDK_ROOT/emulator/emulator"
  else echo "Error: emulator binary not found in PATH, ANDROID_HOME or ANDROID_SDK_ROOT." >&2; exit 1
  fi
  echo "Starting emulator: $AVD"
  if [[ "$HEADLESS" = "1" ]]; then nohup "$emu" -avd "$AVD" -no-snapshot-load -no-window >/dev/null 2>&1 &
  else nohup "$emu" -avd "$AVD" -no-snapshot-load >/dev/null 2>&1 &
  fi
  local tries=0
  while [[ -z "$(first_emulator)" ]]; do
    sleep 2
    tries=$((tries + 1))
    [[ $tries -le 60 ]] || { echo "Error: emulator did not appear in 'adb devices'" >&2; exit 1; }
  done
}

# Choose the device in this shell — no subshell, so SERIAL survives.
if [[ -z "$SERIAL" ]]; then
  SERIAL="$(first_emulator)"
  if [[ -z "$SERIAL" ]]; then
    [[ "$REUSE" = "0" ]] || { echo "Error: no running emulator and --reuse given." >&2; exit 1; }
    start_emulator
    SERIAL="$(first_emulator)"
  fi
fi
wait_for_boot "$SERIAL"

mkdir -p "$(dirname "$OUTPUT")"
"${SCRIPT_DIR}/open-deeplink.sh" --link "$DEEPLINK" --device "$SERIAL" --wait ${APP_ID:+--app-id "$APP_ID"}
sleep "$DELAY"
adb -s "$SERIAL" exec-out screencap -p > "$OUTPUT"
echo "Captured $OUTPUT from $SERIAL"
