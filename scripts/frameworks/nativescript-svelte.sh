#!/usr/bin/env bash
set -euo pipefail

# NativeScript Svelte framework scaffold for Appeus v2
# Called by add-app.sh, not directly.
#
# Arguments:
#   $1 - App directory (e.g., /path/to/project/apps/mobile)
#   $2 - App name (e.g., mobile)
#
# Environment variables (optional):
#   APPEUS_LANG       - ts | js (default: ts)
#   APPEUS_PM         - yarn | npm | pnpm (default: npm)
#
# Requires:
#   - NativeScript CLI: npm install -g nativescript

APP_DIR="$1"
APP_NAME="$2"

LANG_CHOICE="${APPEUS_LANG:-ts}"
PM_CHOICE="${APPEUS_PM:-npm}"

echo "NativeScript Svelte scaffold:"
echo "  Language: ${LANG_CHOICE}"
echo "  Package manager: ${PM_CHOICE}"
echo ""

# Determine how to run NativeScript CLI
# Prefer npx (no install required), fall back to global ns
NS_CMD=""
if command -v npx &> /dev/null; then
  NS_CMD="npx nativescript"
  echo "Using npx to run NativeScript (no global install required)"
elif command -v ns &> /dev/null; then
  NS_CMD="ns"
  echo "Using globally installed NativeScript CLI"
else
  echo "Error: Cannot run NativeScript CLI." >&2
  echo "" >&2
  echo "Options:" >&2
  echo "  1. Install Node.js/npm (includes npx) - recommended" >&2
  echo "  2. Install NativeScript globally: npm install -g nativescript" >&2
  echo "" >&2
  exit 1
fi

# NativeScript creates the project in a subdirectory, so we need to work around that
TMP_PARENT_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'appeus-ns')"
PROJECT_NAME="$(basename "$APP_DIR")"

echo "Creating NativeScript Svelte app..."

# Workaround: svelte-native has peer dependency conflicts with NativeScript 9
# Set npm to use legacy-peer-deps to avoid ERESOLVE errors
export npm_config_legacy_peer_deps=true

# Create the project
if ! ( cd "${TMP_PARENT_DIR}" && $NS_CMD create "${PROJECT_NAME}" --svelte ); then
  echo "" >&2
  echo "Error: NativeScript project creation failed." >&2
  echo "" >&2
  echo "If you see peer dependency errors, this is a known issue with" >&2
  echo "@nativescript-community/svelte-native and NativeScript 9." >&2
  echo "" >&2
  echo "Try running manually with:" >&2
  echo "  npm config set legacy-peer-deps true" >&2
  echo "  npx nativescript create ${PROJECT_NAME} --svelte" >&2
  echo "" >&2
  rm -rf "${TMP_PARENT_DIR}"
  exit 1
fi

# Move scaffold into app directory
rsync -a "${TMP_PARENT_DIR}/${PROJECT_NAME}/" "${APP_DIR}/"
rm -rf "${TMP_PARENT_DIR}"

cd "$APP_DIR"

# TypeScript is default for NativeScript Svelte, but ensure config exists
if [ "${LANG_CHOICE}" = "ts" ]; then
  if [ ! -f "${APP_DIR}/tsconfig.json" ]; then
    cat > "${APP_DIR}/tsconfig.json" <<'JSON'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["app/**/*"],
  "exclude": ["node_modules", "platforms"]
}
JSON
  fi
fi

# Create src directory structure (NativeScript uses app/ by default, we'll add src/ for consistency)
mkdir -p "${APP_DIR}/app/components"
mkdir -p "${APP_DIR}/app/pages"
mkdir -p "${APP_DIR}/app/services"
mkdir -p "${APP_DIR}/app/data"

# Create global specs for this target
SPECS_DIR="$(dirname "$(dirname "$APP_DIR")")/design/specs/${APP_NAME}"
mkdir -p "${SPECS_DIR}/global"

# Write toolchain spec
cat > "${SPECS_DIR}/global/toolchain.md" <<EOF
# Toolchain Spec

language: ${LANG_CHOICE}
runtime: nativescript
framework: svelte-native
packageManager: ${PM_CHOICE}
navigation: nativescript-router
state: svelte-stores

notes:
- NativeScript Svelte uses the app/ folder for source code
- Components go in app/components/
- Pages go in app/pages/
- See https://svelte.nativescript.org/ for documentation
EOF

# Copy UI and dependencies templates if missing
APPEUS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
if [ ! -f "${SPECS_DIR}/global/ui.md" ]; then
  cp "${APPEUS_DIR}/templates/specs/global/ui.md" "${SPECS_DIR}/global/ui.md"
fi
if [ ! -f "${SPECS_DIR}/global/dependencies.md" ]; then
  cat > "${SPECS_DIR}/global/dependencies.md" <<'EOF'
# Dependencies Spec

NativeScript Svelte dependencies.

```yaml
deps:
  - "@nativescript/core": "^8"
  - "@nativescript-community/svelte-native": "^1"
  - "svelte": "^4"
devDeps:
  - "typescript": "^5"
  - "@nativescript/types": "^8"
  - "svelte-check": "^3"
```

## Notes

- Versions are indicative; adjust per project
- Run `ns doctor` to verify environment setup
EOF
fi

echo ""
echo "NativeScript Svelte scaffold complete."
echo "  App location: ${APP_DIR}"
echo "  Source: ${APP_DIR}/app/"
echo ""
echo "To run (choose one):"
echo ""
echo "  Using npx (no install):"
echo "    cd apps/${APP_NAME}"
echo "    npx nativescript preview"
echo "    npx nativescript run ios"
echo "    npx nativescript run android"
echo ""
echo "  Or install globally for shorter commands:"
echo "    npm install -g nativescript"
echo "    cd apps/${APP_NAME}"
echo "    ns preview"
echo "    ns run ios"
echo ""
echo "Documentation: https://svelte.nativescript.org/"
