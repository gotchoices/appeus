#!/usr/bin/env bash
set -euo pipefail

# Initialize an Appeus design surface and wire AGENTS.md symlinks.
# Usage: from project root: ./appeus/scripts/init-project.sh

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APPEUS_DIR="${ROOT_DIR}/appeus"
DESIGN_DIR="${ROOT_DIR}/design"
SRC_DIR="${ROOT_DIR}/src"

mkdir -p "${DESIGN_DIR}/stories"
mkdir -p "${DESIGN_DIR}/generated/scenarios"
mkdir -p "${DESIGN_DIR}/generated/screens"
mkdir -p "${DESIGN_DIR}/generated/api"
mkdir -p "${DESIGN_DIR}/specs/screens"
mkdir -p "${DESIGN_DIR}/specs/global"
mkdir -p "${DESIGN_DIR}/specs/api"
mkdir -p "${SRC_DIR}/screens"
mkdir -p "${SRC_DIR}/navigation"
mkdir -p "${SRC_DIR}/components" "${SRC_DIR}/state" "${SRC_DIR}/data" "${SRC_DIR}/engine"

# AGENTS.md symlinks (relative)
ln -snf "../appeus/agent-rules/design-root.md" "${DESIGN_DIR}/AGENTS.md"
ln -snf "../../appeus/agent-rules/stories.md" "${DESIGN_DIR}/stories/AGENTS.md"
ln -snf "../../appeus/agent-rules/consolidations.md" "${DESIGN_DIR}/generated/AGENTS.md"
ln -snf "../appeus/agent-rules/specs.md" "${DESIGN_DIR}/specs/AGENTS.md"
ln -snf "../appeus/agent-rules/src.md" "${SRC_DIR}/AGENTS.md"
ln -snf "../appeus/agent-rules/api.md" "${DESIGN_DIR}/specs/api/AGENTS.md"

# Seed templates if missing
if [ ! -f "${DESIGN_DIR}/specs/navigation.md" ]; then
  mkdir -p "$(dirname "${DESIGN_DIR}/specs/navigation.md")"
  cp -f "${APPEUS_DIR}/templates/specs/navigation.md" "${DESIGN_DIR}/specs/navigation.md"
fi
if [ ! -f "${DESIGN_DIR}/specs/global/toolchain.md" ]; then
  cp -f "${APPEUS_DIR}/templates/specs/global/toolchain.md" "${DESIGN_DIR}/specs/global/toolchain.md"
fi
if [ ! -f "${DESIGN_DIR}/specs/global/ui.md" ]; then
  cp -f "${APPEUS_DIR}/templates/specs/global/ui.md" "${DESIGN_DIR}/specs/global/ui.md"
fi
if [ ! -f "${DESIGN_DIR}/specs/global/dependencies.md" ]; then
  cp -f "${APPEUS_DIR}/templates/specs/global/dependencies.md" "${DESIGN_DIR}/specs/global/dependencies.md"
fi
if [ ! -f "${DESIGN_DIR}/specs/api/README.md" ]; then
  cat > "${DESIGN_DIR}/specs/api/README.md" <<'EOF'
# API Specs
- Add files per procedure using the template in appeus/templates/specs/api/procedure-template.md
- Human-authored specs override AI consolidations in design/generated/api/*
EOF
fi

echo "Appeus: initialized design tree and AGENTS.md links."
echo "Next: write stories in design/stories/, then run appeus/scripts/check-stale and appeus/scripts/regenerate when ready."


