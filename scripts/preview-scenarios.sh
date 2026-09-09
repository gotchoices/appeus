#!/usr/bin/env bash
set -euo pipefail

# preview-scenarios.sh
# Serve a target's scenarios locally with live deep links: clicking a `<scheme>://` link
# on a page opens that state on the connected device/emulator (through open-deeplink.sh).
# Also serves /states — every registry entry, captured or not.
#
# Usage:
#   appeus/scripts/preview-scenarios.sh [--target <name>] [--device <id>] [--port 8080] [--host 127.0.0.1] [--no-open]
#
#   --device <id>    emulator serial / simulator udid this server sends links to (default:
#                    $APPEUS_DEVICE, else the only connected device). The page never chooses a
#                    device: run one server per project, each bound to its own emulator.
#   --port <n>       port to listen on (default: $APPEUS_PORT, else 8080). Give each project its
#                    own port when previewing several at once.
#   --host 0.0.0.0   also reachable on the LAN: a phone with the app installed resolves the
#                    links itself (the page does not intercept clicks on a mobile browser)
#   --no-open        do not open a browser tab
#   --verbose        log every request and the exact launch command (each link open is
#                    logged either way); also $APPEUS_VERBOSE=1
#
# The browser opened is the OS default; $APPEUS_BROWSER (or $BROWSER) names a different
# command. Nothing is opened over SSH/headless or with --no-open — the URL is printed either way.
#
# If exactly one target exists, --target defaults to it. Requires node/npx
# (scripts/lib/scenarios.js renders the pages). publish-scenarios.sh renders the same
# pages statically, with raw links.

SCRIPT_DIR="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/project-root.sh
source "${SCRIPT_DIR}/lib/project-root.sh"
# shellcheck source=lib/scenarios.sh
source "${SCRIPT_DIR}/lib/scenarios.sh"

TARGET="" PORT="${APPEUS_PORT:-8080}" HOST=127.0.0.1 OPEN=1 DEVICE="${APPEUS_DEVICE:-}"
VERBOSE=0; [[ "${APPEUS_VERBOSE:-0}" != "0" ]] && VERBOSE=1
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="${2:-}"; shift 2 ;;
    --device) DEVICE="${2:-}"; shift 2 ;;
    --port) PORT="${2:-${APPEUS_PORT:-8080}}"; shift 2 ;;
    --host) HOST="${2:-127.0.0.1}"; shift 2 ;;
    --no-open) OPEN=0; shift ;;
    --verbose|-v) VERBOSE=1; shift ;;
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

# Hand a URL to whatever the OS uses to open one. Never names a browser: the point is
# the user's default. Dispatch is by OS *first* — a bare `command -v open` would match
# util-linux's `open` (an alias for openvt, a virtual-terminal tool) on some Linux boxes.
open_browser() {
  local url="$1" opener

  # Explicit choice wins. $BROWSER is the long-standing convention; it may carry a %s.
  for opener in "${APPEUS_BROWSER:-}" "${BROWSER:-}"; do
    [[ -n "$opener" ]] || continue
    if [[ "$opener" == *%s* ]]; then
      ${opener//%s/$url} >/dev/null 2>&1 && return 0
    else
      $opener "$url" >/dev/null 2>&1 && return 0
    fi
    echo "Note: \$APPEUS_BROWSER/\$BROWSER ('${opener}') did not open the page." >&2
    return 1
  done

  case "$(uname -s)" in
    Darwin)
      command -v open >/dev/null 2>&1 && open "$url" >/dev/null 2>&1 && return 0
      ;;
    MINGW*|MSYS*|CYGWIN*)
      # `start` is a cmd builtin, not an executable; the empty title arg is required.
      command -v cmd.exe >/dev/null 2>&1 && cmd.exe /c start "" "$url" >/dev/null 2>&1 && return 0
      command -v powershell.exe >/dev/null 2>&1 && powershell.exe -NoProfile -Command Start-Process "$url" >/dev/null 2>&1 && return 0
      command -v explorer.exe >/dev/null 2>&1 && explorer.exe "$url" >/dev/null 2>&1 && return 0
      ;;
    Linux|*BSD|DragonFly)
      # WSL: hand it to Windows, which has the browser.
      if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
        for opener in wslview explorer.exe; do
          command -v "$opener" >/dev/null 2>&1 && "$opener" "$url" >/dev/null 2>&1 && return 0
        done
        command -v powershell.exe >/dev/null 2>&1 && powershell.exe -NoProfile -Command Start-Process "$url" >/dev/null 2>&1 && return 0
      fi
      # No display means no browser to open (SSH, headless CI, a bare tty).
      if [[ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
        return 1
      fi
      for opener in xdg-open gio gnome-open kde-open5 kde-open sensible-browser x-www-browser www-browser; do
        command -v "$opener" >/dev/null 2>&1 || continue
        if [[ "$opener" = "gio" ]]; then
          gio open "$url" >/dev/null 2>&1 && return 0
        else
          "$opener" "$url" >/dev/null 2>&1 && return 0
        fi
      done
      ;;
  esac
  return 1
}

if [[ "$OPEN" = "1" ]]; then
  (
    # Wait for *this* server to answer before opening a tab: on a port collision the
    # answer would come from the other project's preview.
    for _ in $(seq 1 40); do
      kill -0 "$$" 2>/dev/null || exit 0   # parent gone: startup failed
      if curl -sf -o /dev/null --max-time 1 "${URL}states" 2>/dev/null; then
        open_browser "$URL" || echo "Could not open a browser automatically — visit ${URL} (or set APPEUS_BROWSER)."
        exit 0
      fi
      sleep 0.5
    done
  ) &
fi

appeus_scenarios_js serve --project "$PROJECT_DIR" --target "$TARGET" \
  --port "$PORT" --host "$HOST" --open-script "${SCRIPT_DIR}/open-deeplink.sh" \
  ${DEVICE:+--device "$DEVICE"} $([[ "$VERBOSE" = "1" ]] && echo --verbose)
