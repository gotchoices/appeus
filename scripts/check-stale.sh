#!/usr/bin/env bash
set -euo pipefail

# Per-screen staleness report for Appeus v2.1 (canonical per-target layout).
#
# Usage:
#   appeus/scripts/check-stale.sh [--target <name>]
#
# If exactly one target exists, --target defaults to it. If multiple targets exist, --target is required.

# Parse arguments
TARGET=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target <name>]"
      echo ""
      echo "Check staleness of screens for a target app."
      echo "If multiple targets exist, --target is required."
      exit 0
      ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project (with design/ and appeus/ at the root), or set APPEUS_PROJECT_DIR." >&2
  exit 1
}
DESIGN_DIR="${PROJECT_DIR}/design"

[ -d "${DESIGN_DIR}" ] || { echo "No design/ directory."; exit 1; }

list_targets() {
  find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d \
    ! -name "domain" \
    ! -name "schema" \
    ! -name "api" \
    ! -name "global" \
    ! -name "screens" \
    ! -name "components" \
    -exec basename {} \; 2>/dev/null
}

if [ -z "$TARGET" ]; then
  targets="$(list_targets || true)"
  if [ -z "${targets}" ]; then
    echo "Error: No targets found under design/specs/. Add an app first (scripts/add-app.sh)." >&2
    exit 1
  fi
  target_count=$(printf "%s\n" "${targets}" | wc -l | tr -d ' ')
  if [ "${target_count}" = "1" ]; then
    TARGET=$(printf "%s\n" "${targets}" | head -n 1)
    echo "NOTE: Defaulting --target to '${TARGET}' (only target found)"
  else
    echo "Error: Multiple targets detected. --target is required." >&2
    echo ""
    echo "Available targets:"
    printf "%s\n" "${targets}"
    exit 1
  fi
fi

SPECS_SCREENS_DIR="${DESIGN_DIR}/specs/${TARGET}/screens"
SPECS_COMPONENTS_DIR="${DESIGN_DIR}/specs/${TARGET}/components"
SPECS_NAV_FILE="${DESIGN_DIR}/specs/${TARGET}/navigation.md"
SPECS_GLOBAL_DIR="${DESIGN_DIR}/specs/${TARGET}/global"
STORIES_DIR="${DESIGN_DIR}/stories/${TARGET}"
GENERATED_DIR="${DESIGN_DIR}/generated/${TARGET}"
META_FILE="${GENERATED_DIR}/meta/outputs.json"
STATUS_FILE="${GENERATED_DIR}/status.json"
SRC_DIR="${PROJECT_DIR}/apps/${TARGET}/src"

# Validate paths exist
SCREENS_PLAN="${SPECS_SCREENS_DIR}/index.md"
if [ ! -f "${SCREENS_PLAN}" ]; then
  echo "Missing ${SCREENS_PLAN}; cannot enumerate screens." >&2
  exit 1
fi

mkdir -p "$(dirname "${STATUS_FILE}")"
mkdir -p "$(dirname "${META_FILE}")"

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

# Ensure meta/outputs.json exists and has entries for known screens (non-destructive).
if [ ! -f "${META_FILE}" ]; then
  echo "Creating empty outputs.json at ${META_FILE}"
  printf '%s\n' '{"outputs":[]}' > "${META_FILE}"
