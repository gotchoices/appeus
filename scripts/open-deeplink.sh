#!/usr/bin/env bash
set -euo pipefail

# open-deeplink.sh
# Open one registered state — or any deep link — on a connected Android device/emulator
# or a booted iOS simulator. Used by agents to show a slice, by the scenario preview
# server for each click, and by android-screenshot.sh before it captures.
#
# Usage:
#   appeus/scripts/open-deeplink.sh [--target <name>] --route <Route> [--variant <v>] [--locale <l>] [--params k=v]...
#   appeus/scripts/open-deeplink.sh [--target <name>] --id <registry id> | --file <image file>
#   appeus/scripts/open-deeplink.sh [--target <name>] --link <scheme://screen/...>
#   appeus/scripts/open-deeplink.sh --list
#
# Options:
#   --device auto|android|ios|<serial|udid>   device to use (default: $APPEUS_DEVICE, else auto)
#   --app-id <package>   Android package that should receive the link (default: registry appId)
#   --wait               Android: wait for the activity to launch (am start -W)
#   --dry-run            print the launch command instead of running it
#   --list               print connected devices as: kind<TAB>id<TAB>label
#
# The link for --route/--id/--file comes from the target's registry
# (design/generated/<target>/images/index.md) via scripts/lib/scenarios.js, so it is
# built by the same formula build-images.sh and the preview server use.
#
# Exit codes: 0 opened · 2 no device · 3 several devices (name one with --device) · 1 other

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
# shellcheck source=lib/scenarios.sh
source "${SCRIPT_DIR}/lib/scenarios.sh"

TARGET="" ROUTE="" VARIANT="" LOCALE="" ID="" FILE="" LINK="" APP_ID=""
DEVICE="${APPEUS_DEVICE:-auto}"
WAIT=0 DRY_RUN=0 LIST=0
PARAMS=()

usage() { sed -n '/^# Usage:/,/^# Exit codes/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --route) ROUTE="${2:-}"; shift 2 ;;
    --variant) VARIANT="${2:-}"; shift 2 ;;
    --locale) LOCALE="${2:-}"; shift 2 ;;
    --params) PARAMS+=("${2:-}"); shift 2 ;;
    --id) ID="${2:-}"; shift 2 ;;
    --file) FILE="${2:-}"; shift 2 ;;
    --link) LINK="${2:-}"; shift 2 ;;
    --device) DEVICE="${2:-auto}"; shift 2 ;;
    --app-id) APP_ID="${2:-}"; shift 2 ;;
    --wait) WAIT=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --list) LIST=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Error: Unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

# Connected devices, one per line: kind<TAB>id<TAB>label
list_devices() {
  if command -v adb >/dev/null 2>&1; then
    adb devices -l 2>/dev/null | awk 'NR>1 && $2=="device" {
      label=""; for (i=3;i<=NF;i++) if ($i ~ /^model:/) label=substr($i,7);
      printf "android\t%s\t%s\n", $1, label }'
  fi
  if command -v xcrun >/dev/null 2>&1; then
    { xcrun simctl list devices booted 2>/dev/null || true; } \
      | sed -nE 's/^ +(.*) \(([0-9A-Fa-f-]{36})\) \(Booted\).*$/ios\t\2\t\1/p'
  fi
}

if [[ "$LIST" = "1" ]]; then
  list_devices
  exit 0
fi

