#!/usr/bin/env bash
# scenarios.sh — run scripts/lib/scenarios.js with its packages on PATH.
#
# scenarios.js needs `yaml` (and `marked` for serve/build). `npx -p` fetches
# them once into the npm cache and exposes them for the run, so no install step
# is required in the project or the toolkit.
#
# Usage (after sourcing): appeus_scenarios_js <command> --project <dir> --target <name> [...]

appeus_scenarios_js() {
  local lib_dir
  lib_dir="$(cd -L "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  if ! command -v npx >/dev/null 2>&1; then
    echo "Error: node/npx is required (scripts/lib/scenarios.js reads the state registry)." >&2
    return 1
  fi
  npx --yes -p marked -p yaml node "${lib_dir}/scenarios.js" "$@"
}
