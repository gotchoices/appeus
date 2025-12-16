#!/usr/bin/env bash
set -euo pipefail

# Picks the next stale screen (vertical slice) and prints an AI-facing plan.
# Supports both single-app and multi-app project structures.
#
# Usage:
#   appeus/scripts/generate-next.sh [--target <name>]
#
# In multi-app projects, --target is required.

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project (with design/ and appeus/ at the root), or set APPEUS_PROJECT_DIR." >&2
  exit 1
}
DESIGN_DIR="${PROJECT_DIR}/design"

TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target <name>]"
      echo ""
      echo "Pick the next stale screen and print a regeneration plan."
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Detect single-app vs multi-app mode
is_single_app_mode() {
  if [ -d "${DESIGN_DIR}/specs/screens" ]; then
    local target_count
    target_count=$(find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$target_count" = "0" ]; then
      return 0
    fi
  fi
  return 1
}

# Determine status file path
if is_single_app_mode; then
  STATUS_FILE="${DESIGN_DIR}/generated/status.json"
  TARGET_ARG=""
else
  if [ -z "$TARGET" ]; then
    echo "Error: Multi-app project detected. --target is required." >&2
    echo ""
    echo "Available targets:"
    find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" -exec basename {} \; 2>/dev/null
    exit 1
  fi
  STATUS_FILE="${DESIGN_DIR}/generated/${TARGET}/status.json"
  TARGET_ARG="--target ${TARGET}"
fi

# Run check-stale if status file is missing
if [ ! -f "${STATUS_FILE}" ]; then
  echo "Running check-stale to generate status..."
  "${SCRIPT_DIR}/check-stale.sh" ${TARGET_ARG} >/dev/null
fi

if [ ! -f "${STATUS_FILE}" ]; then
  echo "No status.json and cannot compute staleness. Abort." >&2
  exit 1
fi

# Find stale screens
STALE_SCREENS="$(jq -r '.screens[] | select(.stale==true) | .route' "${STATUS_FILE}" 2>/dev/null || true)"

if [ -z "${STALE_SCREENS}" ]; then
  echo "All screens appear up to date."
  exit 0
fi

NEXT="$(printf '%s\n' "${STALE_SCREENS}" | head -n1)"
STALE_COUNT="$(printf '%s\n' "${STALE_SCREENS}" | wc -l | tr -d ' ')"

echo "Next vertical slice target: ${NEXT}"
echo "(${STALE_COUNT} stale screen(s) total)"
echo ""

"${SCRIPT_DIR}/regenerate.sh" ${TARGET_ARG} --screen "${NEXT}"
