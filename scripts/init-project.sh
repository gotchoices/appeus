#!/usr/bin/env bash
set -euo pipefail

# Appeus v2: Initialize a new project with design-first structure.
# Run this in an empty or existing project folder.
#
# Usage:
#   /path/to/appeus/scripts/init-project.sh [--no-git]
#
# Options:
#   --no-git    Skip git initialization
#
# Environment:
#   APPEUS_GIT=0    Same as --no-git
#
# This script is:
#   - Non-destructive: won't overwrite existing files
#   - Idempotent: safe to re-run (refreshes symlinks, adds missing items)
#
# After running, complete the discovery phase by filling out design/specs/project.md,
# then use add-app.sh to scaffold your first app.

# Parse arguments
INIT_GIT="${APPEUS_GIT:-1}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-git) INIT_GIT=0; shift ;;
    -h|--help)
      echo "Usage: $0 [--no-git]"
      echo ""
      echo "Initialize an Appeus v2 project in the current directory."
      echo ""
      echo "Options:"
      echo "  --no-git    Skip git initialization"
      echo ""
      echo "Environment:"
      echo "  APPEUS_GIT=0    Same as --no-git"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

PROJECT_DIR="$(pwd)"
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPEUS_DIR="$(cd -P "${SCRIPT_DIR}/.." && pwd)"

# Tracking for report
ADDED=()
SKIPPED=()
REFRESHED=()

log_added() { ADDED+=("$1"); }
log_skipped() { SKIPPED+=("$1"); }
log_refreshed() { REFRESHED+=("$1"); }

# Create directory if it doesn't exist
ensure_dir() {
  local dir="$1"
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    log_added "$dir/"
  fi
}

# Create symlink (always refresh if exists)
ensure_symlink() {
  local target="$1"
  local link="$2"
  if [ -L "$link" ]; then
    # Refresh existing symlink
    rm "$link"
    ln -s "$target" "$link"
    log_refreshed "$link"
  elif [ -e "$link" ]; then
    # File exists but is not a symlink - skip
    log_skipped "$link (exists, not a symlink)"
  else
    ln -s "$target" "$link"
    log_added "$link"
  fi
}

# Copy file only if destination doesn't exist
copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [ -f "$dest" ]; then
    log_skipped "$dest (exists)"
  else
    cp "$src" "$dest"
    log_added "$dest"
  fi
}

# Write file only if destination doesn't exist
write_if_missing() {
  local dest="$1"
  local content="$2"
  if [ -f "$dest" ]; then
    log_skipped "$dest (exists)"
  else
    echo "$content" > "$dest"
    log_added "$dest"
  fi
}

echo "Appeus v2: Initializing project in $(pwd)"
echo ""

# 1. Create appeus symlink
ensure_symlink "$APPEUS_DIR" "${PROJECT_DIR}/appeus"

# 2. Create root AGENTS.md pointing to bootstrap (discovery phase)
ensure_symlink "appeus/agent-rules/bootstrap.md" "${PROJECT_DIR}/AGENTS.md"

# 3. Create design folder structure
ensure_dir "${PROJECT_DIR}/design"
ensure_dir "${PROJECT_DIR}/design/specs"
ensure_dir "${PROJECT_DIR}/design/specs/schema"
ensure_dir "${PROJECT_DIR}/design/specs/api"
ensure_dir "${PROJECT_DIR}/design/stories"
ensure_dir "${PROJECT_DIR}/design/generated"

# 4. Create design AGENTS.md symlinks
ensure_symlink "../appeus/agent-rules/design-root.md" "${PROJECT_DIR}/design/AGENTS.md"
ensure_symlink "../../appeus/agent-rules/specs.md" "${PROJECT_DIR}/design/specs/AGENTS.md"
ensure_symlink "../../appeus/agent-rules/stories.md" "${PROJECT_DIR}/design/stories/AGENTS.md"
ensure_symlink "../../appeus/agent-rules/consolidations.md" "${PROJECT_DIR}/design/generated/AGENTS.md"
ensure_symlink "../../../appeus/agent-rules/api.md" "${PROJECT_DIR}/design/specs/api/AGENTS.md"
ensure_symlink "../../../appeus/agent-rules/schema.md" "${PROJECT_DIR}/design/specs/schema/AGENTS.md"

