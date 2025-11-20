#!/usr/bin/env bash
set -euo pipefail

# publish-scenarios.sh
# Package scenarios site and optionally rsync to a remote destination.
#
# Usage:
#   appeus/scripts/publish-scenarios.sh [--dest user@host:/path] [--dry-run]
# Env:
#   APPEUS_PUBLISH_DEST can provide the default destination
#

DEST="${APPEUS_PUBLISH_DEST:-}"
DRYRUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dest) DEST="${2:-}"; shift 2 ;;
    --dry-run) DRYRUN=1; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

ROOT="$(pwd)"
GEN_DIR="${ROOT}/design/generated"
SCEN_DIR="${GEN_DIR}/scenarios"
IMG_DIR="${GEN_DIR}/images"
SITE_DIR="${GEN_DIR}/site"
VIEWER_SRC="${ROOT}/appeus/templates/scenarios/viewer.html"

mkdir -p "${SITE_DIR}/scenarios" "${SITE_DIR}/images"
cp -f "${VIEWER_SRC}" "${SITE_DIR}/index.html"
cp -f "${SCEN_DIR}"/*.md "${SITE_DIR}/scenarios/" 2>/dev/null || true
cp -f "${IMG_DIR}"/*.png "${SITE_DIR}/images/" 2>/dev/null || true

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


