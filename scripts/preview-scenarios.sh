#!/usr/bin/env bash
set -euo pipefail

# preview-scenarios.sh
# Serve the scenarios folder with Markdown rendering.
# Supports both single-app and multi-app project structures.
#
# Usage:
#   appeus/scripts/preview-scenarios.sh [--target <name>] [--port 8080]
#
# In multi-app projects, --target is required.
#
# Requires node + npx. Uses markserv to render Markdown in-place.
# Falls back to a plain static server if markserv is unavailable (MD not rendered).

SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DESIGN_DIR="${PROJECT_DIR}/design"

TARGET=""
PORT=8080

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --port) PORT="${2:-8080}"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target <name>] [--port <port>]"
      echo "  --target  App target (required for multi-app projects)"
      echo "  --port    Port to serve on (default: 8080)"
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

if [[ ! -d "${SCEN_DIR}" ]]; then
  echo "Scenarios directory not found: ${SCEN_DIR}"
  exit 1
fi

if [[ ! -d "${IMG_DIR}" ]]; then
  mkdir -p "${IMG_DIR}"
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
  npx --prefix="${GEN_DIR}" --yes markserv "scenarios/index.md" --port "${PORT}"
else
  echo "npx not found. Falling back to a simple HTTP server (Markdown will not be rendered)."
  cd "${GEN_DIR}"
  if command -v python3 >/dev/null 2>&1; then
    python3 -m http.server "${PORT}"
  else
    python -m SimpleHTTPServer "${PORT}"
  fi
fi