# 5. Copy project.md template
copy_if_missing "${APPEUS_DIR}/templates/specs/project.md" "${PROJECT_DIR}/design/specs/project.md"

# 6. Copy schema index template
copy_if_missing "${APPEUS_DIR}/templates/specs/schema/index.md" "${PROJECT_DIR}/design/specs/schema/index.md"

# 7. Create API README
write_if_missing "${PROJECT_DIR}/design/specs/api/README.md" "# API Specs
- Add files per procedure using the template in appeus/templates/specs/api/procedure-template.md
- Human-authored specs override AI consolidations in design/generated/api/*
"

# 8. Create generated subdirectories (shared)
ensure_dir "${PROJECT_DIR}/design/generated/api"
ensure_dir "${PROJECT_DIR}/design/generated/meta"

# 9. Human-facing README symlinks
ensure_symlink "../../appeus/user-guides/stories.md" "${PROJECT_DIR}/design/stories/README.md"
ensure_symlink "../../appeus/user-guides/specs.md" "${PROJECT_DIR}/design/specs/README.md"

# 10. Create apps directory
ensure_dir "${PROJECT_DIR}/apps"

# 11. Create mock directory
ensure_dir "${PROJECT_DIR}/mock"
ensure_dir "${PROJECT_DIR}/mock/data"

# 12. Create .gitignore with appeus symlinks
GITIGNORE_CONTENT="# Appeus symlinks (recreate with: path/to/appeus/scripts/init-project.sh)
appeus
AGENTS.md
**/AGENTS.md

# Dependencies
node_modules/

# Build outputs
dist/
build/
.next/
.svelte-kit/

# Environment
.env
.env.local

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
"

if [ -f "${PROJECT_DIR}/.gitignore" ]; then
  # Check if our marker comment exists
  if grep -q "Appeus symlinks" "${PROJECT_DIR}/.gitignore"; then
    log_skipped ".gitignore (already has appeus entries)"
  else
    # Append to existing .gitignore
    echo "" >> "${PROJECT_DIR}/.gitignore"
    echo "$GITIGNORE_CONTENT" >> "${PROJECT_DIR}/.gitignore"
    log_added ".gitignore (appended appeus entries)"
  fi
else
  echo "$GITIGNORE_CONTENT" > "${PROJECT_DIR}/.gitignore"
  log_added ".gitignore"
fi

# 13. Initialize git if not already initialized and not disabled
if [ "${INIT_GIT}" != "0" ]; then
  if [ ! -d "${PROJECT_DIR}/.git" ]; then
    git init >/dev/null 2>&1 || true
    log_added ".git/ (initialized)"
  fi
fi

# Print report
echo "=== Report ==="
echo ""

if [ ${#ADDED[@]} -gt 0 ]; then
  echo "Added:"
  for item in "${ADDED[@]}"; do
    echo "  + $item"
  done
  echo ""
fi

if [ ${#REFRESHED[@]} -gt 0 ]; then
  echo "Refreshed:"
  for item in "${REFRESHED[@]}"; do
    echo "  ~ $item"
  done
  echo ""
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
  echo "Skipped (already exists):"
  for item in "${SKIPPED[@]}"; do
    echo "  - $item"
  done
  echo ""
fi

echo "=== Next Steps ==="
echo ""
echo "1. Complete the discovery phase:"
echo "   Edit design/specs/project.md to document your project decisions"
echo ""
echo "2. Add your first app:"
echo "   ./appeus/scripts/add-app.sh --name mobile --framework react-native"
echo "   ./appeus/scripts/add-app.sh --name web --framework sveltekit"
echo ""
echo "3. Write stories in design/stories/"
echo ""
echo "Supported frameworks: react-native, sveltekit"
echo ""
