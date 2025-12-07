#!/usr/bin/env bash
set -euo pipefail

# Tauri framework scaffold for Appeus v2
# Called by add-app.sh, not directly.
#
# STATUS: STUB - Not yet implemented
#
# Arguments:
#   $1 - App directory (e.g., /path/to/project/apps/desktop)
#   $2 - App name (e.g., desktop)
#
# Environment variables (planned):
#   APPEUS_LANG       - ts | js (default: ts)
#   APPEUS_PM         - yarn | npm | pnpm (default: npm)
#   APPEUS_FRONTEND   - svelte | vue | react (default: svelte)
#
# Will use: npm create tauri-app@latest
#
# Note: Tauri wraps a web frontend (Svelte, Vue, React) as a desktop app.
# Consider sharing code with an existing web target.

APP_DIR="$1"
APP_NAME="$2"

echo "========================================"
echo "Tauri: NOT YET IMPLEMENTED"
echo "========================================"
echo ""
echo "Tauri creates lightweight desktop apps using web technologies."
echo "It wraps a web frontend (Svelte, Vue, React) with a Rust backend."
echo ""
echo "Tauri is ideal for:"
echo "  - Desktop versions of web apps"
echo "  - Cross-platform desktop apps (macOS, Windows, Linux)"
echo "  - Smaller bundle sizes than Electron"
echo ""
echo "To contribute:"
echo "  1. Implement scaffold logic using 'npm create tauri-app'"
echo "  2. Add reference docs at reference/frameworks/tauri.md"
echo "  3. Test with a sample project"
echo ""
echo "For now, use sveltekit for web apps."
echo ""

exit 1

