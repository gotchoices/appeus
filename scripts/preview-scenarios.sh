#!/usr/bin/env bash
set -euo pipefail

# preview-scenarios.sh
# Serve the scenarios folder with Markdown rendering.
# Appeus v2.1 canonical: per-target layout only.
#
# Usage:
#   appeus/scripts/preview-scenarios.sh [--target <name>] [--port 8080]
#
# If exactly one target exists, --target defaults to it. If multiple targets exist, --target is required.
#
# Requires node + npx. Uses markserv to render Markdown in-place.
# Falls back to a plain static server if markserv is unavailable (MD not rendered).

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project (with design/ and appeus/ at the root), or set APPEUS_PROJECT_DIR." >&2
  exit 1
}
DESIGN_DIR="${PROJECT_DIR}/design"

TARGET=""
PORT=8080

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --port) PORT="${2:-8080}"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--target <name>] [--port <port>]"
      echo "  --target  App target (required if multiple targets exist)"
      echo "  --port    Port to serve on (default: 8080)"
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

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

if [ -z "$TARGET" ]; then
  targets="$(list_targets || true)"
  if [ -z "${targets}" ]; then
    echo "Error: No targets found under design/specs/. Add an app first (scripts/add-app.sh)." >&2
    exit 1
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

GEN_DIR="${DESIGN_DIR}/generated/${TARGET}"

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