fi
if command -v jq >/dev/null 2>&1; then
  for ROUTE in "${SCREENS[@]}"; do
    # If route missing from registry, seed a conservative dependsOn list.
    if ! jq -e --arg r "$ROUTE" 'any(.outputs[]?; .route == $r)' "${META_FILE}" >/dev/null 2>&1; then
      deps=()
      [ -f "${PROJECT_DIR}/design/specs/project.md" ] && deps+=("design/specs/project.md")
      if [ -d "${PROJECT_DIR}/design/specs/domain" ]; then
        while IFS= read -r -d '' f; do deps+=("${f#${PROJECT_DIR}/}"); done < <(find "${PROJECT_DIR}/design/specs/domain" -type f -name "*.md" -print0 2>/dev/null || true)
      fi
      [ -f "${SPECS_NAV_FILE}" ] && deps+=("${SPECS_NAV_FILE#${PROJECT_DIR}/}")
      [ -f "${SCREENS_PLAN}" ] && deps+=("${SCREENS_PLAN#${PROJECT_DIR}/}")
      # Per-screen spec
      KEBAB="$(echo "${ROUTE}" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')"
      [ -f "${SPECS_SCREENS_DIR}/${KEBAB}.md" ] && deps+=("${SPECS_SCREENS_DIR#${PROJECT_DIR}/}/${KEBAB}.md")
      [ -f "${SPECS_SCREENS_DIR}/${ROUTE}.md" ] && deps+=("${SPECS_SCREENS_DIR#${PROJECT_DIR}/}/${ROUTE}.md")
      # Target stories
      if [ -d "${STORIES_DIR}" ]; then
        while IFS= read -r -d '' f; do deps+=("${f#${PROJECT_DIR}/}"); done < <(find "${STORIES_DIR}" -type f -name "*.md" -print0 2>/dev/null || true)
      fi
      # The consolidation is what code is generated from. Listed unconditionally:
      # it usually does not exist yet when a route is first seeded, and dependsOn
      # is seeded only once.
      deps+=("design/generated/${TARGET}/screens/${ROUTE}.md")
      # `${a[@]+"${a[@]}"}` keeps `set -u` happy on empty arrays (bash 3.2, macOS default).
      deps_json=$(printf "%s\n" ${deps[@]+"${deps[@]}"} | awk 'NF && !seen[$0]++' | jq -R . | jq -s .)
      tmp=$(mktemp)
      jq --arg route "$ROUTE" --argjson deps "$deps_json" '
        .outputs += [{"route": $route, "dependsOn": $deps, "depHashes": {}}]
      ' "${META_FILE}" > "$tmp"
      mv "$tmp" "${META_FILE}"
    fi
  done
fi

json_escape() {
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  else
    # Enough for the short, ASCII reasons this script emits.
    printf '"%s"' "$(cat | tr -d '\n' | sed 's/\\/\\\\/g; s/"/\\"/g')"
  fi
}

file_sha256() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    return 1
  fi
}

# Hash comparison needs both a registry reader and a digest tool.
HASHING_AVAILABLE=0
if command -v jq >/dev/null 2>&1 && file_sha256 "${SCREENS_PLAN}" >/dev/null 2>&1; then
  HASHING_AVAILABLE=1
fi

# Compare each dependsOn file against its recorded depHashes entry.
# Echoes a reason when stale, nothing when fresh; returns 1 when no usable hashes exist.
hash_staleness_reason() { # $1 = route
  local route="$1" recorded actual dep count

  count="$(jq -r --arg r "$route" '[.outputs[] | select(.route==$r) | .depHashes // {} | keys[]] | length' "${META_FILE}" 2>/dev/null || echo 0)"
  [ "${count:-0}" -gt 0 ] || return 1

  while IFS= read -r dep; do
    [ -n "$dep" ] || continue
    recorded="$(jq -r --arg r "$route" --arg d "$dep" '.outputs[] | select(.route==$r) | .depHashes[$d] // ""' "${META_FILE}" 2>/dev/null || echo "")"
    # Tolerate an explicit algorithm prefix, e.g. "sha256:abc…".
    recorded="${recorded#sha256:}"

    if [ ! -f "${PROJECT_DIR}/${dep}" ]; then
      [ -n "$recorded" ] && { echo "dependency removed: ${dep}"; return 0; }
      continue
    fi
    if [ -z "$recorded" ]; then
      echo "no recorded hash: ${dep}"
      return 0
    fi
    actual="$(file_sha256 "${PROJECT_DIR}/${dep}")"
    if [ "$actual" != "$recorded" ]; then
      echo "changed: ${dep}"
      return 0
    fi
  done < <(jq -r --arg r "$route" '.outputs[] | select(.route==$r) | .dependsOn[]?' "${META_FILE}" 2>/dev/null || true)

  return 0
}

