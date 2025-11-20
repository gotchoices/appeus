#!/usr/bin/env bash
set -euo pipefail

# preview-scenarios.sh
# Serve the scenarios and images locally for review.
# Usage: appeus/scripts/preview-scenarios.sh [--port 8080]

PORT=8080
while [[ $# -gt 0 ]]; do
  case "$1" in
    --port) PORT="${2:-8080}"; shift 2 ;;
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

echo "Serving ${SITE_DIR} on http://localhost:${PORT}"
cd "${SITE_DIR}"
if command -v python3 >/dev/null 2>&1; then
  python3 -m http.server "${PORT}"
else
  python -m SimpleHTTPServer "${PORT}"
fi


