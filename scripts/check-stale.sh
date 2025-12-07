#!/usr/bin/env bash
set -euo pipefail

# Per-screen staleness report for Appeus v2.
# Supports both single-app and multi-app project structures.
#
# Usage:
#   appeus/scripts/check-stale.sh [--target <name>]
#
# In single-app mode, --target is optional.
# In multi-app mode, --target is required.

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DESIGN_DIR="${PROJECT_DIR}/design"

# Parse arguments
TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target <name>]"
      echo ""
      echo "Check staleness of screens for a target app."
      echo "In multi-app projects, --target is required."
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[ -d "${DESIGN_DIR}" ] || { echo "No design/ directory."; exit 1; }

# Detect single-app vs multi-app mode
is_single_app_mode() {
  if [ -d "${DESIGN_DIR}/specs/screens" ]; then
    # Check if there are target subdirs in specs (excluding screens, schema, api, global)
    local target_count
    target_count=$(find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$target_count" = "0" ]; then
      return 0  # single-app mode
    fi
  fi
  return 1  # multi-app mode
}

# Determine paths based on mode
if is_single_app_mode; then
  if [ -n "$TARGET" ]; then
    echo "Warning: --target specified but project is in single-app mode. Ignoring." >&2
  fi
  
  SPECS_SCREENS_DIR="${DESIGN_DIR}/specs/screens"
  SPECS_NAV_FILE="${DESIGN_DIR}/specs/navigation.md"
  SPECS_GLOBAL_DIR="${DESIGN_DIR}/specs/global"
  STORIES_DIR="${DESIGN_DIR}/stories"
  GENERATED_DIR="${DESIGN_DIR}/generated"
  META_FILE="${GENERATED_DIR}/meta/outputs.json"
  STATUS_FILE="${GENERATED_DIR}/status.json"
  
  # Find the app directory (should be only one in apps/)
  APP_DIR=$(find "${PROJECT_DIR}/apps" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
  if [ -z "$APP_DIR" ]; then
    # Fallback to root src/ for v1 compatibility
    SRC_DIR="${PROJECT_DIR}/src"
  else
    SRC_DIR="${APP_DIR}/src"
  fi
else
  # Multi-app mode
  if [ -z "$TARGET" ]; then
    echo "Error: Multi-app project detected. --target is required." >&2
    echo ""
    echo "Available targets:"
    find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" -exec basename {} \; 2>/dev/null
    exit 1
  fi
  
  SPECS_SCREENS_DIR="${DESIGN_DIR}/specs/${TARGET}/screens"
  SPECS_NAV_FILE="${DESIGN_DIR}/specs/${TARGET}/navigation.md"
  SPECS_GLOBAL_DIR="${DESIGN_DIR}/specs/${TARGET}/global"
  STORIES_DIR="${DESIGN_DIR}/stories/${TARGET}"
  GENERATED_DIR="${DESIGN_DIR}/generated/${TARGET}"
  META_FILE="${GENERATED_DIR}/meta/outputs.json"
  STATUS_FILE="${GENERATED_DIR}/status.json"
  SRC_DIR="${PROJECT_DIR}/apps/${TARGET}/src"
fi

# Validate paths exist
SCREENS_PLAN="${SPECS_SCREENS_DIR}/index.md"
if [ ! -f "${SCREENS_PLAN}" ]; then
  echo "Missing ${SCREENS_PLAN}; cannot enumerate screens." >&2
  exit 1
fi

mkdir -p "$(dirname "${STATUS_FILE}")"

# Extract screen routes from the plan table
SCREENS=()
while IFS= read -r ROUTE; do
  [ -n "$ROUTE" ] && SCREENS+=("${ROUTE}")
done < <(awk -F'|' '
  NF>=4 && $0 ~ /^\|/ {
    for (i=1;i<=NF;i++){ sub(/^[ \t]+/,"",$i); sub(/[ \t]+$/,"",$i) }
    # Skip header and separator rows
    if ($2 == "Screen Name") next;
    if ($3 == "Route") next;
    if ($0 ~ /^\|[- ]+\|/) next;
    if ($3 != "") print $3
  }' "${SCREENS_PLAN}" | sed 's/ //g')

if [ ${#SCREENS[@]} -eq 0 ]; then
  echo "No screens found in ${SCREENS_PLAN}"
  echo "Add screens to the index table to track staleness."
  exit 0
fi

json_escape() { python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'; }

SUMMARY_ROWS=()
JSON_ENTRIES=()
STALE_COUNT=0

for ROUTE in "${SCREENS[@]}"; do
  # Inputs: prefer precise registry from meta/outputs.json; fallback to heuristic
  INPUTS=()
  if [ -f "${META_FILE}" ] && command -v jq >/dev/null 2>&1; then
    while IFS= read -r dep; do
      [ -n "$dep" ] && INPUTS+=("${PROJECT_DIR}/${dep}")
    done < <(jq -r --arg r "$ROUTE" '.outputs[] | select(.route==$r) | .dependsOn[]?' "${META_FILE}" 2>/dev/null || true)
  fi
  
  if [ "${#INPUTS[@]:-0}" -eq 0 ]; then
    # Fallback: gather all likely inputs
    while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "${STORIES_DIR}" -type f -name "*.md" -print0 2>/dev/null || true)
    [ -f "${SPECS_NAV_FILE}" ] && INPUTS+=("${SPECS_NAV_FILE}")
    while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "${SPECS_GLOBAL_DIR}" -type f -print0 2>/dev/null || true)
    # Schema specs (shared)
    while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "${DESIGN_DIR}/specs/schema" -type f -print0 2>/dev/null || true)
    # Per-screen spec
    KEBAB="$(echo "${ROUTE}" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | tr '[:upper:]' '[:lower:]')"
    [ -f "${SPECS_SCREENS_DIR}/${KEBAB}.md" ] && INPUTS+=("${SPECS_SCREENS_DIR}/${KEBAB}.md")
    [ -f "${SPECS_SCREENS_DIR}/${ROUTE}.md" ] && INPUTS+=("${SPECS_SCREENS_DIR}/${ROUTE}.md")
  fi

  # Outputs: generated screen file
  OUTPUTS=()
  [ -f "${SRC_DIR}/screens/${ROUTE}.tsx" ] && OUTPUTS+=("${SRC_DIR}/screens/${ROUTE}.tsx")
  [ -f "${SRC_DIR}/screens/${ROUTE}.ts" ] && OUTPUTS+=("${SRC_DIR}/screens/${ROUTE}.ts")
  # SvelteKit routes
  KEBAB="$(echo "${ROUTE}" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | tr '[:upper:]' '[:lower:]')"
  [ -f "${SRC_DIR}/routes/${KEBAB}/+page.svelte" ] && OUTPUTS+=("${SRC_DIR}/routes/${KEBAB}/+page.svelte")

  latest_in=0
  for f in "${INPUTS[@]}"; do
    if [ -f "$f" ]; then
      ts=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
      [ "$ts" -gt "$latest_in" ] && latest_in="$ts"
    fi
  done
  
  earliest_out=9999999999
  if [ "${#OUTPUTS[@]:-0}" -gt 0 ]; then
    for f in "${OUTPUTS[@]}"; do
      ts=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
      [ "$ts" -lt "$earliest_out" ] && earliest_out="$ts"
    done
  else
    earliest_out=0
  fi

  STALE="false"
  REASON=""
  if [ "${#OUTPUTS[@]}" -eq 0 ]; then
    STALE="true"
    REASON="missing output"
  elif [ "$latest_in" -gt "$earliest_out" ]; then
    STALE="true"
    REASON="inputs newer than outputs"
  fi
  [ "$STALE" = "true" ] && STALE_COUNT=$((STALE_COUNT+1))

  SUMMARY_ROWS+=("$(printf '%-22s | %-5s | %s' "${ROUTE}" "${STALE}" "${REASON}")")
  JSON_ENTRIES+=("{\"route\":\"${ROUTE}\",\"stale\":${STALE},\"reason\":$(printf '%s' "${REASON}" | json_escape)}")
done

# Write JSON report
if [ ${#JSON_ENTRIES[@]} -gt 0 ]; then
  JSON="{\"screens\":[ $(IFS=,; echo "${JSON_ENTRIES[*]}") ],\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"staleCount\":${STALE_COUNT}}"
else
  JSON="{\"screens\":[],\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"staleCount\":0}"
fi
printf '%s\n' "${JSON}" > "${STATUS_FILE}"

# Print summary
if [ -n "$TARGET" ]; then
  echo "Staleness summary for target: ${TARGET}"
else
  echo "Staleness summary:"
fi
echo ""
echo "Route                 | stale | reason"
echo "----------------------+-------+---------------------------"
for row in "${SUMMARY_ROWS[@]}"; do echo "${row}"; done
echo ""
echo "Wrote JSON report to ${STATUS_FILE}"

if [ "${STALE_COUNT}" -gt 0 ]; then
  echo ""
  echo "Next: run appeus/scripts/generate-next.sh to target the next vertical slice."
else
  echo ""
  echo "All screens look up to date."
fi
