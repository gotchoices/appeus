#!/usr/bin/env bash
set -euo pipefail

# Per-screen staleness report (initial implementation).
# Reads screens from design/specs/screens/index.md and compares mtimes of inputs vs outputs.
# Writes JSON to design/generated/status.json and prints a summary table.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DESIGN_DIR="${ROOT_DIR}/design"
SRC_DIR="${ROOT_DIR}/src"
STATUS_DIR="${DESIGN_DIR}/generated"
STATUS_FILE="${STATUS_DIR}/status.json"

[ -d "${DESIGN_DIR}" ] || { echo "No design/ directory."; exit 1; }
mkdir -p "${STATUS_DIR}"

SCREENS_PLAN="${DESIGN_DIR}/specs/screens/index.md"
if [ ! -f "${SCREENS_PLAN}" ]; then
  echo "Missing ${SCREENS_PLAN}; cannot enumerate screens." >&2
  exit 1
fi

# Extract screen routes from the plan table (2nd column), skipping headers/separators
SCREENS=()
while IFS= read -r ROUTE; do
  SCREENS+=("${ROUTE}")
done < <(awk -F'|' '
  NF>=5 && $0 ~ /^\|/ {
    # Trim fields
    for (i=1;i<=NF;i++){ sub(/^[ \t]+/,"",$i); sub(/[ \t]+$/,"",$i) }
    # Skip header and separator rows
    if ($2 == "Screen Name") next;
    if ($3 == "Route") next;
    if ($0 ~ /^\|[- ]+\|/) next;
    print $3
  }' "${SCREENS_PLAN}" | sed 's/ //g')

json_escape() { python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'; }

SUMMARY_ROWS=()
JSON_ENTRIES=()
STALE_COUNT=0

for ROUTE in "${SCREENS[@]}"; do
  # Inputs: stories, nav, global, spec for this screen if present
  INPUTS=()
  while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "${DESIGN_DIR}/stories" -type f -name "*.md" -print0 2>/dev/null || true)
  [ -f "${DESIGN_DIR}/specs/navigation.md" ] && INPUTS+=("${DESIGN_DIR}/specs/navigation.md")
  while IFS= read -r -d '' f; do INPUTS+=("$f"); done < <(find "${DESIGN_DIR}/specs/global" -type f -print0 2>/dev/null || true)
  # Per-screen spec (id matches route or kebab-case)
  KEBAB="$(echo "${ROUTE}" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | tr '[:upper:]' '[:lower:]')"
  [ -f "${DESIGN_DIR}/specs/screens/${KEBAB}.md" ] && INPUTS+=("${DESIGN_DIR}/specs/screens/${KEBAB}.md")
  [ -f "${DESIGN_DIR}/specs/screens/${ROUTE}.md" ] && INPUTS+=("${DESIGN_DIR}/specs/screens/${ROUTE}.md")

  # Outputs: generated screen file
  OUTPUTS=()
  [ -f "${SRC_DIR}/screens/${ROUTE}.tsx" ] && OUTPUTS+=("${SRC_DIR}/screens/${ROUTE}.tsx")

  latest_in=0
  for f in "${INPUTS[@]}"; do
    ts=$(stat -f %m "$f" 2>/dev/null || echo 0)
    [ "$ts" -gt "$latest_in" ] && latest_in="$ts"
  done
  earliest_out=9999999999
  if [ "${#OUTPUTS[@]:-0}" -gt 0 ]; then
    for f in "${OUTPUTS[@]}"; do
      ts=$(stat -f %m "$f" 2>/dev/null || echo 0)
      [ "$ts" -lt "$earliest_out" ] && earliest_out="$ts"
    done
  else
    earliest_out=0
  fi

  STALE="false"
  REASON=""
  if [ "${#OUTPUTS[@]}" -eq 0 ]; then
    STALE="true"
    REASON="missing output src/screens/${ROUTE}.tsx"
  elif [ "$latest_in" -gt "$earliest_out" ]; then
    STALE="true"
    REASON="inputs newer than outputs"
  fi
  [ "$STALE" = "true" ] && STALE_COUNT=$((STALE_COUNT+1))

  SUMMARY_ROWS+=("$(printf '%-22s | %-5s | %s' "${ROUTE}" "${STALE}" "${REASON}")")

  # JSON entry (minimal for agent selection)
  JSON_ENTRIES+=("{\"route\":\"${ROUTE}\",\"stale\":${STALE},\"reason\":$(printf '%s' "${REASON}" | json_escape)}")
done

JSON="{\"screens\":[ $(IFS=,; echo "${JSON_ENTRIES[*]}") ],\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"staleCount\":${STALE_COUNT}}"
printf '%s\n' "${JSON}" > "${STATUS_FILE}"

echo "Staleness summary (per screen):"
echo "Route                 | stale | reason"
echo "----------------------+-------+---------------------------"
for row in "${SUMMARY_ROWS[@]}"; do echo "${row}"; done
echo ""
echo "Wrote JSON report to ${STATUS_FILE}"
if [ "${STALE_COUNT}" -gt 0 ]; then
  echo "Next: run appeus/scripts/generate-next.sh to target the next vertical slice."
else
  echo "All screens look up to date by mtime heuristic."
fi


