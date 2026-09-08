#!/usr/bin/env bash
set -euo pipefail

# publish-scenarios.sh
# Render a target's scenarios to a static site and optionally rsync it to a destination.
#
# Usage:
#   appeus/scripts/publish-scenarios.sh [--target <name>] [--dest user@host:/path] [--dry-run]
#
# Output: design/generated/<target>/site/ — scenarios/*.html, states.html (every registry
# entry), images/, index.html. Deep links are left raw: a published page has no device to
# talk to, but a phone with the app installed resolves them itself.
#
# If exactly one target exists, --target defaults to it. Requires node/npx.
# Env: APPEUS_PUBLISH_DEST provides the default destination.

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
# shellcheck source=lib/scenarios.sh
source "${SCRIPT_DIR}/lib/scenarios.sh"

TARGET="" DEST="${APPEUS_PUBLISH_DEST:-}" DRYRUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --dest) DEST="${2:-}"; shift 2 ;;
    --dry-run) DRYRUN=1; shift ;;
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
SITE_DIR="${GEN_DIR}/site"

[[ -d "${GEN_DIR}/scenarios" || -f "${GEN_DIR}/images/index.md" ]] || {
  echo "Error: nothing to publish under ${GEN_DIR#${PROJECT_DIR}/} (no scenarios/ and no images/index.md)." >&2
  exit 1
}

appeus_scenarios_js build --project "$PROJECT_DIR" --target "$TARGET" --out "$SITE_DIR"

if [[ -z "$DEST" ]]; then
  echo "No destination provided. Set APPEUS_PUBLISH_DEST or pass --dest user@host:/path"
  exit 0
fi
echo "Publishing to ${DEST} …"
if [[ "$DRYRUN" -eq 1 ]]; then
  echo "rsync -avz --delete \"${SITE_DIR}/\" \"${DEST}/\""
  exit 0
fi
command -v rsync >/dev/null 2>&1 || { echo "rsync not found. Copy ${SITE_DIR}/ to ${DEST} manually." >&2; exit 2; }
rsync -avz --delete "${SITE_DIR}/" "${DEST}/"
echo "Publish complete."
