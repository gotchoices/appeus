#!/usr/bin/env bash
set -euo pipefail

# Idempotent Appeus setup: create project-root 'appeus' symlink, design tree, AGENTS.md links,
# seed global specs, and create handy command symlinks (e.g., ./regen).

PROJECT_DIR="$(pwd)"
# Resolve physical paths to avoid recursive symlink targets
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_APPEUS_DIR="$(cd -P "${SCRIPT_DIR}/.." && pwd)"

ROOT_DIR="${PROJECT_DIR}"
DESIGN_DIR="${ROOT_DIR}/design"
SRC_DIR="${ROOT_DIR}/src"

# Always create (or refresh) a single project-root symlink to the Appeus toolkit being used
APPEUS_DIR="${SCRIPT_APPEUS_DIR}"
ln -snf "${APPEUS_DIR}" "${ROOT_DIR}/appeus"
# Optional: root-level AGENTS.md for quick orientation
ln -snf "appeus/agent-rules/root.md" "${ROOT_DIR}/AGENTS.md"

mkdir -p "${DESIGN_DIR}/stories"
mkdir -p "${DESIGN_DIR}/generated/scenarios"
mkdir -p "${DESIGN_DIR}/generated/screens"
mkdir -p "${DESIGN_DIR}/generated/images"
mkdir -p "${DESIGN_DIR}/generated/api"
mkdir -p "${DESIGN_DIR}/generated/meta"
mkdir -p "${DESIGN_DIR}/specs/screens"
mkdir -p "${DESIGN_DIR}/specs/global"
mkdir -p "${DESIGN_DIR}/specs/api"
mkdir -p "${SRC_DIR}" >/dev/null 2>&1 || true

# AGENTS.md symlinks via project-root 'appeus' symlink
ln -snf "../appeus/agent-rules/design-root.md" "${DESIGN_DIR}/AGENTS.md"
ln -snf "../../appeus/agent-rules/stories.md" "${DESIGN_DIR}/stories/AGENTS.md"
ln -snf "../../appeus/agent-rules/consolidations.md" "${DESIGN_DIR}/generated/AGENTS.md"
ln -snf "../../../appeus/agent-rules/scenarios.md" "${DESIGN_DIR}/generated/scenarios/AGENTS.md"
ln -snf "../../appeus/agent-rules/specs.md" "${DESIGN_DIR}/specs/AGENTS.md"
ln -snf "../../../appeus/agent-rules/api.md" "${DESIGN_DIR}/specs/api/AGENTS.md"

# Seed images index if missing
if [ ! -f "${DESIGN_DIR}/generated/images/index.md" ]; then
  cp -f "${APPEUS_DIR}/templates/generated/images-index.md" "${DESIGN_DIR}/generated/images/index.md"
fi
# Human-facing README symlink in stories (like appgen)
ln -snf "../../appeus/user-guides/stories.md" "${DESIGN_DIR}/stories/README.md"
# Seed a starter story from template if none exist yet (excluding README/AGENTS)
if [ "$(find "${DESIGN_DIR}/stories" -maxdepth 1 -type f -name "*.md" ! -name "README.md" ! -name "AGENTS.md" | wc -l | tr -d ' ')" = "0" ]; then
  cp -n "${APPEUS_DIR}/templates/stories/story-template.md" "${DESIGN_DIR}/stories/01-first-story.md"
fi
# Only create src/AGENTS.md if src exists
if [ -d "${SRC_DIR}" ]; then
  ln -snf "../appeus/agent-rules/src.md" "${SRC_DIR}/AGENTS.md"
fi

# Seed navigation spec if missing
if [ ! -f "${DESIGN_DIR}/specs/navigation.md" ]; then
  mkdir -p "$(dirname "${DESIGN_DIR}/specs/navigation.md")"
  cp -f "${APPEUS_DIR}/templates/specs/navigation.md" "${DESIGN_DIR}/specs/navigation.md"
fi

# Write toolchain with current choices (read from env if set; otherwise defaults)
LANG_CHOICE="${APPEUS_LANG:-ts}"
PM_CHOICE="${APPEUS_PM:-yarn}"
RUNTIME_CHOICE="${APPEUS_RUNTIME:-bare}"
if [ ! -f "${DESIGN_DIR}/specs/global/toolchain.md" ]; then
  cat > "${DESIGN_DIR}/specs/global/toolchain.md" <<EOF
# Toolchain Spec

language: ${LANG_CHOICE}
runtime: ${RUNTIME_CHOICE}
packageManager: ${PM_CHOICE}
navigation: react-navigation
state: zustand
http: fetch

notes:
- Adjust as needed; regenerate to apply.
EOF
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

# Seed screens index plan if missing
if [ ! -f "${DESIGN_DIR}/specs/screens/index.md" ]; then
  cp -f "${APPEUS_DIR}/templates/specs/screens/index.md" "${DESIGN_DIR}/specs/screens/index.md"
fi

# Command symlinks for convenience
#ln -snf "appeus/scripts/regenerate.sh" "${ROOT_DIR}/regen"
# (check-stale is primarily for agents; humans can run it via appeus/scripts/check-stale.sh if needed)

echo "Appeus: setup complete."
echo "Next: write your first story in design/stories/01-first-story.md, then run ./regen"
echo "Commit tip: git add -A && git commit -m \"appeus setup\""


