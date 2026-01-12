#!/usr/bin/env bash
set -euo pipefail

# detach-appeus.sh
# Remove Appeus-installed symlinks from an Appeus-guided project without deleting any regular files.
#
# This script:
# - Removes symlinks that resolve into the toolkit pointed to by the project's root `appeus` symlink
# - Never deletes regular files/directories (only unlinks symlinks)
#
# After detaching, re-running scripts/init-project.sh will re-create the symlinks.

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"

usage() {
  cat <<'EOF'
Usage: detach-appeus.sh [--dry-run]

Remove Appeus symlinks from the current project tree.

This will only remove symlinks that point into the project root `appeus` toolkit symlink.
Regular files are never deleted.

Options:
  --dry-run   Print what would be removed without removing anything
  -h, --help  Show this help
EOF
}

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Error: Unknown arg: $1" >&2; usage >&2; exit 1 ;;
  esac
done

PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project (with design/ and appeus/ at the root), or set APPEUS_PROJECT_DIR." >&2
  exit 1
}

die() { echo "Error: $*" >&2; exit 1; }

PYTHON=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON="python3"
fi

TOOLKIT_REALPATH=""
if [ -L "${PROJECT_DIR}/appeus" ]; then
  if [ -n "${PYTHON}" ]; then
    TOOLKIT_REALPATH="$("${PYTHON}" - <<'PY' "${PROJECT_DIR}/appeus"
import os,sys
print(os.path.realpath(sys.argv[1]))
PY
)"
  else
    # Best-effort fallback: treat any symlink whose link target contains "appeus/" as detachable
    TOOLKIT_REALPATH=""
  fi
fi

echo "Appeus v2: Detaching from project: ${PROJECT_DIR}"
if [ "${DRY_RUN}" = "1" ]; then
  echo "(dry-run)"
fi
echo ""

removed=0
skipped=0

should_remove_link() {
  local link="$1"

  # Never consider anything inside the toolkit itself (if it's a real dir in the project).
  # Note: if ${PROJECT_DIR}/appeus is a symlink, find will still traverse it unless pruned elsewhere.
  case "$link" in
    "${PROJECT_DIR}/appeus"|"${PROJECT_DIR}/appeus/"*) return 0 ;; # allow removing the root symlink itself
  esac

  local link_target
  link_target="$(readlink "$link" 2>/dev/null || true)"

  # If we can resolve the toolkit path, only remove links that resolve into it.
  if [ -n "${TOOLKIT_REALPATH}" ] && [ -n "${PYTHON}" ]; then
    local resolved
    resolved="$("${PYTHON}" - <<'PY' "$link"
import os,sys
print(os.path.realpath(sys.argv[1]))
PY
)"
    case "$resolved" in
      "${TOOLKIT_REALPATH}"|"${TOOLKIT_REALPATH}/"*) return 0 ;;
    esac
    return 1
  fi

  # Fallback heuristic when we can't resolve:
  # remove symlinks whose raw target path clearly references "appeus/".
  case "$link_target" in
    *"/appeus/"*|appeus/*|../appeus/*|../../appeus/*|../../../appeus/*) return 0 ;;
  esac
  return 1
}

# Find all symlinks under project root, excluding .git and common dependency folders.
while IFS= read -r -d '' link; do
  if should_remove_link "$link"; then
    if [ "${DRY_RUN}" = "1" ]; then
      echo "Would remove symlink: ${link}"
    else
      rm "$link"
      echo "Removed symlink: ${link}"
    fi
    removed=$((removed + 1))
  else
    skipped=$((skipped + 1))
  fi
done < <(
  find "${PROJECT_DIR}" \
    \( -path "${PROJECT_DIR}/.git" -o -path "${PROJECT_DIR}/.git/*" -o -path "${PROJECT_DIR}/node_modules" -o -path "${PROJECT_DIR}/node_modules/*" \) -prune -o \
    -type l -print0
)

echo ""
echo "Done."
echo "Removed: ${removed}"
echo "Skipped (non-appeus symlinks): ${skipped}"

if [ "${DRY_RUN}" != "1" ]; then
  echo ""
  echo "To re-attach Appeus symlinks, re-run:"
  echo "  ${PROJECT_DIR}/appeus/scripts/init-project.sh"
fi


