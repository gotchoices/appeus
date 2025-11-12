#!/usr/bin/env bash
set -euo pipefail

# Lists design files newer than app outputs and suggests regeneration.
# Heuristic: if any files in design/specs or design/generated are newer than files in src/screens or src/navigation.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DESIGN_DIR="${ROOT_DIR}/design"
SRC_DIR="${ROOT_DIR}/src"

if [ ! -d "${DESIGN_DIR}" ]; then
  echo "No design/ folder found. Run appeus/scripts/init-project.sh first." >&2
  exit 1
fi

latest_design_mtime=$(find "${DESIGN_DIR}/specs" "${DESIGN_DIR}/generated" -type f 2>/dev/null | xargs -I{} stat -f %m {} 2>/dev/null | sort -nr | head -n1 || echo 0)
latest_src_mtime=$(find "${SRC_DIR}/screens" "${SRC_DIR}/navigation" -type f 2>/dev/null | xargs -I{} stat -f %m {} 2>/dev/null | sort -nr | head -n1 || echo 0)

echo "Latest design mtime: ${latest_design_mtime:-0}"
echo "Latest src mtime   : ${latest_src_mtime:-0}"

if [ "${latest_design_mtime:-0}" -gt "${latest_src_mtime:-0}" ]; then
  echo ""
  echo "Stale outputs detected:"
  echo " - Some files in design/specs or design/generated are newer than src outputs."
  echo "Consider running: appeus/scripts/regenerate"
  echo ""
  echo "Recent design changes:"
  find "${DESIGN_DIR}/specs" "${DESIGN_DIR}/generated" -type f -mtime -7d -print 2>/dev/null | sed 's|^| - |'
else
  echo "No stale outputs detected."
fi