SUMMARY_ROWS=()
JSON_ENTRIES=()
STALE_COUNT=0
HASH_ROUTES=0
MTIME_ROUTES=0

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
    # Component specs (shared within target)
    if [ -d "${SPECS_COMPONENTS_DIR}" ]; then
      while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "${SPECS_COMPONENTS_DIR}" -type f -print0 2>/dev/null || true)
    fi
    # Domain contract specs (shared, v2.1)
    while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "${DESIGN_DIR}/specs/domain" -type f -print0 2>/dev/null || true)
    [ -f "${DESIGN_DIR}/specs/project.md" ] && INPUTS+=("${DESIGN_DIR}/specs/project.md")
    # Per-screen spec
    KEBAB="$(echo "${ROUTE}" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')"
    [ -f "${SPECS_SCREENS_DIR}/${KEBAB}.md" ] && INPUTS+=("${SPECS_SCREENS_DIR}/${KEBAB}.md")
    [ -f "${SPECS_SCREENS_DIR}/${ROUTE}.md" ] && INPUTS+=("${SPECS_SCREENS_DIR}/${ROUTE}.md")
  fi

  # Outputs: generated screen file
  OUTPUTS=()
  [ -f "${SRC_DIR}/screens/${ROUTE}.tsx" ] && OUTPUTS+=("${SRC_DIR}/screens/${ROUTE}.tsx")
  [ -f "${SRC_DIR}/screens/${ROUTE}.ts" ] && OUTPUTS+=("${SRC_DIR}/screens/${ROUTE}.ts")
  # SvelteKit routes
  KEBAB="$(echo "${ROUTE}" | sed -E 's/([a-z0-9])([A-Z])/\1-\2/g' | tr '[:upper:]' '[:lower:]')"
  [ -f "${SRC_DIR}/routes/${KEBAB}/+page.svelte" ] && OUTPUTS+=("${SRC_DIR}/routes/${KEBAB}/+page.svelte")

  STALE="false"
  REASON=""
  METHOD="mtime"

  if [ "${#OUTPUTS[@]}" -eq 0 ]; then
    STALE="true"
    REASON="missing output"
    METHOD="n/a"
  else
    # Hash-based (preferred): compare recorded depHashes to the files on disk.
    # mtimes are unreliable — git rewrites them on clone/checkout, and stat has
    # one-second resolution — so they are only the fallback.
    HASH_REASON=""
    if [ "${HASHING_AVAILABLE}" = "1" ]; then
      if HASH_REASON="$(hash_staleness_reason "${ROUTE}")"; then
        METHOD="hash"
        if [ -n "${HASH_REASON}" ]; then
          STALE="true"
          REASON="${HASH_REASON}"
        fi
      fi
    fi

    if [ "${METHOD}" = "mtime" ]; then
      latest_in=0
      for f in ${INPUTS[@]+"${INPUTS[@]}"}; do
        if [ -f "$f" ]; then
          ts=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
          [ "$ts" -gt "$latest_in" ] && latest_in="$ts"
        fi
      done

      earliest_out=9999999999
      for f in ${OUTPUTS[@]+"${OUTPUTS[@]}"}; do
        ts=$(stat -f %m "$f" 2>/dev/null || stat -c %Y "$f" 2>/dev/null || echo 0)
        [ "$ts" -lt "$earliest_out" ] && earliest_out="$ts"
      done

      if [ "$latest_in" -ge "$earliest_out" ]; then
        STALE="true"
        REASON="inputs not older than outputs (mtime; run update-dep-hashes.sh for exact detection)"
      fi
    fi
  fi

  case "${METHOD}" in
    hash) HASH_ROUTES=$((HASH_ROUTES+1)) ;;
    mtime) MTIME_ROUTES=$((MTIME_ROUTES+1)) ;;
  esac
  [ "$STALE" = "true" ] && STALE_COUNT=$((STALE_COUNT+1))

  SUMMARY_ROWS+=("$(printf '%-22s | %-5s | %-5s | %s' "${ROUTE}" "${STALE}" "${METHOD}" "${REASON}")")
  JSON_ENTRIES+=("{\"route\":\"${ROUTE}\",\"stale\":${STALE},\"method\":\"${METHOD}\",\"reason\":$(printf '%s' "${REASON}" | json_escape)}")
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
echo "Route                 | stale | how   | reason"
echo "----------------------+-------+-------+---------------------------"
for row in ${SUMMARY_ROWS[@]+"${SUMMARY_ROWS[@]}"}; do echo "${row}"; done
echo ""
echo "Wrote JSON report to ${STATUS_FILE}"

if [ "${MTIME_ROUTES}" -gt 0 ]; then
  echo ""
  if [ "${HASHING_AVAILABLE}" = "1" ]; then
    echo "NOTE: ${MTIME_ROUTES} route(s) fell back to mtime comparison (no depHashes recorded)."
    echo "  mtimes are unreliable after git clone/checkout. Record hashes with:"
    echo "    appeus/scripts/update-dep-hashes.sh --target ${TARGET} --all"
  else
    echo "NOTE: hash comparison unavailable (needs jq and shasum/sha256sum); used mtimes for all routes."
  fi
fi

echo ""
if [ "${STALE_COUNT}" -gt 0 ]; then
  echo "Next: pick a stale slice and regenerate it (agents typically use check-stale output + the screens index to choose)."
else
  echo "All screens look up to date."
fi
