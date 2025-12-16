#!/usr/bin/env bash
set -euo pipefail

# project-root.sh
# Helper for Appeus scripts to locate the project root directory in a way that
# works when `appeus/` is a symlink into a toolkit checkout.
#
# Resolution order:
#  1) APPEUS_PROJECT_DIR (if set)
#  2) Walk up from current working directory until we find a directory that
#     contains both `design/` and `appeus/` (or `appeus` symlink)
#  3) Fallback: two levels up from the script dir (only if it looks like a project)
#
# Usage:
#   PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || exit 1

appeus_find_project_dir() {
  local script_dir="${1:-}"

  if [[ -n "${APPEUS_PROJECT_DIR:-}" ]]; then
    if [[ -d "${APPEUS_PROJECT_DIR}" ]]; then
      echo "${APPEUS_PROJECT_DIR}"
      return 0
    fi
    return 1
  fi

  local d
  d="$(pwd)"
  while [[ "${d}" != "/" ]]; do
    if [[ -d "${d}/design" && -e "${d}/appeus" ]]; then
      echo "${d}"
      return 0
    fi
    d="$(dirname "${d}")"
  done

  if [[ -n "${script_dir}" ]]; then
    if d="$(cd "${script_dir}/../.." >/dev/null 2>&1 && pwd)"; then
      if [[ -d "${d}/design" && -e "${d}/appeus" ]]; then
        echo "${d}"
        return 0
      fi
    fi
  fi

  return 1
}


