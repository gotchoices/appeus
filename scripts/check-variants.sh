#!/usr/bin/env bash
set -euo pipefail

# check-variants.sh
# Report, per target, every variant a screen spec declares that has no fixture behind it.
# A storyboard cannot reveal a state that does not exist: a screen whose `error` variant
# has no `mock/data/<namespace>.error.json` renders the default fixture and looks correct.
#
# Usage:
#   appeus/scripts/check-variants.sh [--target <name>] [--summary]
#
# Join key: the screen spec's `variants:` × the fixture namespaces its consolidation
# declares in frontmatter (`mocks: [tallies]`, i.e. mock/data/tallies.<variant>.json).
# When a consolidation declares none, namespaces are inferred from the mock/data files
# listed as `deps` for that route in the state registry (design/generated/<target>/images/index.md).
#
# Also reported: variants that have a fixture but no registry entry (not reviewable), and
# routes whose fixture namespaces cannot be determined.
#
# Report only; always exits 0. `--summary` prints a single line (used by check-stale.sh).

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
# shellcheck source=lib/scenarios.sh
source "${SCRIPT_DIR}/lib/scenarios.sh"

TARGET="" SUMMARY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --summary) SUMMARY=1; shift ;;
    -h|--help) sed -n '/^# Usage:/,/^# Report only/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Error: Unknown arg: $1" >&2; exit 1 ;;
  esac
done

PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project, or set APPEUS_PROJECT_DIR." >&2
  exit 1
}
TARGET="$(appeus_resolve_target "$PROJECT_DIR" "$TARGET" 2> >(if [[ "$SUMMARY" = "0" ]]; then cat >&2; else cat >/dev/null; fi))" || exit 1

SPECS_DIR="${PROJECT_DIR}/design/specs/${TARGET}/screens"
CONS_DIR="${PROJECT_DIR}/design/generated/${TARGET}/screens"
MOCK_DIR="${PROJECT_DIR}/mock/data"

# Items of a frontmatter list, inline (`key: [a, b]`) or block (`key:` then `- a` lines).
read -r -d '' FM_LIST_AWK <<'AWK' || true
/^---[ \t]*$/ { if (infm) exit; infm = 1; next }
!infm { next }
inlist && /^[ \t]*-[ \t]+/ { s = $0; sub(/^[ \t]*-[ \t]+/, "", s); gsub(/^["']|["']$/, "", s); print s; next }
inlist { inlist = 0 }
$0 ~ ("^" key ":") {
  s = $0; sub("^" key ":[ \t]*", "", s)
  if (s ~ /^\[/) { gsub(/[][ "']/, "", s); n = split(s, a, ","); for (i = 1; i <= n; i++) if (a[i] != "") print a[i] }
  else if (s == "") inlist = 1
  else { gsub(/^["']|["']$/, "", s); print s }
}
AWK
fm_list() { awk -v key="$2" "$FM_LIST_AWK" "$1"; }   # $1 = file, $2 = key

# Registry (optional; needs node). Lines: id route variant file capture link deps, 0x1f-separated
REGISTRY=""
if command -v npx >/dev/null 2>&1 && [[ -f "${PROJECT_DIR}/design/generated/${TARGET}/images/index.md" ]]; then
  REGISTRY="$(appeus_scenarios_js registry --project "$PROJECT_DIR" --target "$TARGET" 2>/dev/null || true)"
fi
# Registry rows for a route; entries may carry path segments (`Route/<id>`).
registry_rows() { printf '%s\n' "$REGISTRY" | awk -F$'\x1f' -v r="$1" '$2 == r || index($2, r "/") == 1'; }

MISSING=0 UNREGISTERED=0 UNKNOWN=0
LINES=()

for spec in "${SPECS_DIR}"/*.md; do
  [[ -f "$spec" ]] || continue
  [[ "$(basename "$spec")" = "index.md" ]] && continue
  route="$(fm_list "$spec" route | head -n 1)"
  [[ -n "$route" ]] || continue
  variants="$(fm_list "$spec" variants)"
  [[ -n "$variants" ]] || continue

  namespaces=""
  cons="${CONS_DIR}/${route}.md"
  [[ -f "$cons" ]] && namespaces="$(fm_list "$cons" mocks)"
  if [[ -z "$namespaces" && -n "$REGISTRY" ]]; then
    namespaces="$(registry_rows "$route" | cut -d$'\x1f' -f7 | tr ',' '\n' \
      | sed -nE 's#^mock/data/([^/.]+)\.[^/]+\.json$#\1#p' | sort -u)"
  fi
  if [[ -z "$namespaces" ]]; then
    UNKNOWN=$((UNKNOWN + 1))
    LINES+=("${route}: fixture namespaces unknown — declare \`mocks: [<namespace>]\` in ${cons#${PROJECT_DIR}/}")
    continue
  fi

  while IFS= read -r v; do
    [[ -n "$v" ]] || continue
    found=""
    while IFS= read -r ns; do
      [[ -f "${MOCK_DIR}/${ns}.${v}.json" ]] && found="${found:+$found, }${ns}"
    done <<< "$namespaces"
    if [[ -z "$found" ]]; then
      MISSING=$((MISSING + 1))
      looked="$(printf '%s\n' "$namespaces" | sed "s#\$#.${v}.json#" | paste -sd, - | sed 's/,/, /g')"
      LINES+=("${route}/${v}: no fixture (looked for mock/data/${looked})")
      continue
    fi
    if [[ -n "$REGISTRY" ]]; then
      # An entry with no variant shows the app default, which is `happy`.
      if ! registry_rows "$route" | awk -F$'\x1f' -v v="$v" '$3 == v || ($3 == "" && v == "happy") { f = 1 } END { exit !f }'; then
        UNREGISTERED=$((UNREGISTERED + 1))
        LINES+=("${route}/${v}: fixture exists (${found}) but no registry entry in images/index.md — not reviewable")
      fi
    fi
  done <<< "$variants"
done

total=$((MISSING + UNREGISTERED + UNKNOWN))
if [[ "$SUMMARY" = "1" ]]; then
  if [[ "$total" = "0" ]]; then
    echo "Variant fixtures: every declared variant has a fixture and a registry entry."
  else
    echo "Variant fixtures: ${MISSING} without fixture, ${UNREGISTERED} unregistered, ${UNKNOWN} route(s) with unknown namespaces (appeus/scripts/check-variants.sh --target ${TARGET})"
  fi
  exit 0
fi

echo "Variant fixture report for target: ${TARGET}"
echo ""
if [[ "$total" = "0" ]]; then
  echo "Every declared variant has a fixture and a registry entry."
else
  for l in "${LINES[@]}"; do echo "  ${l}"; done
  echo ""
  echo "${MISSING} without fixture, ${UNREGISTERED} unregistered, ${UNKNOWN} route(s) with unknown namespaces."
fi
[[ -n "$REGISTRY" ]] || echo "(registry not read — node/npx or images/index.md missing — so registration was not checked)"
