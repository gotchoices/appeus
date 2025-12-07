#!/usr/bin/env bash
set -euo pipefail

# publish-scenarios.sh
# Package scenarios site and optionally rsync to a remote destination.
# Supports both single-app and multi-app project structures.
#
# Usage:
#   appeus/scripts/publish-scenarios.sh [--target <name>] [--dest user@host:/path] [--dry-run]
#
# In multi-app projects, --target is required.
#
# Env:
#   APPEUS_PUBLISH_DEST can provide the default destination

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DESIGN_DIR="${PROJECT_DIR}/design"

TARGET=""
DEST="${APPEUS_PUBLISH_DEST:-}"
DRYRUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --dest) DEST="${2:-}"; shift 2 ;;
    --dry-run) DRYRUN=1; shift ;;
    -h|--help)
      echo "Usage: $0 [--target <name>] [--dest user@host:/path] [--dry-run]"
      echo "  --target  App target (required for multi-app projects)"
      echo "  --dest    rsync destination"
      echo "  --dry-run Print rsync command without executing"
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

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

# Determine paths based on mode
if is_single_app_mode; then
  GEN_DIR="${DESIGN_DIR}/generated"
else
  if [ -z "$TARGET" ]; then
    echo "Error: Multi-app project detected. --target is required." >&2
    echo ""
    echo "Available targets:"
    find "${DESIGN_DIR}/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" -exec basename {} \; 2>/dev/null
    exit 1
  fi
  GEN_DIR="${DESIGN_DIR}/generated/${TARGET}"
fi

SCEN_DIR="${GEN_DIR}/scenarios"
IMG_DIR="${GEN_DIR}/images"
SITE_DIR="${GEN_DIR}/site"
TPL_PAGE="${SCRIPT_DIR}/../templates/scenarios/page.html"

if [[ ! -d "${SCEN_DIR}" ]]; then
  echo "Scenarios directory not found: ${SCEN_DIR}"
  exit 1
fi

mkdir -p "${SITE_DIR}/scenarios" "${SITE_DIR}/images"
cp -f "${IMG_DIR}"/*.png "${SITE_DIR}/images/" 2>/dev/null || true

# If marked is available, export Markdown → HTML; otherwise copy Markdown as-is
if command -v npx >/dev/null 2>&1; then
  echo "Rendering Markdown to HTML..."
  for f in "${SCEN_DIR}"/*.md; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f" .md)"
    html_content="$(npx --yes marked -i "$f")"
    if [[ -f "${TPL_PAGE}" ]]; then
      # Wrap with template
      page="$(cat "${TPL_PAGE}")"
      page="${page//'{{title}}'/${name}}"
      # Use printf %s to preserve newlines properly
      printf "%s" "${page//'{{content}}'/${html_content}}" > "${SITE_DIR}/scenarios/${name}.html"
    else
      printf "<!doctype html><meta charset=\"utf-8\"><title>%s</title>%s" "${name}" "${html_content}" > "${SITE_DIR}/scenarios/${name}.html"
    fi
  done
  # Root index redirect to rendered scenarios index
  echo "<!doctype html><meta http-equiv=\"refresh\" content=\"0; url=scenarios/index.html\">" > "${SITE_DIR}/index.html"
  # Fix links in all rendered pages from .md → .html
  for html in "${SITE_DIR}/scenarios/"*.html; do
    [[ -f "$html" ]] || continue
    if command -v perl >/dev/null 2>&1; then
      perl -0777 -pe 's/href="([^"]+)\.md"/href="$1.html"/g' -i "$html"
    else
      sed -i '' -e 's/href=\"\\([^"]*\\)\\.md\"/href=\"\\1.html\"/g' "$html" 2>/dev/null || sed -i -e 's/href=\"\([^"]*\)\.md\"/href=\"\1.html\"/g' "$html"
    fi
  done
else
  echo "npx not found; publishing raw Markdown."
  cp -f "${SCEN_DIR}"/*.md "${SITE_DIR}/scenarios/" 2>/dev/null || true
  echo "<!doctype html><meta http-equiv=\"refresh\" content=\"0; url=scenarios/index.md\">" > "${SITE_DIR}/index.html"
fi

echo "Packaged site at ${SITE_DIR}"

if [[ -n "$DEST" ]]; then
  echo "Publishing to ${DEST} …"
  if [[ "$DRYRUN" -eq 1 ]]; then
    echo "rsync -avz --delete \"${SITE_DIR}/\" \"${DEST}/\""
    exit 0
  fi
  if command -v rsync >/dev/null 2>&1; then
    rsync -avz --delete "${SITE_DIR}/" "${DEST}/"
    echo "Publish complete."
  else
    echo "rsync not found. Please copy ${SITE_DIR}/ to ${DEST} manually."
    exit 2
  fi
else
  echo "No destination provided. Set APPEUS_PUBLISH_DEST or pass --dest user@host:/path"
fi
