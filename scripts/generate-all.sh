#!/usr/bin/env bash
set -euo pipefail

# Iterate vertical slices until clean (agent-driven).

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

while true; do
  "${ROOT_DIR}/appeus/scripts/check-stale.sh" >/dev/null
  STALE_COUNT="$(jq -r '.staleCount // 0' "${ROOT_DIR}/design/generated/status.json" 2>/dev/null || echo 0)"
  if [ "${STALE_COUNT}" -eq 0 ]; then
    echo "Nothing to generate. Clean."
    exit 0
  fi
  "${ROOT_DIR}/appeus/scripts/generate-next.sh"
  echo ""
  echo "After completing the above steps, re-run this command to proceed to the next slice."
  exit 0
done


