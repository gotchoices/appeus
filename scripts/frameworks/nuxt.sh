#!/usr/bin/env bash
set -euo pipefail

# Nuxt framework scaffold for Appeus v2
# Called by add-app.sh, not directly.
#
# STATUS: STUB - Not yet implemented
#
# Arguments:
#   $1 - App directory (e.g., /path/to/project/apps/web)
#   $2 - App name (e.g., web)
#
# Environment variables (planned):
#   APPEUS_LANG       - ts | js (default: ts)
#   APPEUS_PM         - yarn | npm | pnpm (default: npm)
#
# Will use: npx nuxi init <name>

APP_DIR="$1"
APP_NAME="$2"

echo "========================================"
echo "Nuxt: NOT YET IMPLEMENTED"
echo "========================================"
echo ""
echo "Nuxt is a Vue-based web framework, similar to SvelteKit."
echo "It pairs well with NativeScript Vue for mobile."
echo ""
echo "To contribute:"
echo "  1. Implement scaffold logic using 'npx nuxi init'"
echo "  2. Add reference docs at reference/frameworks/nuxt.md"
echo "  3. Test with a sample project"
echo ""
echo "For now, use sveltekit for web apps."
echo ""

exit 1

