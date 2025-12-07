#!/usr/bin/env bash
set -euo pipefail

# update-dep-hashes.sh
# Recomputes SHA256 hashes for dependsOn files and updates outputs.json depHashes.
# Supports both single-app and multi-app project structures.
#
# Usage:
#   appeus/scripts/update-dep-hashes.sh [--target <name>] --route <RouteName>
#   appeus/scripts/update-dep-hashes.sh [--target <name>] --all
#
# In multi-app projects, --target is required.

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DESIGN_DIR="${PROJECT_DIR}/design"

die() { echo "Error: $*" >&2; exit 1; }

# Ensure required tools
command -v jq >/dev/null 2>&1 || die "jq is required"
command -v shasum >/dev/null 2>&1 || die "shasum is required"

TARGET=""
MODE=""
TARGET_ROUTE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --all) MODE="all"; shift ;;
    --route) MODE="route"; TARGET_ROUTE="${2:-}"; [[ -n "$TARGET_ROUTE" ]] || die "--route requires a value"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target <name>] --route <RouteName>"
      echo "       $0 [--target <name>] --all"
      echo ""
      echo "Update dependency hashes for staleness tracking."
      exit 0
      ;;
    *) die "Unknown arg: $1" ;;
  esac
done

[[ -n "$MODE" ]] || die "Please specify --route <RouteName> or --all"

# Detect single-app vs multi-app mode
is_single_app_mode() {
  if [ -d "${DESIGN_DIR}/specs/screens" ]; then
    local target_count
    target_count=$(find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$target_count" = "0" ]; then
      return 0
    fi
  fi
  return 1
}

# Determine outputs.json path
if is_single_app_mode; then
  OUTPUTS_JSON="${DESIGN_DIR}/generated/meta/outputs.json"
else
  if [ -z "$TARGET" ]; then
    echo "Error: Multi-app project detected. --target is required." >&2
    echo ""
    echo "Available targets:"
    find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" -exec basename {} \; 2>/dev/null
    exit 1
  fi
  OUTPUTS_JSON="${DESIGN_DIR}/generated/${TARGET}/meta/outputs.json"
fi

if [[ ! -f "$OUTPUTS_JSON" ]]; then
  echo "Creating empty outputs.json at ${OUTPUTS_JSON}"
  mkdir -p "$(dirname "$OUTPUTS_JSON")"
  echo '{"outputs":[]}' > "$OUTPUTS_JSON"
fi

update_route() {
  local route="$1"
  local deps
  deps=$(jq -r --arg r "$route" '.outputs[] | select(.route==$r).dependsOn[]?' "$OUTPUTS_JSON" 2>/dev/null || true)
  
  if [[ -z "$deps" ]]; then
    echo "WARN: No dependsOn for route $route; skipping"
    return
  fi
  
  # Build JSON object of depHashes
  local depobj='{}'
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    # Handle relative paths
    local filepath="$f"
    if [[ ! "$f" = /* ]]; then
      filepath="${PROJECT_DIR}/${f}"
    fi
    if [[ -f "$filepath" ]]; then
      local h
      h=$(shasum -a 256 "$filepath" | awk '{print $1}')
      depobj=$(jq --arg k "$f" --arg v "$h" '. + {($k): $v}' <<<"$depobj")
    else
      echo "NOTE: dependsOn missing for $route: $f (skipping)"
    fi
  done <<< "$deps"
  
  # Write back
  local tmp
  tmp=$(mktemp)
  jq --arg r "$route" --argjson obj "$depobj" '(.outputs[] | select(.route==$r).depHashes) = $obj' "$OUTPUTS_JSON" > "$tmp"
  mv "$tmp" "$OUTPUTS_JSON"
  echo "Updated depHashes for $route"
}

if [[ "$MODE" == "route" ]]; then
  update_route "$TARGET_ROUTE"
else
  # all (explicit)
  routes=$(jq -r '.outputs[].route' "$OUTPUTS_JSON" 2>/dev/null || true)
  if [[ -z "$routes" ]]; then
    echo "No outputs registered in ${OUTPUTS_JSON}"
    exit 0
  fi
  while IFS= read -r r; do
    [[ -z "$r" ]] && continue
    update_route "$r"
  done <<< "$routes"
fi

echo "Done."
