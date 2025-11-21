#!/usr/bin/env bash
set -euo pipefail

# Initialize a React Native app per environment overrides.
# Env: APPEUS_RUNTIME=expo|bare (default bare), APPEUS_LANG=ts|js (default ts),
#      APPEUS_PM=yarn|npm|pnpm (default yarn), APPEUS_GIT=1|0 (default 1),
#      APPEUS_APP_NAME=<ReactNativeAppName> (default sanitized folder name)

PROJECT_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_APPEUS_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

ROOT_DIR="${PROJECT_DIR}"

LANG_CHOICE="${APPEUS_LANG:-ts}"
PM_CHOICE="${APPEUS_PM:-yarn}"
RUNTIME_CHOICE="${APPEUS_RUNTIME:-bare}"
RN_VERSION="${APPEUS_RN_VERSION:-0.82.1}"
FORCE_REINIT="${APPEUS_FORCE_RN_INIT:-0}"
APP_NAME="$(basename "${PROJECT_DIR}")"
RAW_APP_NAME="${APPEUS_APP_NAME:-${APP_NAME}}"
RN_APP_NAME="$(printf "%s" "${RAW_APP_NAME}" | sed 's/[^A-Za-z0-9]//g')"
if [ -z "${RN_APP_NAME}" ]; then RN_APP_NAME="AppeusApp"; fi
case "${RN_APP_NAME}" in
  [A-Za-z]* ) : ;;
  * ) RN_APP_NAME="A${RN_APP_NAME}" ;;
esac

if [ "${FORCE_REINIT}" = "1" ] || [ ! -f "${ROOT_DIR}/package.json" ]; then
  if [ "${RUNTIME_CHOICE}" = "expo" ]; then
    TEMPLATE_ARG="--template blank"
    [ "${LANG_CHOICE}" = "ts" ] && TEMPLATE_ARG="--template blank-typescript"
    echo "Appeus: Scaffolding Expo app (${LANG_CHOICE}) ..."
    npx --yes create-expo-app@latest . ${TEMPLATE_ARG}
  else
    echo "Appeus: Scaffolding bare React Native app ${RN_VERSION} (${LANG_CHOICE}) ..."
    TMP_PARENT_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'appeus-rn')"
    # Prefer the community CLI to avoid deprecation warnings; fallback to the RN CLI if needed
    ( cd "${TMP_PARENT_DIR}" && npx --yes @react-native-community/cli@latest init "${RN_APP_NAME}" --version "${RN_VERSION}" ) || \
    ( echo "Appeus: primary init via @react-native-community/cli failed; retrying with react-native CLI ..." && cd "${TMP_PARENT_DIR}" && npx --yes react-native@latest init "${RN_APP_NAME}" --version "${RN_VERSION}" ) || \
    ( echo "Appeus: React Native init failed. Consider rerunning with APPEUS_RUNTIME=expo. Aborting." >&2; exit 1 )
    rsync -a "${TMP_PARENT_DIR}/${RN_APP_NAME}/" "${ROOT_DIR}/"
    rm -rf "${TMP_PARENT_DIR}"
    # Post-init TypeScript setup (avoid outdated TS template pinning RN)
    if [ "${LANG_CHOICE}" = "ts" ]; then
      echo "Appeus: Adding TypeScript tooling (post-init)..."
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
      if [ ! -f "${ROOT_DIR}/tsconfig.json" ]; then
        cat > "${ROOT_DIR}/tsconfig.json" <<'JSON'
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
fi

# Initialize git repo unless disabled
if [ "${APPEUS_GIT:-1}" != "0" ]; then
  if [ ! -d "${ROOT_DIR}/.git" ]; then
    git init >/dev/null 2>&1 || true
  fi
fi

echo "Appeus: rn-init completed."
echo "Next: run ${SCRIPT_APPEUS_DIR}/scripts/setup-appeus.sh"


