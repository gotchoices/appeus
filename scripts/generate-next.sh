#!/usr/bin/env bash
set -euo pipefail

# Picks the next stale screen (vertical slice) and prints an AI-facing plan.
# Uses design/generated/status.json; if missing, runs check-stale first.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
STATUS_FILE="${ROOT_DIR}/design/generated/status.json"

[ -f "${STATUS_FILE}" ] || "${ROOT_DIR}/appeus/scripts/check-stale.sh" >/dev/null

if [ ! -f "${STATUS_FILE}" ]; then
  echo "No status.json and cannot compute staleness. Abort." >&2
  exit 1
fi

STATES="$(jq -r '.screens[] | select(.stale==true) | .route' "${STATUS_FILE}" 2>/dev/null || true)"
if [ -z "${STATES}" ]; then
  echo "All screens appear up to date."
  exit 0
fi

NEXT="$(printf '%s\n' "${STATES}" | head -n1)"
echo "Next vertical slice target: ${NEXT}"
echo ""
"${ROOT_DIR}/appeus/scripts/regenerate.sh" --screen "${NEXT}"


