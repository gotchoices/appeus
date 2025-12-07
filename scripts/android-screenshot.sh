#!/usr/bin/env bash
# Wrapper name retained for clarity; identical to capture-android-screenshot.sh
set -euo pipefail

# Android deep-link screenshot helper
# - Launches (or reuses) an emulator
# - Opens a deep link in the target app
# - Captures a PNG screenshot to the given path
#
# Usage:
#   appeus/scripts/android-screenshot.sh \
#     --deeplink "myapp://screen/ItemList?variant=happy" \
#     --output "./design/generated/images/item-list-happy.png" \
#     --app-id "com.example.myapp" \
#     --avd "Medium_Phone_API_34" \
#     --delay 3 \
#     --reuse
#
# Environment defaults (can be overridden by flags):
#   APPEUS_ANDROID_AVD   (default: Medium_Phone_API_34)
#   APPEUS_APP_ID        (optional, currently unused but accepted for compatibility)
#   APPEUS_SCREEN_DELAY  (default: 3)
#

AVD="${APPEUS_ANDROID_AVD:-Medium_Phone_API_34}"
APP_ID="${APPEUS_APP_ID:-}"
DELAY="${APPEUS_SCREEN_DELAY:-3}"
DEEPLINK=""
OUTPUT="screenshot.png"
REUSE=0
HEADLESS=1
SERIAL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --deeplink) DEEPLINK="${2:-}"; shift 2 ;;
    --output) OUTPUT="${2:-}"; shift 2 ;;
    --app-id) APP_ID="${2:-}"; shift 2 ;;
    --avd) AVD="${2:-}"; shift 2 ;;
    --delay) DELAY="${2:-}"; shift 2 ;;
    --reuse) REUSE=1; shift ;;
    --window) HEADLESS=0; shift ;;
    --serial) SERIAL="${2:-}"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --deeplink URL [--output PATH] [--app-id ID] [--avd NAME] [--delay SECONDS] [--reuse] [--window] [--serial emulator-5554]"
      exit 0
      ;;
    *)
      echo "Unknown flag: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$DEEPLINK" ]]; then
  echo "Error: --deeplink is required"
  exit 1
fi

ensure_output_dir() {
  local dir
  dir="$(dirname "$OUTPUT")"
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
  fi
}

pick_emulator_serial() {
  # Returns first emulator serial or empty
  local s
  s="$(adb devices | sed -n '2,$p' | awk '/\tdevice$/{print $1; exit}')"
  # Trim CR/LF and spaces just in case
  printf "%s" "$s" | tr -d '\r\n[:space:]'
}

adb_target() {
  if [[ -n "$SERIAL" ]]; then
    adb -s "$SERIAL" "$@"
  else
    # target first emulator
    adb -e "$@"
  fi
}

wait_for_boot() {
  # Wait until a device/emulator is up and booted
  adb_target wait-for-device || true
  local tries=0
  while [[ "$(adb_target shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" != "1" ]]; do
    sleep 1
    tries=$((tries+1)); if [[ $tries -gt 180 ]]; then echo "Timeout waiting for boot_completed"; exit 1; fi
  done
}

launch_emulator_if_needed() {
  local serial=""
  if [[ -z "$SERIAL" ]]; then
    serial="$(pick_emulator_serial || true)"
  else
    serial="$SERIAL"
  fi
  if [[ -n "$serial" ]]; then
    echo "Using running emulator: $serial"
    SERIAL="$serial"
    echo "$SERIAL"
    return 0
  fi
  if [[ "$REUSE" -eq 1 ]]; then
    echo "No running emulator found and --reuse specified. Exiting."
    exit 1
  fi
  echo "Starting emulator: $AVD"
  if command -v emulator >/dev/null 2>&1; then
    if [[ "$HEADLESS" -eq 1 ]]; then
      nohup emulator -avd "$AVD" -no-snapshot-load -no-window >/dev/null 2>&1 &
    else
      nohup emulator -avd "$AVD" -no-snapshot-load >/dev/null 2>&1 &
    fi
  else
    # Try ANDROID_HOME/ANDROID_SDK_ROOT fallback
    EMU=""
    if [[ -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/emulator/emulator" ]]; then
      EMU="$ANDROID_HOME/emulator/emulator"
    elif [[ -n "${ANDROID_SDK_ROOT:-}" && -x "$ANDROID_SDK_ROOT/emulator/emulator" ]]; then
      EMU="$ANDROID_SDK_ROOT/emulator/emulator"
    fi
    if [[ -z "$EMU" ]]; then
      echo "Error: emulator binary not found in PATH, ANDROID_HOME or ANDROID_SDK_ROOT."
      exit 1
    fi
    if [[ "$HEADLESS" -eq 1 ]]; then
      nohup "$EMU" -avd "$AVD" -no-snapshot-load -no-window >/dev/null 2>&1 &
    else
      nohup "$EMU" -avd "$AVD" -no-snapshot-load >/dev/null 2>&1 &
    fi
  fi
  # Allow process to start and then wait
  sleep 2
  wait_for_boot
  SERIAL="$(pick_emulator_serial || true)"
  echo "$SERIAL"
}

main() {
  ensure_output_dir
  local serial=""
  serial="$(launch_emulator_if_needed)"
  if [[ -n "$serial" ]]; then
    wait_for_boot
    echo "Deep-linking on $serial: $DEEPLINK"
    adb_target shell am start -W -a android.intent.action.VIEW -d "$DEEPLINK" >/dev/null
    sleep "$DELAY"
    echo "Capturing screenshot to $OUTPUT"
    adb_target exec-out screencap -p > "$OUTPUT"
  else
    wait_for_boot
    echo "Deep-linking: $DEEPLINK"
    adb_target shell am start -W -a android.intent.action.VIEW -d "$DEEPLINK" >/dev/null
    sleep "$DELAY"
    echo "Capturing screenshot to $OUTPUT"
    adb_target exec-out screencap -p > "$OUTPUT"
  fi
  echo "Done: $OUTPUT"
}

main "$@"


