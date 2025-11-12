#!/usr/bin/env bash
set -euo pipefail

# Regeneration planner (prompt-only). Accepts an optional target:
#   --screen <Route>  or  --api <Namespace>
# Prints an AI-facing plan for the specific slice.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DESIGN_DIR="${ROOT_DIR}/design"
SRC_DIR="${ROOT_DIR}/src"
TARGET_KIND=""
TARGET_VAL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --screen) TARGET_KIND="screen"; TARGET_VAL="$2"; shift 2 ;;
    --api) TARGET_KIND="api"; TARGET_VAL="$2"; shift 2 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

echo "Appeus regenerate (planner)"
if [ -n "${TARGET_KIND}" ]; then
  echo "Target: ${TARGET_KIND}=${TARGET_VAL}"
else
  echo "Target: all (agent should pick next vertical slice)"
fi
echo ""
echo "Inputs:"
echo " - Human specs:    ${DESIGN_DIR}/specs"
echo " - Consolidations: ${DESIGN_DIR}/generated"
echo "Outputs:"
echo " - Screens:        ${SRC_DIR}/screens"
echo " - Navigation:     ${SRC_DIR}/navigation"
echo " - Mocks:          ${ROOT_DIR}/mock/data"
echo " - Engine stubs:   ${ROOT_DIR}/src/data, ${ROOT_DIR}/src/engine"
echo ""
echo "Plan:"
if [ "${TARGET_KIND}" = "screen" ] && [ -n "${TARGET_VAL}" ]; then
  KEBAB="$(echo "${TARGET_VAL}" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | tr '[:upper:]' '[:lower:]')"
  echo "1) Refresh screen consolidation: design/generated/screens/${TARGET_VAL}.md (dependsOn stories, specs/screens/${KEBAB}.md?, specs/navigation.md, screens/index.md, global/*)"
  echo "2) Refresh required API consolidations (from 'needs' in consolidation)"
  echo "3) Generate/refresh mocks under mock/data for required namespaces (write .meta.json)"
  echo "4) Generate/refresh engine stubs/adapters to read mocks and plumb variant"
  echo "5) Generate/refresh RN code: src/screens/${TARGET_VAL}.tsx and update src/navigation/*"
  echo "6) Generate scenarios for stories referencing ${TARGET_VAL}: design/generated/scenarios/<story-id>.md"
  echo "7) Update design/generated/status.json and print a short report"
else
  echo "1) Run appeus/scripts/check-stale.sh to get per-screen status"
  echo "2) Pick the next stale, reachable screen (vertical slice)"
  echo "3) Apply steps 1-7 above for that screen"
fi
echo ""
echo "Notes:"
echo " - Respect precedence: specs > consolidations > defaults"
echo " - Embed dependency metadata (dependsOn/depHashes) in consolidations and generated code"
echo " - Do not overwrite human-authored specs"


