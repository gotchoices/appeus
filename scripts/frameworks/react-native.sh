#!/usr/bin/env bash
set -euo pipefail

# React Native framework scaffold for Appeus v2
# Called by add-app.sh, not directly.
#
# Arguments:
#   $1 - App directory (e.g., /path/to/project/apps/mobile)
#   $2 - App name (e.g., mobile)
#
# Environment variables (optional):
#   APPEUS_RUNTIME    - expo | bare (default: bare)
#   APPEUS_LANG       - ts | js (default: ts)
#   APPEUS_PM         - yarn | npm | pnpm (default: yarn)
#   APPEUS_RN_VERSION - React Native version (default: 0.82.1)

APP_DIR="$1"
APP_NAME="$2"

LANG_CHOICE="${APPEUS_LANG:-ts}"
PM_CHOICE="${APPEUS_PM:-yarn}"
RUNTIME_CHOICE="${APPEUS_RUNTIME:-bare}"
RN_VERSION="${APPEUS_RN_VERSION:-0.82.1}"

# Sanitize app name for RN (alphanumeric only, start with letter)
RN_APP_NAME="$(printf "%s" "${APP_NAME}" | sed 's/[^A-Za-z0-9]//g')"
if [ -z "${RN_APP_NAME}" ]; then RN_APP_NAME="AppeusApp"; fi
case "${RN_APP_NAME}" in
  [A-Za-z]* ) : ;;
  * ) RN_APP_NAME="A${RN_APP_NAME}" ;;
esac

echo "React Native scaffold:"
echo "  Runtime: ${RUNTIME_CHOICE}"
echo "  Language: ${LANG_CHOICE}"
echo "  Package manager: ${PM_CHOICE}"
echo "  RN Version: ${RN_VERSION}"
echo "  RN App Name: ${RN_APP_NAME}"
echo ""

cd "$APP_DIR"

if [ "${RUNTIME_CHOICE}" = "expo" ]; then
  TEMPLATE_ARG="--template blank"
  [ "${LANG_CHOICE}" = "ts" ] && TEMPLATE_ARG="--template blank-typescript"
  echo "Creating Expo app..."
  npx --yes create-expo-app@latest . ${TEMPLATE_ARG}
else
  echo "Creating bare React Native app..."
  TMP_PARENT_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'appeus-rn')"
  
  # Prefer the community CLI to avoid deprecation warnings
  if ( cd "${TMP_PARENT_DIR}" && npx --yes @react-native-community/cli@latest init "${RN_APP_NAME}" --version "${RN_VERSION}" ); then
    echo "  Created with @react-native-community/cli"
  elif ( cd "${TMP_PARENT_DIR}" && npx --yes react-native@latest init "${RN_APP_NAME}" --version "${RN_VERSION}" ); then
    echo "  Created with react-native CLI (fallback)"
  else
    echo "Error: React Native init failed." >&2
    echo "Consider using APPEUS_RUNTIME=expo instead." >&2
    rm -rf "${TMP_PARENT_DIR}"
    exit 1
  fi
  
  # Move scaffold into app directory
  rsync -a "${TMP_PARENT_DIR}/${RN_APP_NAME}/" "${APP_DIR}/"
  rm -rf "${TMP_PARENT_DIR}"
  
  # Post-init TypeScript setup
  if [ "${LANG_CHOICE}" = "ts" ]; then
    echo "Adding TypeScript tooling..."
    case "${PM_CHOICE}" in
      yarn)
        yarn add -D typescript @react-native/typescript-config @types/react @types/react-native >/dev/null 2>&1 || true
        ;;
      npm)
        npm install -D typescript @react-native/typescript-config @types/react @types/react-native >/dev/null 2>&1 || true
        ;;
      pnpm)
        pnpm add -D typescript @react-native/typescript-config @types/react @types/react-native >/dev/null 2>&1 || true
        ;;
    esac
    
    if [ ! -f "${APP_DIR}/tsconfig.json" ]; then
      cat > "${APP_DIR}/tsconfig.json" <<'JSON'
{
  "extends": "@react-native/typescript-config/tsconfig.json",
  "compilerOptions": {
    "jsx": "react-jsx",
    "esModuleInterop": true
  }
}
JSON
    fi
  fi
fi

# Create src directory structure
mkdir -p "${APP_DIR}/src/screens"
mkdir -p "${APP_DIR}/src/navigation"
mkdir -p "${APP_DIR}/src/components"
mkdir -p "${APP_DIR}/src/data"
mkdir -p "${APP_DIR}/src/mock"

# Create global specs for this target
SPECS_DIR="$(dirname "$(dirname "$APP_DIR")")/design/specs/${APP_NAME}"
mkdir -p "${SPECS_DIR}/global"

# Write toolchain spec
cat > "${SPECS_DIR}/global/toolchain.md" <<EOF
# Toolchain Spec

language: ${LANG_CHOICE}
runtime: ${RUNTIME_CHOICE}
packageManager: ${PM_CHOICE}
navigation: react-navigation
state: zustand
http: fetch

notes:
- Adjust as needed; regenerate to apply.
EOF

# Copy UI and dependencies templates if missing
APPEUS_DIR="$(dirname "$(dirname "$(dirname "$0")")")"
if [ ! -f "${SPECS_DIR}/global/ui.md" ]; then
  cp "${APPEUS_DIR}/templates/specs/global/ui.md" "${SPECS_DIR}/global/ui.md"
fi
if [ ! -f "${SPECS_DIR}/global/dependencies.md" ]; then
  cp "${APPEUS_DIR}/templates/specs/global/dependencies.md" "${SPECS_DIR}/global/dependencies.md"
fi

echo ""
echo "React Native scaffold complete."
echo "  App location: ${APP_DIR}"
echo "  Source: ${APP_DIR}/src/"
echo ""
echo "To run:"
echo "  cd apps/${APP_NAME}"
case "${PM_CHOICE}" in
  yarn) echo "  yarn install && yarn start" ;;
  npm) echo "  npm install && npm start" ;;
  pnpm) echo "  pnpm install && pnpm start" ;;
esac

