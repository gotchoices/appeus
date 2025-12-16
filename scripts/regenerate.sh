#!/usr/bin/env bash
set -euo pipefail

# Regeneration planner (prompt-only) for Appeus v2.
# Prints an AI-facing plan for a specific slice.
#
# Usage:
#   appeus/scripts/regenerate.sh [--target <name>] --screen <Route>
#   appeus/scripts/regenerate.sh [--target <name>] --api <Namespace>
#   appeus/scripts/regenerate.sh [--target <name>]
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
TARGET_KIND=""
TARGET_VAL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --screen) TARGET_KIND="screen"; TARGET_VAL="$2"; shift 2 ;;
    --api) TARGET_KIND="api"; TARGET_VAL="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target <name>] [--screen <Route> | --api <Namespace>]"
      echo ""
      echo "Print a regeneration plan for the agent to follow."
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
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

# Determine paths based on mode
if is_single_app_mode; then
  SPECS_DIR="${DESIGN_DIR}/specs"
  STORIES_DIR="${DESIGN_DIR}/stories"
  GENERATED_DIR="${DESIGN_DIR}/generated"
  
  APP_DIR=$(find "${PROJECT_DIR}/apps" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
  if [ -z "$APP_DIR" ]; then
    SRC_DIR="${PROJECT_DIR}/src"
    APP_NAME="(root)"
  else
    SRC_DIR="${APP_DIR}/src"
    APP_NAME="$(basename "$APP_DIR")"
  fi
else
  if [ -z "$TARGET" ]; then
    echo "Error: Multi-app project detected. --target is required." >&2
    echo ""
    echo "Available targets:"
    find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" -exec basename {} \; 2>/dev/null
    exit 1
  fi
  
  SPECS_DIR="${DESIGN_DIR}/specs/${TARGET}"
  STORIES_DIR="${DESIGN_DIR}/stories/${TARGET}"
  GENERATED_DIR="${DESIGN_DIR}/generated/${TARGET}"
  SRC_DIR="${PROJECT_DIR}/apps/${TARGET}/src"
  APP_NAME="${TARGET}"
fi

echo "Appeus regenerate (planner)"
echo ""
if [ -n "$TARGET" ]; then
  echo "App target: ${TARGET}"
fi
if [ -n "${TARGET_KIND}" ]; then
  echo "Slice: ${TARGET_KIND}=${TARGET_VAL}"
else
  echo "Slice: all (agent should pick next vertical slice)"
fi
echo ""
echo "Paths:"
echo " - Stories:        ${STORIES_DIR}"
echo " - Human specs:    ${SPECS_DIR}"
echo " - Schema specs:   ${DESIGN_DIR}/specs/schema (shared)"
echo " - API specs:      ${DESIGN_DIR}/specs/api (shared)"
echo " - Consolidations: ${GENERATED_DIR}"
echo " - App source:     ${SRC_DIR}"
echo " - Mocks:          ${PROJECT_DIR}/mock/data (shared)"
echo ""

if [ "${TARGET_KIND}" = "screen" ] && [ -n "${TARGET_VAL}" ]; then
  KEBAB="$(echo "${TARGET_VAL}" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | tr '[:upper:]' '[:lower:]')"
  echo "Plan for screen: ${TARGET_VAL}"
  echo ""
  echo "1) Refresh screen consolidation:"
  echo "   ${GENERATED_DIR}/screens/${TARGET_VAL}.md"
  echo "   dependsOn: stories, specs/screens/${KEBAB}.md?, navigation.md, global/*, schema/*"
  echo ""
  echo "2) Refresh required API consolidations (from 'needs' in consolidation)"
  echo ""
  echo "3) Generate/refresh mocks under mock/data for required namespaces"
  echo "   Write .meta.json with dependency tracking"
  echo ""
  echo "4) Generate/refresh data adapters in ${SRC_DIR}/data/"
  echo ""
  echo "5) Generate/refresh screen code:"
  echo "   ${SRC_DIR}/screens/${TARGET_VAL}.tsx (or equivalent)"
  echo "   Update ${SRC_DIR}/navigation/"
  echo ""
  echo "6) Generate scenarios for stories referencing ${TARGET_VAL}:"
  echo "   ${GENERATED_DIR}/scenarios/<story-id>.md"
  echo ""
  echo "7) Update staleness tracking:"
  echo "   Run: appeus/scripts/update-dep-hashes.sh --route ${TARGET_VAL}"
  echo "   Then: appeus/scripts/check-stale.sh"
elif [ "${TARGET_KIND}" = "api" ] && [ -n "${TARGET_VAL}" ]; then
  echo "Plan for API namespace: ${TARGET_VAL}"
  echo ""
  echo "1) Refresh API consolidation:"
  echo "   ${DESIGN_DIR}/generated/api/${TARGET_VAL}.md"
  echo ""
  echo "2) Generate/refresh mock data:"
  echo "   mock/data/${TARGET_VAL}.happy.json"
  echo "   mock/data/${TARGET_VAL}.empty.json"
  echo "   mock/data/${TARGET_VAL}.error.json"
  echo "   mock/data/${TARGET_VAL}.meta.json"
  echo ""
  echo "3) Update data adapters in ${SRC_DIR}/data/"
else
  echo "Plan: vertical slice"
  echo ""
  echo "1) Run: appeus/scripts/check-stale.sh $([ -n "$TARGET" ] && echo "--target $TARGET")"
  echo "   Get per-screen staleness status"
  echo ""
  echo "2) Pick the next stale, reachable screen"
  echo ""
  echo "3) Apply screen plan (steps 1-7) for that screen"
fi

echo ""
echo "Notes:"
echo " - Precedence: specs > consolidations > defaults"
echo " - Embed dependency metadata (dependsOn/depHashes) in consolidations"
echo " - Do not overwrite human-authored specs"
echo " - Schema and API specs are shared across all targets"
