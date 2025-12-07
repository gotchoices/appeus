#!/usr/bin/env bash
set -euo pipefail

# Next.js framework scaffold for Appeus v2
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
# Will use: npx create-next-app@latest <name>

APP_DIR="$1"
APP_NAME="$2"

echo "========================================"
echo "Next.js: NOT YET IMPLEMENTED"
echo "========================================"
echo ""
echo "Next.js is a React-based web framework."
echo "It pairs well with React Native for mobile."
echo ""
echo "To contribute:"
echo "  1. Implement scaffold logic using 'npx create-next-app'"
echo "  2. Add reference docs at reference/frameworks/nextjs.md"
echo "  3. Test with a sample project"
echo ""
echo "For now, use sveltekit for web apps or react-native for mobile."
echo ""

exit 1

