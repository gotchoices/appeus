#!/usr/bin/env bash
set -euo pipefail

# Capacitor framework scaffold for Appeus v2
# Called by add-app.sh, not directly.
#
# STATUS: STUB - Not yet implemented
#
# Arguments:
#   $1 - App directory (e.g., /path/to/project/apps/mobile)
#   $2 - App name (e.g., mobile)
#
# Environment variables (planned):
#   APPEUS_LANG       - ts | js (default: ts)
#   APPEUS_PM         - yarn | npm | pnpm (default: npm)
#
# Note: Capacitor wraps an existing web app as a native mobile app.
# Typically used with an existing SvelteKit, Vue, or React web app.
#
# Will use: npm install @capacitor/core @capacitor/cli
#           npx cap init

APP_DIR="$1"
APP_NAME="$2"

echo "========================================"
echo "Capacitor: NOT YET IMPLEMENTED"
echo "========================================"
echo ""
echo "Capacitor wraps web apps as native mobile apps (iOS/Android)."
echo "It's a hybrid approach - your web code runs in a WebView."
echo ""
echo "Capacitor is ideal for:"
echo "  - Converting existing web apps to mobile"
echo "  - Teams with web expertise who want mobile presence"
echo "  - Apps where web-like UX is acceptable"
echo ""
echo "For truly native mobile UX, consider:"
echo "  - react-native"
echo "  - nativescript-svelte"
echo ""
echo "To contribute:"
echo "  1. Implement scaffold logic using Capacitor CLI"
echo "  2. Add reference docs at reference/frameworks/capacitor.md"
echo "  3. Test with a sample project"
echo ""

exit 1

