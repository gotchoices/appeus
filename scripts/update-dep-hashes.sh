#!/usr/bin/env bash
set -euo pipefail

# update-dep-hashes.sh
# Recomputes SHA256 hashes for dependsOn files and updates outputs.json depHashes.
# Appeus v2.1 canonical: per-target layout only.
#
# Usage:
#   appeus/scripts/update-dep-hashes.sh [--target <name>] --route <RouteName>
#   appeus/scripts/update-dep-hashes.sh [--target <name>] --all
#
# If exactly one target exists, --target defaults to it. If multiple targets exist, --target is required.

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project (with design/ and appeus/ at the root), or set APPEUS_PROJECT_DIR." >&2
  exit 1
}
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

# v2.1 canonical: per-target specs are directories under design/specs/, alongside project.md and domain/
# Keep backward compatibility by excluding legacy v2.0 folders as well.
list_targets() {
  find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d \
    ! -name "domain" \
    ! -name "schema" \
    ! -name "api" \
    ! -name "global" \
    ! -name "screens" \
    ! -name "components" \
    -exec basename {} \; 2>/dev/null
}

extract_routes_from_index() {
  local index_file="$1"
  [ -f "${index_file}" ] || return 0
  awk -F'|' '
    NF>=4 && $0 ~ /^\|/ {
      for (i=1;i<=NF;i++){ sub(/^[ \t]+/,"",$i); sub(/[ \t]+$/,"",$i) }
      if ($2 == "Screen Name") next;
      if ($3 == "Route") next;
      if ($0 ~ /^\|[- ]+\|/) next;
      if ($3 != "") print $3
    }' "${index_file}" | sed 's/ //g'
}

# Infer a conservative dependsOn list for a route (broad but safe).
infer_depends_on_for_route() {
  local target="$1"
  local route="$2"

  local deps=()

  # Shared project/toolchain spec
  [ -f "${PROJECT_DIR}/design/specs/project.md" ] && deps+=("design/specs/project.md")

  # Shared domain contract (v2.1)
  if [ -d "${PROJECT_DIR}/design/specs/domain" ]; then
    while IFS= read -r -d '' f; do
      deps+=("${f#${PROJECT_DIR}/}")
    done < <(find "${PROJECT_DIR}/design/specs/domain" -type f -name "*.md" -print0 2>/dev/null || true)
  fi

  [ -f "${PROJECT_DIR}/design/specs/${target}/navigation.md" ] && deps+=("design/specs/${target}/navigation.md")
  [ -f "${PROJECT_DIR}/design/specs/${target}/screens/index.md" ] && deps+=("design/specs/${target}/screens/index.md")
  # All stories for target
  if [ -d "${PROJECT_DIR}/design/stories/${target}" ]; then
    while IFS= read -r -d '' f; do deps+=("${f#${PROJECT_DIR}/}"); done < <(find "${PROJECT_DIR}/design/stories/${target}" -type f -name "*.md" -print0 2>/dev/null || true)
  fi
  # Per-screen spec
  local kebab
  kebab="$(echo "${route}" | sed -E 's/([a-z0-9])([A-Z])/\1-\L\2/g' | tr '[:upper:]' '[:lower:]')"
  [ -f "${PROJECT_DIR}/design/specs/${target}/screens/${kebab}.md" ] && deps+=("design/specs/${target}/screens/${kebab}.md")
  [ -f "${PROJECT_DIR}/design/specs/${target}/screens/${route}.md" ] && deps+=("design/specs/${target}/screens/${route}.md")

  # Unique + stable order
  printf "%s\n" "${deps[@]}" | awk 'NF && !seen[$0]++'
}

ensure_outputs_registry_seeded() {
  local registry="$1"
  local target="$2"

  # If outputs is empty, seed from screens index.
  local count
  count=$(jq -r '.outputs | length' "$registry" 2>/dev/null || echo "0")
  if [ "$count" != "0" ]; then
    return 0
  fi

  local index_file=""
  index_file="${PROJECT_DIR}/design/specs/${target}/screens/index.md"

  local routes
  routes="$(extract_routes_from_index "${index_file}" || true)"
  if [ -z "${routes}" ]; then
    # Nothing to seed (no index, or empty index) — keep empty registry.
    return 0
  fi

  while IFS= read -r r; do
    [ -z "$r" ] && continue
    local deps_json
    deps_json=$(infer_depends_on_for_route "${target}" "$r" | jq -R . | jq -s .)
    local tmp
    tmp=$(mktemp)
    jq --arg route "$r" --argjson deps "$deps_json" '
      if any(.outputs[]?; .route == $route) then
        .
      else
        .outputs += [{"route": $route, "dependsOn": $deps, "depHashes": {}}]
      end
    ' "$registry" > "$tmp"
    mv "$tmp" "$registry"
  done <<< "$routes"
}

ensure_route_entry() {
  local registry="$1"
  local target="$2"
  local route="$3"

  if jq -e --arg r "$route" 'any(.outputs[]?; .route == $r)' "$registry" >/dev/null 2>&1; then
    return 0
  fi

  local deps_json
  deps_json=$(infer_depends_on_for_route "${target}" "$route" | jq -R . | jq -s .)
  local tmp
  tmp=$(mktemp)
  jq --arg route "$route" --argjson deps "$deps_json" '
    .outputs += [{"route": $route, "dependsOn": $deps, "depHashes": {}}]
  ' "$registry" > "$tmp"
  mv "$tmp" "$registry"
}

# Determine outputs.json path (per-target)
if [ -z "$TARGET" ]; then
  targets="$(list_targets || true)"
  if [ -z "${targets}" ]; then
    die "No targets found under design/specs/. Add an app first (scripts/add-app.sh)."
  fi
  target_count=$(printf "%s\n" "${targets}" | wc -l | tr -d ' ')
  if [ "${target_count}" = "1" ]; then
    TARGET=$(printf "%s\n" "${targets}" | head -n 1)
    echo "NOTE: Defaulting --target to '${TARGET}' (only target found)"
  else
    echo "Error: Multiple targets detected. --target is required." >&2
    echo ""
    echo "Available targets:"
    printf "%s\n" "${targets}"
    exit 1
  fi
fi
OUTPUTS_JSON="${DESIGN_DIR}/generated/${TARGET}/meta/outputs.json"

if [[ ! -f "$OUTPUTS_JSON" ]]; then
  echo "Creating empty outputs.json at ${OUTPUTS_JSON}"
  mkdir -p "$(dirname "$OUTPUTS_JSON")"
  echo '{"outputs":[]}' > "$OUTPUTS_JSON"
fi

# If the registry exists but is empty/template-like, seed it from the screens index (non-destructive).
ensure_outputs_registry_seeded "$OUTPUTS_JSON" "$TARGET"

update_route() {
  local route="$1"
  # Ensure there is a route entry; if missing, add it (non-destructive).
  ensure_route_entry "$OUTPUTS_JSON" "$TARGET" "$route"
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
