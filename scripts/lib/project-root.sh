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

# Target folders under design/specs/ (everything except project.md and the
# shared domain contract; legacy v2.0 shared folders are excluded too).
appeus_list_targets() { # $1 = project dir
  find "${1}/design/specs" -mindepth 1 -maxdepth 1 -type d \
    ! -name "domain" ! -name "schema" ! -name "api" \
    ! -name "global" ! -name "screens" ! -name "components" \
    -exec basename {} \; 2>/dev/null | sort
}

# Echo the target to operate on: the one given, else the only one that exists.
# Fails (with the list on stderr) when there are several and none was named.
appeus_resolve_target() { # $1 = project dir, $2 = requested target (may be empty)
  local project_dir="$1" target="${2:-}" targets count
  if [[ -n "$target" ]]; then echo "$target"; return 0; fi
  targets="$(appeus_list_targets "$project_dir" || true)"
  if [[ -z "$targets" ]]; then
    echo "Error: No targets found under design/specs/. Add an app first (scripts/add-app.sh)." >&2
    return 1
  fi
  count="$(printf '%s\n' "$targets" | wc -l | tr -d ' ')"
  if [[ "$count" != "1" ]]; then
    echo "Error: Multiple targets detected. --target is required." >&2
    echo "" >&2
    echo "Available targets:" >&2
    printf '%s\n' "$targets" >&2
    return 1
  fi
  echo "NOTE: Defaulting --target to '${targets}' (only target found)" >&2
  echo "$targets"
}
