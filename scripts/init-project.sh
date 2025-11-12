#!/usr/bin/env bash
set -euo pipefail

# Wrapper: run rn-init then setup-appeus.
PROJECT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_APPEUS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

"${SCRIPT_APPEUS_DIR}/scripts/rn-init.sh"
"${SCRIPT_APPEUS_DIR}/scripts/setup-appeus.sh"

echo ""
echo "Appeus: init-project completed."
echo "Next: edit design/stories/01-first-story.md, then run ./regen to generate code."


