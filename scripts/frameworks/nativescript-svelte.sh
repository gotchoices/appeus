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
#   APPEUS_LANG                    - ts | js (default: ts)
#   APPEUS_PM                      - yarn | npm | pnpm (default: npm)
#   APPEUS_NS_VERSION              - NativeScript core version (default: 8.9.9)
#   APPEUS_SVELTE_NATIVE_VERSION   - svelte-native version (default: 1.0.29)

APP_DIR="$1"
APP_NAME="$2"

LANG_CHOICE="${APPEUS_LANG:-ts}"
PM_CHOICE="${APPEUS_PM:-npm}"

# Known-good versions (these work together without peer conflicts)
RECOMMENDED_NS_VERSION="${APPEUS_NS_VERSION:-8.9.9}"
RECOMMENDED_SN_VERSION="${APPEUS_SVELTE_NATIVE_VERSION:-1.0.29}"

echo "NativeScript Svelte scaffold:"
echo "  Language: ${LANG_CHOICE}"
echo "  Package manager: ${PM_CHOICE}"
echo "  Recommended versions:"
echo "    @nativescript/core: ${RECOMMENDED_NS_VERSION}"
echo "    svelte-native: ${RECOMMENDED_SN_VERSION}"
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
# Set npm to use legacy-peer-deps to avoid ERESOLVE errors during scaffold
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

# Create .npmrc for ongoing development (prevents peer dep issues when running ns commands)
if [ ! -f "${APP_DIR}/.npmrc" ]; then
  echo "legacy-peer-deps=true" > "${APP_DIR}/.npmrc"
fi

# Check installed versions vs recommended
VERSION_MISMATCH=0
INSTALLED_NS=""
INSTALLED_SN=""

if command -v jq &> /dev/null && [ -f "${APP_DIR}/package.json" ]; then
  INSTALLED_NS=$(jq -r '.dependencies["@nativescript/core"] // "unknown"' "${APP_DIR}/package.json" | sed 's/[~^]//g')
  INSTALLED_SN=$(jq -r '.dependencies["@nativescript-community/svelte-native"] // "unknown"' "${APP_DIR}/package.json" | sed 's/[~^]//g')
  
  # Normalize version strings for comparison (remove ~ and ^, get first part)
  INSTALLED_NS_CLEAN=$(echo "$INSTALLED_NS" | sed 's/[~^]//g' | cut -d'.' -f1-3)
  INSTALLED_SN_CLEAN=$(echo "$INSTALLED_SN" | sed 's/[~^]//g' | cut -d'.' -f1-3)
  
  if [[ "$INSTALLED_NS_CLEAN" != "$RECOMMENDED_NS_VERSION" ]] || [[ "$INSTALLED_SN_CLEAN" != "$RECOMMENDED_SN_VERSION" ]]; then
    VERSION_MISMATCH=1
  fi
fi

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
  cat > "${SPECS_DIR}/global/dependencies.md" <<EOF
# Dependencies Spec

NativeScript Svelte dependencies.

\`\`\`yaml
deps:
  - "@nativescript/core": "${RECOMMENDED_NS_VERSION}"
  - "@nativescript-community/svelte-native": "${RECOMMENDED_SN_VERSION}"
  - "svelte": "^4"
devDeps:
  - "typescript": "^5"
  - "@nativescript/types": "${RECOMMENDED_NS_VERSION}"
  - "svelte-check": "^3"
\`\`\`

## Notes

- Versions shown are known to work together
- Run \`ns doctor\` to verify environment setup
EOF
fi

echo ""
echo "NativeScript Svelte scaffold complete."
echo "  App location: ${APP_DIR}"
echo "  Source: ${APP_DIR}/app/"
echo ""

# Version mismatch advisory
if [ "$VERSION_MISMATCH" = "1" ]; then
  echo "========================================"
  echo "⚠️  VERSION MISMATCH DETECTED"
  echo "========================================"
  echo ""
  echo "The template installed different versions than recommended:"
  echo ""
  echo "  Installed                          Recommended"
  echo "  ---------                          -----------"
  echo "  @nativescript/core: ${INSTALLED_NS}    ${RECOMMENDED_NS_VERSION}"
  echo "  svelte-native: ${INSTALLED_SN}         ${RECOMMENDED_SN_VERSION}"
  echo ""
  echo "If you encounter peer dependency or runtime issues, edit package.json:"
  echo ""
  echo "  \"@nativescript/core\": \"${RECOMMENDED_NS_VERSION}\","
  echo "  \"@nativescript/types\": \"${RECOMMENDED_NS_VERSION}\"  (in devDependencies)"
  echo ""
  echo "Then reinstall:"
  echo ""
  echo "  cd apps/${APP_NAME}"
  echo "  rm -rf node_modules package-lock.json"
  echo "  npm install"
  echo ""
  echo "To use these versions by default, set environment variables:"
  echo "  APPEUS_NS_VERSION=${RECOMMENDED_NS_VERSION}"
  echo "  APPEUS_SVELTE_NATIVE_VERSION=${RECOMMENDED_SN_VERSION}"
  echo ""
fi

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
