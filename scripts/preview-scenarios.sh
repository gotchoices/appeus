#!/usr/bin/env bash
set -euo pipefail

# preview-scenarios.sh
# Serve a target's scenarios locally with live deep links: clicking a `<scheme>://` link
# on a page opens that state on the connected device/emulator (through open-deeplink.sh).
# Also serves /states — every registry entry, captured or not.
#
# Usage:
#   appeus/scripts/preview-scenarios.sh [--target <name>] [--port 8080] [--host 127.0.0.1] [--no-open]
#
#   --host 0.0.0.0   also reachable on the LAN: a phone with the app installed resolves the
#                    links itself (the page does not intercept clicks on a mobile browser)
#   --no-open        do not open a browser tab
#
# If exactly one target exists, --target defaults to it. Requires node/npx
# (scripts/lib/scenarios.js renders the pages). publish-scenarios.sh renders the same
# pages statically, with raw links.

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
# shellcheck source=lib/scenarios.sh
source "${SCRIPT_DIR}/lib/scenarios.sh"

TARGET="" PORT=8080 HOST=127.0.0.1 OPEN=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --port) PORT="${2:-8080}"; shift 2 ;;
    --host) HOST="${2:-127.0.0.1}"; shift 2 ;;
    --no-open) OPEN=0; shift ;;
    -h|--help) sed -n '/^# Usage:/,/^# If exactly/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

PROJECT_DIR="$(appeus_find_project_dir "$SCRIPT_DIR")" || {
  echo "Error: Could not find project root. Run from inside your project (with design/ and appeus/ at the root), or set APPEUS_PROJECT_DIR." >&2
  exit 1
}
TARGET="$(appeus_resolve_target "$PROJECT_DIR" "$TARGET")" || exit 1
GEN_DIR="${PROJECT_DIR}/design/generated/${TARGET}"
[[ -d "$GEN_DIR" ]] || { echo "Error: ${GEN_DIR} does not exist (run add-app.sh for this target)." >&2; exit 1; }
[[ -f "${GEN_DIR}/images/index.md" ]] || echo "Note: no ${GEN_DIR#${PROJECT_DIR}/}/images/index.md yet; links cannot be opened until it names a scheme."

URL="http://$([[ "$HOST" = "0.0.0.0" ]] && echo localhost || echo "$HOST"):${PORT}/"
if [[ "$OPEN" = "1" ]]; then
  (
    sleep 1.5
    if command -v open >/dev/null 2>&1; then open "$URL" >/dev/null 2>&1 || true
    elif command -v xdg-open >/dev/null 2>&1; then xdg-open "$URL" >/dev/null 2>&1 || true
    fi
  ) &
fi

appeus_scenarios_js serve --project "$PROJECT_DIR" --target "$TARGET" \
  --port "$PORT" --host "$HOST" --open-script "${SCRIPT_DIR}/open-deeplink.sh"
