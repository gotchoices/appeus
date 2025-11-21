#!/usr/bin/env bash
set -euo pipefail

# preview-scenarios.sh
# Serve the scenarios folder like appgen did (Markdown rendered by markserv).
# Usage: appeus/scripts/preview-scenarios.sh [--port 8080]
#
# Requires node + npx. Installs/uses markserv to render Markdown in-place.
# Falls back to a plain static server if markserv is unavailable (MD not rendered).

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
if [[ ! -d "${SCEN_DIR}" || ! -d "${IMG_DIR}" ]]; then
  echo "Scenarios or images directory not found under ${GEN_DIR}"
  exit 1
fi

echo "Previewing scenarios from ${GEN_DIR}"
if command -v npx >/dev/null 2>&1; then
  echo "Starting markserv on http://localhost:${PORT}"
  cd "${GEN_DIR}"
  # Serve the generated root so /scenarios and /images resolve correctly
  # Try to open the index automatically
  (
    sleep 1
    if command -v open >/dev/null 2>&1; then
      open "http://localhost:${PORT}/scenarios/index.md" >/dev/null 2>&1 || true
    elif command -v xdg-open >/dev/null 2>&1; then
      xdg-open "http://localhost:${PORT}/scenarios/index.md" >/dev/null 2>&1 || true
    fi
  ) &
  npx --yes markserv "." --port "${PORT}"
else
  echo "npx not found. Falling back to a simple HTTP server (Markdown will not be rendered)."
  cd "${GEN_DIR}"
  if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "${PORT}"
  else
    python -m SimpleHTTPServer "${PORT}"
  fi
fi