# ---- resolve the link (and appId) ----
if [[ -z "$LINK" ]]; then
  [[ -n "$ROUTE" || -n "$ID" || -n "$FILE" ]] || { echo "Error: give --route, --id, --file or --link (see --help)" >&2; exit 1; }
  PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
    echo "Error: Could not find project root. Run from inside your project, or set APPEUS_PROJECT_DIR." >&2
    exit 1
  }
  TARGET="$(appeus_resolve_target "$PROJECT_DIR" "$TARGET")" || exit 1
  args=(link --project "$PROJECT_DIR" --target "$TARGET")
  if [[ -n "$ID" ]]; then args+=(--id "$ID")
  elif [[ -n "$FILE" ]]; then args+=(--file "$FILE")
  else
    args+=(--route "$ROUTE")
    [[ -n "$VARIANT" ]] && args+=(--variant "$VARIANT")
    [[ -n "$LOCALE" ]] && args+=(--locale "$LOCALE")
    for kv in ${PARAMS[@]+"${PARAMS[@]}"}; do args+=(--params "$kv"); done
  fi
  IFS=$'\x1f' read -r LINK REG_APP_ID _scheme < <(appeus_scenarios_js "${args[@]}") || exit 1
  [[ -n "$APP_ID" ]] || APP_ID="${REG_APP_ID:-}"
fi

case "$LINK" in
  *://*) ;;
  *) echo "Error: '$LINK' is not a <scheme>:// link" >&2; exit 1 ;;
esac

# ---- pick a device ----
KIND="" DEVICE_ID=""
rows="$(list_devices | awk 'NF')"
case "$DEVICE" in
  auto) ;;
  android|ios) rows="$(printf '%s\n' "$rows" | awk -F'\t' -v k="$DEVICE" '$1==k')" ;;
  *)
    match="$(printf '%s\n' "$rows" | awk -F'\t' -v id="$DEVICE" '$2==id')"
    if [[ -z "$match" ]]; then
      # Not in the list (adb may be absent, or the device just booted): trust the caller.
      if [[ "$DEVICE" =~ ^[0-9A-Fa-f-]{36}$ ]]; then KIND=ios; else KIND=android; fi
      DEVICE_ID="$DEVICE"
    fi
    rows="$match"
    ;;
esac
if [[ -z "$KIND" ]]; then
  if [[ -z "$rows" ]]; then
    echo "Error: no connected Android device/emulator or booted iOS simulator (device: ${DEVICE})." >&2
    exit 2
  fi
  count="$(printf '%s\n' "$rows" | wc -l | tr -d ' ')"
  if [[ "$count" != "1" ]]; then
    echo "Error: ${count} devices connected; choose one with --device <id> (or APPEUS_DEVICE):" >&2
    printf '%s\n' "$rows" >&2
    exit 3
  fi
  KIND="$(printf '%s' "$rows" | cut -f1)"
  DEVICE_ID="$(printf '%s' "$rows" | cut -f2)"
fi

# ---- launch ----
case "$KIND" in
  android)
    # The command runs in the device's shell, so the link must be quoted there:
    # an unquoted `&` in the query string would background `am start`.
    quoted="'${LINK//\'/\'\\\'\'}'"
    am="am start"
    [[ "$WAIT" = "1" ]] && am="$am -W"
    am="$am -a android.intent.action.VIEW -d $quoted"
    [[ -n "$APP_ID" ]] && am="$am $APP_ID"
    cmd=(adb -s "$DEVICE_ID" shell "$am")
    ;;
  ios)
    cmd=(xcrun simctl openurl "$DEVICE_ID" "$LINK")
    ;;
esac

if [[ "$DRY_RUN" = "1" ]]; then
  printf '%q ' "${cmd[@]}"; echo
  exit 0
fi

# `am start` reports resolution failures on stdout, sometimes with exit 0.
status=0; out="$("${cmd[@]}" 2>&1)" || status=$?
if [[ "$status" != "0" ]] || printf '%s' "$out" | grep -q 'Error'; then
  msg="$(printf '%s\n' "$out" | grep -m1 'Error' || printf '%s\n' "$out" | head -n 1)"
  echo "Error: ${msg#Error: }" >&2
  [[ -n "$APP_ID" ]] && echo "  (is ${APP_ID} installed on ${DEVICE_ID}, and does it register the ${LINK%%://*}:// scheme?)" >&2
  exit 1
fi
echo "Opened ${LINK} on ${KIND} ${DEVICE_ID}"
