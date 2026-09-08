#!/usr/bin/env bash
set -euo pipefail

# build-images.sh
# Capture screenshots for missing/stale entries of a target's state registry (Android).
#
# Usage:
#   appeus/scripts/build-images.sh [--target <name>] [--reuse] [--window] [--force] [--dry-run]
#
#   --reuse     reuse a running emulator (fail if none)
#   --window    show the emulator window (not headless)
#   --force     recapture every entry, even if fresh
#   --dry-run   list what would be captured, and why, without touching a device
#
# The registry is design/generated/<target>/images/index.md; appId, scheme and the deep
# link for each entry come from scripts/lib/scenarios.js (the same formula open-deeplink.sh
# and the preview use). Entries with `capture: false` are listed states, not screenshots,
# and are skipped here. An image is stale when missing, or older than any `deps` file or
# the screen's source file.
#
# If exactly one target exists, --target defaults to it. Requires node/npx and adb.
# Env: APPEUS_ANDROID_AVD, APPEUS_SCREEN_DELAY, APPEUS_DEVICE (see android-screenshot.sh).

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
# shellcheck source=lib/scenarios.sh
source "${SCRIPT_DIR}/lib/scenarios.sh"

TARGET="" REUSE_FLAG="" WINDOW_FLAG="" FORCE=0 DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --reuse) REUSE_FLAG="--reuse"; shift ;;
    --window) WINDOW_FLAG="--window"; shift ;;
    --force) FORCE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) sed -n '/^# Usage:/,/^# Env:/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project (with design/ and appeus/ at the root), or set APPEUS_PROJECT_DIR." >&2
  exit 1
}
TARGET="$(appeus_resolve_target "$PROJECT_DIR" "$TARGET")" || exit 1

GEN_DIR="${PROJECT_DIR}/design/generated/${TARGET}"
SRC_DIR="${PROJECT_DIR}/apps/${TARGET}/src"
OUT_DIR="${GEN_DIR}/images"
INDEX="${OUT_DIR}/index.md"
HELPER="${SCRIPT_DIR}/android-screenshot.sh"

[[ -f "$INDEX" ]] || {
  echo "Error: no registry at ${INDEX#${PROJECT_DIR}/}" >&2
  echo "Run add-app.sh for this target, then add entries under 'screenshots:' in its frontmatter." >&2
  exit 1
}

APP_ID="" SCHEME=""
while IFS=$'\t' read -r k v; do
  case "$k" in appId) APP_ID="$v" ;; scheme) SCHEME="$v" ;; esac
done < <(appeus_scenarios_js meta --project "$PROJECT_DIR" --target "$TARGET")
[[ -n "$SCHEME" ]] || { echo "Error: ${INDEX#${PROJECT_DIR}/} names no 'scheme:'; deep links cannot be built." >&2; exit 1; }

REGISTRY="$(appeus_scenarios_js registry --project "$PROJECT_DIR" --target "$TARGET")"
[[ -n "$REGISTRY" ]] || { echo "No entries under 'screenshots:' in ${INDEX#${PROJECT_DIR}/}."; exit 0; }

echo "App ID: ${APP_ID:-<none>}"
echo "Scheme: ${SCHEME}"
echo ""

mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0; }

# Echo why the image is stale; nothing when fresh.
stale_reason() { # $1 = output, $2.. = deps
  local output="$1"; shift
  [[ -f "$output" ]] || { echo "missing"; return; }
  local out_m dep
  out_m="$(mtime "$output")"
  for dep in "$@"; do
    [[ -f "$dep" ]] || continue
    if [[ "$(mtime "$dep")" -gt "$out_m" ]]; then echo "older than ${dep#${PROJECT_DIR}/}"; return; fi
  done
}

captured=0 skipped=0 listed=0
while IFS=$'\x1f' read -r id route variant file capture link deps; do
  [[ -n "$route" ]] || continue
  if [[ "$capture" != "1" ]]; then
    echo "listed  ${id} (capture: false) ${link}"
    listed=$((listed + 1))
    continue
  fi
  output="${OUT_DIR}/${file}"
  dep_paths=()
  if [[ -n "$deps" ]]; then
    while IFS= read -r d; do [[ -n "$d" ]] && dep_paths+=("${PROJECT_DIR}/${d}"); done < <(printf '%s' "$deps" | tr ',' '\n')
  fi
  # The screen's source is always a dependency; the route may carry path segments.
  screen_file="${SRC_DIR}/screens/${route%%/*}.tsx"
  [[ -f "$screen_file" ]] && dep_paths+=("$screen_file")

  reason="$(stale_reason "$output" ${dep_paths[@]+"${dep_paths[@]}"})"
  [[ "$FORCE" = "1" ]] && reason="forced"
  if [[ -z "$reason" ]]; then
    echo "fresh   ${file}"
    skipped=$((skipped + 1))
    continue
  fi
  if [[ "$DRY_RUN" = "1" ]]; then
    echo "would capture ${file} (${reason}): ${link}"
    captured=$((captured + 1))
    continue
  fi
  echo "capture ${file} (${reason}): ${link}"
  "$HELPER" --deeplink "$link" --output "$output" --app-id "$APP_ID" ${REUSE_FLAG} ${WINDOW_FLAG}
  captured=$((captured + 1))
done <<< "$REGISTRY"

echo ""
if [[ "$DRY_RUN" = "1" ]]; then
  echo "Dry run. Would capture: ${captured}; fresh: ${skipped}; listed only: ${listed}."
else
  echo "Done. Captured: ${captured}; fresh: ${skipped}; listed only: ${listed}. Images at ${OUT_DIR#${PROJECT_DIR}/}"
fi
