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
# shellcheck source=lib/host-integration.sh
source "${SCRIPT_DIR}/lib/host-integration.sh"

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

on_interrupt() {
  echo "" >&2
  echo "Interrupted." >&2
  exit 130
}
trap on_interrupt INT

# Portable realpath implementation in bash (macOS readlink lacks -f).
# Resolves symlink chains and normalizes ".." / "." via `cd -P` + `pwd -P`.
realpath_portable() {
  local path="$1"

  if [ -z "$path" ]; then
    return 1
  fi

  # Make absolute early (relative paths are relative to current working dir).
  case "$path" in
    /*) ;;
    *) path="$(pwd -P)/$path" ;;
  esac

  # Resolve symlink chain if present.
  while [ -L "$path" ]; do
    local dir target
    dir="$(cd -P "$(dirname "$path")" 2>/dev/null && pwd -P)" || return 1
    target="$(readlink "$path" 2>/dev/null)" || return 1
    case "$target" in
      /*) path="$target" ;;
      *) path="$dir/$target" ;;
    esac
  done

  # Normalize path lexically via filesystem resolution of the parent directory.
  local parent base
  parent="$(cd -P "$(dirname "$path")" 2>/dev/null && pwd -P)" || return 1
  base="$(basename "$path")"
  printf '%s/%s\n' "$parent" "$base"
}

TOOLKIT_REALPATH=""
if [ -L "${PROJECT_DIR}/appeus" ]; then
  TOOLKIT_REALPATH="$(realpath_portable "${PROJECT_DIR}/appeus" 2>/dev/null || true)"
fi

echo "Appeus v2.1: Detaching from project: ${PROJECT_DIR}"
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
    "${PROJECT_DIR}/appeus") return 0 ;; # allow removing the root symlink itself
    "${PROJECT_DIR}/appeus/"*) return 1 ;; # never remove anything within the toolkit checkout
  esac

  local link_target
  link_target="$(readlink "$link" 2>/dev/null || true)"

  # If we can resolve the toolkit path, only remove links that resolve into it.
  if [ -n "${TOOLKIT_REALPATH}" ]; then
    local resolved
    resolved="$(realpath_portable "$link" 2>/dev/null || true)"
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
    \( \
      -name .git -o \
      -name node_modules -o \
      -name Pods -o \
      -name DerivedData -o \
      -name .gradle -o \
      -name build -o \
      -name dist -o \
      -name .next -o \
      -name .turbo -o \
      -name .expo -o \
      -name .cache -o \
      -name .venv \
    \) -prune -o \
    -type l -print0
)

# Remove the marker-delimited Appeus section from host-authored agent rules.
# The section runs from `<!-- appeus -->` to the next HTML comment at start of line
# (or end of file). Host content outside that range is untouched.
strip_appeus_section() {
  local file="$1"

  [ -f "$file" ] || return 0
  [ -L "$file" ] && return 0
  grep -qF "${APPEUS_SECTION_MARKER}" "$file" || return 0

  if [ "${DRY_RUN}" = "1" ]; then
    echo "Would remove appeus section from: ${file}"
    return 0
  fi

  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/appeus-detach.XXXXXX")"
  awk -v marker="${APPEUS_SECTION_MARKER}" '
    $0 == marker { skip = 1; next }
    skip && /^<!--/ && $0 != marker { skip = 0 }
    !skip { print }
  ' "$file" >"$tmp"

  # Drop the blank lines that separated host content from the removed section.
  awk '
    { lines[NR] = $0 }
    END {
      last = NR
      while (last > 0 && lines[last] ~ /^[[:space:]]*$/) last--
      for (i = 1; i <= last; i++) print lines[i]
    }
  ' "$tmp" >"${tmp}.2"
  mv "${tmp}.2" "$file"
  rm -f "$tmp"
  echo "Removed appeus section from: ${file}"
}

for rule_file in AGENTS.md CLAUDE.md; do
  strip_appeus_section "${PROJECT_DIR}/${rule_file}"
done

# Remove only the .gitignore lines Appeus added.
clean_gitignore() {
  local file="${PROJECT_DIR}/.gitignore"
  [ -f "$file" ] || return 0

  local entries=() removed_lines=0 tmp
  while IFS= read -r entry; do
    [ -n "$entry" ] && entries+=("$entry")
  done < <(appeus_ignore_entries)
  entries+=("/AGENTS.md" "/CLAUDE.md" "${APPEUS_GITIGNORE_HEADER}")

  tmp="$(mktemp "${TMPDIR:-/tmp}/appeus-gitignore.XXXXXX")"
  cp "$file" "$tmp"
  for entry in "${entries[@]}"; do
    if grep -qxF "$entry" "$tmp"; then
      grep -vxF "$entry" "$tmp" >"${tmp}.2" || true
      mv "${tmp}.2" "$tmp"
      removed_lines=$((removed_lines + 1))
    fi
  done

  if [ "${removed_lines}" -gt 0 ]; then
    if [ "${DRY_RUN}" = "1" ]; then
      echo "Would remove ${removed_lines} appeus entr$([ "${removed_lines}" = "1" ] && echo y || echo ies) from .gitignore"
    else
      mv "$tmp" "$file"
      echo "Removed ${removed_lines} appeus entr$([ "${removed_lines}" = "1" ] && echo y || echo ies) from .gitignore"
    fi
  fi
  rm -f "$tmp" "${tmp}.2"
}

clean_gitignore

echo ""
echo "Done."
echo "Removed: ${removed}"
echo "Skipped (non-appeus symlinks): ${skipped}"

if [ "${DRY_RUN}" != "1" ]; then
  echo ""
  echo "To re-attach Appeus symlinks, re-run:"
  echo "  ${PROJECT_DIR}/appeus/scripts/init-project.sh"
fi


