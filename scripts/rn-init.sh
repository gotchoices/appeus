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
APP_NAME="$(basename "${PROJECT_DIR}")"
RAW_APP_NAME="${APPEUS_APP_NAME:-${APP_NAME}}"
RN_APP_NAME="$(printf "%s" "${RAW_APP_NAME}" | sed 's/[^A-Za-z0-9]//g')"
if [ -z "${RN_APP_NAME}" ]; then RN_APP_NAME="AppeusApp"; fi
case "${RN_APP_NAME}" in
  [A-Za-z]* ) : ;;
  * ) RN_APP_NAME="A${RN_APP_NAME}" ;;
esac

if [ ! -f "${ROOT_DIR}/package.json" ]; then
  if [ "${RUNTIME_CHOICE}" = "expo" ]; then
    TEMPLATE_ARG="--template blank"
    [ "${LANG_CHOICE}" = "ts" ] && TEMPLATE_ARG="--template blank-typescript"
    echo "Appeus: Scaffolding Expo app (${LANG_CHOICE}) ..."
    npx --yes create-expo-app@latest . ${TEMPLATE_ARG}
  else
    echo "Appeus: Scaffolding bare React Native app (${LANG_CHOICE}) ..."
    TEMPLATE_ARG=""
    [ "${LANG_CHOICE}" = "ts" ] && TEMPLATE_ARG="--template react-native-template-typescript@latest"
    TMP_PARENT_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t 'appeus-rn')"
    ( cd "${TMP_PARENT_DIR}" && npx --yes react-native@latest init "${RN_APP_NAME}" ${TEMPLATE_ARG} ) || \
    ( echo "Appeus: primary RN init failed; retrying with @react-native-community/cli ..." && cd "${TMP_PARENT_DIR}" && npx --yes @react-native-community/cli@latest init "${RN_APP_NAME}" ${TEMPLATE_ARG} ) || \
    ( echo "Appeus: React Native init failed. Consider rerunning with APPEUS_RUNTIME=expo. Aborting." >&2; exit 1 )
    rsync -a "${TMP_PARENT_DIR}/${RN_APP_NAME}/" "${ROOT_DIR}/"
    rm -rf "${TMP_PARENT_DIR}"
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


