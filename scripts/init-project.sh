#!/usr/bin/env bash
set -euo pipefail

# Appeus v2.1: Initialize a new project with design-first structure.
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
      echo "Initialize an Appeus v2.1 project in the current directory."
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

# shellcheck source=lib/host-integration.sh
source "${SCRIPT_DIR}/lib/host-integration.sh"

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

echo "Appeus v2.1: Initializing project in $(pwd)"
echo ""

# Hosted mode: the project root already holds content Appeus does not own
# (host AGENTS.md, package.json, other tooling). Appeus becomes a guest:
# it appends its rules section instead of owning AGENTS.md, and touches
# .gitignore only to add its own symlink entries.
HOSTED=0
if appeus_is_hosted_project "${PROJECT_DIR}"; then
  HOSTED=1
  echo "Hosted mode: existing project content detected; Appeus will not take over root files."
  echo ""
fi

# Detect whether this looks like an existing Appeus-guided project with at least one target already present.
HAS_EXISTING_TARGET=0
if [ -d "${PROJECT_DIR}/apps" ]; then
  for d in "${PROJECT_DIR}/apps/"*; do
    [ -d "$d" ] || continue
    HAS_EXISTING_TARGET=1
    break
  done
fi
if [ "${HAS_EXISTING_TARGET}" = "0" ] && [ -d "${PROJECT_DIR}/design/specs" ]; then
  for d in "${PROJECT_DIR}/design/specs/"*; do
    [ -d "$d" ] || continue
    base="$(basename "$d")"
    [ "$base" = "domain" ] && continue
    if [ -f "${d}/STATUS.md" ]; then
      HAS_EXISTING_TARGET=1
      break
    fi
  done
fi

# 1. Create appeus symlink
ensure_symlink "$APPEUS_DIR" "${PROJECT_DIR}/appeus"

# 2. Ensure root AGENTS.md carries Appeus rules.
# Greenfield: symlink it (bootstrap, or project rules when a target already exists).
# Hosted: append the marker-delimited section from agent-rules/root.md; never overwrite.
ROOT_RULE_MODE="bootstrap"
if [ "${HAS_EXISTING_TARGET}" = "1" ]; then
  ROOT_RULE_MODE="project"
fi

ROOT_RULE_RESULT="$(appeus_ensure_root_rules "${PROJECT_DIR}" "${APPEUS_DIR}" "${ROOT_RULE_MODE}")"
case "${ROOT_RULE_RESULT}" in
  linked) log_added "AGENTS.md → $(appeus_root_link_target "${ROOT_RULE_MODE}")" ;;
  repointed) log_refreshed "AGENTS.md → $(appeus_root_link_target "${ROOT_RULE_MODE}")" ;;
  appended) log_added "AGENTS.md (appended appeus section)" ;;
  present) log_skipped "AGENTS.md (already carries appeus rules)" ;;
esac

CLAUDE_RULE_RESULT="$(appeus_ensure_claude_pointer "${PROJECT_DIR}" "${APPEUS_DIR}" "${ROOT_RULE_MODE}")"
case "${CLAUDE_RULE_RESULT}" in
  linked) log_added "CLAUDE.md → $(appeus_root_link_target "${ROOT_RULE_MODE}")" ;;
  repointed) log_refreshed "CLAUDE.md → $(appeus_root_link_target "${ROOT_RULE_MODE}")" ;;
  appended) log_added "CLAUDE.md (appended appeus section)" ;;
  defers) log_skipped "CLAUDE.md (defers to AGENTS.md)" ;;
  present) log_skipped "CLAUDE.md (already carries appeus rules)" ;;
esac

if [ "${HAS_EXISTING_TARGET}" = "1" ] && [ "${ROOT_RULE_RESULT}" = "repointed" ]; then
  echo "Note: Existing target(s) detected; root AGENTS.md set to project rules."
  echo "  (If you want discovery mode, repoint it to appeus/agent-rules/bootstrap.md.)"
  echo ""
fi

# 3. Create design folder structure
ensure_dir "${PROJECT_DIR}/design"
ensure_dir "${PROJECT_DIR}/design/specs"
ensure_dir "${PROJECT_DIR}/design/specs/domain"
ensure_dir "${PROJECT_DIR}/design/stories"
ensure_dir "${PROJECT_DIR}/design/generated"

# 4. Create design AGENTS.md symlinks
ensure_symlink "../appeus/agent-rules/design-root.md" "${PROJECT_DIR}/design/AGENTS.md"
ensure_symlink "../../appeus/agent-rules/specs.md" "${PROJECT_DIR}/design/specs/AGENTS.md"
ensure_symlink "../../appeus/agent-rules/stories.md" "${PROJECT_DIR}/design/stories/AGENTS.md"
ensure_symlink "../../appeus/agent-rules/consolidations.md" "${PROJECT_DIR}/design/generated/AGENTS.md"

