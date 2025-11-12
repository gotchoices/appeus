#!/usr/bin/env bash
set -euo pipefail

# Placeholder regeneration driver.
# Reads design/specs and design/generated, then prints actionable steps.
# Actual codegen is performed by the AI agent per project needs.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DESIGN_DIR="${ROOT_DIR}/design"
SRC_DIR="${ROOT_DIR}/src"

echo "Appeus regenerate:"
echo " - Read human specs:    ${DESIGN_DIR}/specs"
echo " - Read consolidations: ${DESIGN_DIR}/generated"
echo " - Targets:"
echo "     screens   -> ${SRC_DIR}/screens"
echo "     navigation-> ${SRC_DIR}/navigation"
echo ""
echo "Suggested steps for the AI agent:"
echo "1) Parse design/specs/navigation.md and design/generated/navigation.md (human precedence)."
echo "2) For each design/specs/screens/*.md:"
echo "   - Merge with design/generated/screens/<id>.md if present."
echo "   - Generate/refresh src/screens/<ScreenName>.tsx."
echo "3) Update src/navigation/* (routes, options, deep links)."
echo "4) Ensure deep links pass scenario/variant and the app can open them."
echo "5) Commit changes."
echo ""
echo "Tip: Run appeus/scripts/check-stale to see if design changes are newer than src outputs."


