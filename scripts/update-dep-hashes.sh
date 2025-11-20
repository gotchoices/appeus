#!/usr/bin/env bash
set -euo pipefail

# update-dep-hashes.sh
# Recomputes SHA256 hashes for dependsOn files and updates design/generated/meta/outputs.json depHashes.
# Usage (preferred, per-output):
#   appeus/scripts/update-dep-hashes.sh --route <RouteName>
# Optional sweep (explicit only):
#   appeus/scripts/update-dep-hashes.sh --all
#
# Run from the project root (where design/ and src/ live). Intended to be invoked immediately
# after regenerating a single output so metadata stays in sync.

die() { echo "Error: $*" >&2; exit 1; }

# Ensure required tools
command -v jq >/dev/null 2>&1 || die "jq is required"
command -v shasum >/dev/null 2>&1 || die "shasum is required"

OUTPUTS_JSON="design/generated/meta/outputs.json"
[[ -f "$OUTPUTS_JSON" ]] || die "Missing $OUTPUTS_JSON (run from project root)"

MODE="route"
TARGET_ROUTE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --all) MODE="all"; shift ;;
    --route) MODE="route"; TARGET_ROUTE="${2:-}"; [[ -n "$TARGET_ROUTE" ]] || die "--route requires a value"; shift 2 ;;
    *) die "Unknown arg: $1" ;;
  esac
done

update_route() {
  local route="$1"
  local deps
  deps=$(jq -r --arg r "$route" '.outputs[] | select(.route==$r).dependsOn[]?' "$OUTPUTS_JSON")
  if [[ -z "$deps" ]]; then
    echo "WARN: No dependsOn for route $route; skipping"
    return
  fi
  # Build JSON object of depHashes
  local depobj='{}'
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if [[ -f "$f" ]]; then
      local h
      h=$(shasum -a 256 "$f" | awk '{print $1}')
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
  [[ -n "$TARGET_ROUTE" ]] || die "Please specify --route <RouteName> or use --all"
  update_route "$TARGET_ROUTE"
else
  # all (explicit)
  routes=$(jq -r '.outputs[].route' "$OUTPUTS_JSON")
  while IFS= read -r r; do
    [[ -z "$r" ]] && continue
    update_route "$r"
  done <<< "$routes"
fi

echo "Done."