# 5. Copy project.md template
copy_if_missing "${APPEUS_DIR}/templates/specs/project.md" "${PROJECT_DIR}/design/specs/project.md"

# 6. (v2.1) Domain contract lives under design/specs/domain/
# Keep this folder empty by default; projects vary widely in whether they need schema/api/rules/interfaces.
ensure_symlink "../../../appeus/agent-rules/domain.md" "${PROJECT_DIR}/design/specs/domain/AGENTS.md"
ensure_symlink "../../../appeus/user-guides/domain.md" "${PROJECT_DIR}/design/specs/domain/README.md"

# 9. Human-facing README symlinks
ensure_symlink "../../appeus/user-guides/stories.md" "${PROJECT_DIR}/design/stories/README.md"
ensure_symlink "../../appeus/user-guides/specs.md" "${PROJECT_DIR}/design/specs/README.md"

# If targets already exist, ensure each per-target specs folder has a human guide.
for d in "${PROJECT_DIR}/design/specs/"*; do
  [ -d "$d" ] || continue
  base="$(basename "$d")"
  [ "$base" = "domain" ] && continue
  ensure_symlink "../../../appeus/user-guides/target-spec.md" "${d}/README.md"
done

# 10. Create apps directory
ensure_dir "${PROJECT_DIR}/apps"

# 11. Create mock directory
ensure_dir "${PROJECT_DIR}/mock"
ensure_dir "${PROJECT_DIR}/mock/data"

# 12. Ignore the symlinks Appeus creates (they point into the toolkit checkout).
# Only Appeus-owned entries are added, one line at a time. Generic dev ignores
# (node_modules, dist, .env, …) are written only when creating a fresh .gitignore,
# since a host project already has its own.
GITIGNORE_PATH="${PROJECT_DIR}/.gitignore"
GITIGNORE_EXISTED=0
[ -f "${GITIGNORE_PATH}" ] && GITIGNORE_EXISTED=1

if [ "${GITIGNORE_EXISTED}" = "0" ]; then
  printf '%s\n' "${APPEUS_GITIGNORE_HEADER}" > "${GITIGNORE_PATH}"
fi

IGNORE_ADDED=0
while IFS= read -r entry; do
  [ -n "$entry" ] || continue
  if appeus_add_gitignore_entry "${GITIGNORE_PATH}" "$entry"; then
    IGNORE_ADDED=$((IGNORE_ADDED + 1))
  fi
done < <(appeus_ignore_entries)

# Root rule files are only Appeus-owned when Appeus symlinked them.
for rule_file in AGENTS.md CLAUDE.md; do
  if appeus_is_toolkit_link "${PROJECT_DIR}/${rule_file}"; then
    if appeus_add_gitignore_entry "${GITIGNORE_PATH}" "/${rule_file}"; then
      IGNORE_ADDED=$((IGNORE_ADDED + 1))
    fi
  fi
done

# Generic dev ignores only for a project Appeus is creating from scratch —
# a host repo already has its own.
if [ "${GITIGNORE_EXISTED}" = "0" ] && [ "${HOSTED}" = "0" ]; then
  cat >> "${GITIGNORE_PATH}" <<'EOF'

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
EOF
fi

if [ "${GITIGNORE_EXISTED}" = "0" ]; then
  log_added ".gitignore"
elif [ "${IGNORE_ADDED}" -gt 0 ]; then
  log_added ".gitignore (added ${IGNORE_ADDED} appeus entr$([ "${IGNORE_ADDED}" = "1" ] && echo y || echo ies))"
else
  log_skipped ".gitignore (already has appeus entries)"
fi

# 13. Initialize git if not already initialized and not disabled.
# Never nest a repo inside an existing work tree (e.g. Appeus living in a subdir
# of a larger monorepo) — that would shadow the host repo's history.
if [ "${INIT_GIT}" != "0" ]; then
  if [ ! -d "${PROJECT_DIR}/.git" ]; then
    if git -C "${PROJECT_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      log_skipped ".git/ (inside existing git work tree)"
    else
      git init >/dev/null 2>&1 || true
      log_added ".git/ (initialized)"
    fi
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
echo "   ./appeus/scripts/add-app.sh --target mobile --framework react-native"
echo "   ./appeus/scripts/add-app.sh --target web --framework sveltekit"
echo ""
echo "3. Write stories per target in design/stories/<target>/"
echo ""
echo "Supported frameworks: react-native, sveltekit"
echo ""
