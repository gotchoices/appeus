#!/usr/bin/env bash
set -euo pipefail

# Appeus v2.1: Add an app to the project.
#
# Usage:
#   ./appeus/scripts/add-app.sh --name <name> --framework <framework> [--refresh]
#
# Examples:
#   ./appeus/scripts/add-app.sh --name mobile --framework react-native
#   ./appeus/scripts/add-app.sh --name web --framework sveltekit
#   ./appeus/scripts/add-app.sh --name mobile --framework react-native --refresh
#
# Options:
#   --refresh   Idempotent mode: refresh symlinks and add missing templates
#               without re-running framework scaffold
#
# Supported frameworks:
#   - react-native (implemented)
#   - sveltekit (implemented)
#   - nativescript-svelte (implemented)
#
# This script:
#   - Creates per-target design folders (v2.1 canonical layout)
#   - Dispatches to framework-specific scaffold script

PROJECT_DIR="$(pwd)"
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPEUS_DIR="$(cd -P "${SCRIPT_DIR}/.." && pwd)"

# Defaults
APP_NAME=""
FRAMEWORK=""
REFRESH_MODE=0
KEEP_APP_GIT="${APPEUS_APP_GIT:-0}" # 1 = keep per-app git repo (if scaffold creates one)

strip_nested_git_repo() {
  local app_path="$1"
  if [ "${KEEP_APP_GIT}" = "1" ]; then
    return 0
  fi
  # Many scaffolders auto-init a git repo. Appeus projects are intended to have a single repo at the project root,
  # so remove nested `.git` by default to avoid submodule/subrepo surprises.
  if [ -e "${app_path}/.git" ]; then
    rm -rf "${app_path}/.git"
    echo "  Removed nested git repo: ${app_path}/.git (set APPEUS_APP_GIT=1 to keep)"
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) APP_NAME="$2"; shift 2 ;;
    --framework) FRAMEWORK="$2"; shift 2 ;;
    --refresh) REFRESH_MODE=1; shift ;;
    -h|--help)
      echo "Usage: $0 --name <name> --framework <framework> [--refresh]"
      echo ""
      echo "Options:"
      echo "  --name       App name (e.g., mobile, web)"
      echo "  --framework  Framework to use"
      echo "  --refresh    Idempotent mode: refresh symlinks, add missing templates,"
      echo "               skip framework scaffold if app already exists"
      echo ""
      echo "Supported frameworks:"
      echo "  react-native         React Native (Expo or bare)"
      echo "  sveltekit            SvelteKit web framework"
      echo "  nativescript-svelte  NativeScript with Svelte"
      echo ""
      echo "Planned (stubs exist):"
      echo "  nativescript-vue     NativeScript with Vue"
      echo "  nuxt                 Nuxt (Vue web framework)"
      echo "  nextjs               Next.js (React web framework)"
      echo "  tauri                Tauri (desktop apps)"
      echo "  capacitor            Capacitor (hybrid mobile)"
      echo ""
      echo "Environment variables (framework-specific):"
      echo "  APPEUS_LANG=ts|js         Language (default: ts)"
      echo "  APPEUS_PM=yarn|npm|pnpm   Package manager (default: yarn)"
      echo "  APPEUS_RUNTIME=expo|bare  RN runtime (default: bare, RN only)"
      echo "  APPEUS_RN_VERSION=X.Y.Z   RN version (default: 0.82.1, RN only)"
      echo "  APPEUS_APP_GIT=1          Keep per-app git repo if scaffold initializes one (default: 0 = remove)"
      echo ""
      echo "Examples:"
      echo "  $0 --name mobile --framework react-native"
      echo "  $0 --name mobile --framework react-native --refresh"
      echo "  APPEUS_RUNTIME=expo $0 --name mobile --framework react-native"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Use --help for usage information." >&2
      exit 1
      ;;
  esac
done

# Validate arguments
if [ -z "$APP_NAME" ]; then
  echo "Error: --name is required" >&2
  exit 1
fi

if [ -z "$FRAMEWORK" ]; then
  echo "Error: --framework is required" >&2
  exit 1
fi

# Validate framework
FRAMEWORK_SCRIPT="${SCRIPT_DIR}/frameworks/${FRAMEWORK}.sh"
if [ ! -f "$FRAMEWORK_SCRIPT" ]; then
  echo "Error: Unknown framework '$FRAMEWORK'" >&2
  echo "Supported: react-native, sveltekit, nativescript-svelte" >&2
  echo "Planned (stubs): nativescript-vue, nuxt, nextjs, tauri, capacitor" >&2
  exit 1
fi

# Check if app already exists
APP_EXISTS=0
if [ -d "${PROJECT_DIR}/apps/${APP_NAME}" ]; then
  APP_EXISTS=1
  if [ "$REFRESH_MODE" = "0" ]; then
    echo "Error: App '${APP_NAME}' already exists at apps/${APP_NAME}/" >&2
    echo "" >&2
    echo "To refresh symlinks and add missing templates without re-scaffolding:" >&2
    echo "  $0 --name ${APP_NAME} --framework ${FRAMEWORK} --refresh" >&2
    exit 1
  else
    echo "Refresh mode: App '${APP_NAME}' exists, will refresh symlinks and templates"
  fi
fi

echo "Appeus v2.1: Adding app '${APP_NAME}' with framework '${FRAMEWORK}'"
echo ""

# v2.1 canonical: we do not migrate a “flat” design layout.
# If you have an older Appeus project using design/specs/screens/, migrate it manually (see CHANGELOG).

# Create design folders for the new app
if [ "$REFRESH_MODE" = "1" ]; then
  echo "Refreshing design folders for '${APP_NAME}'..."
else
  echo "Creating design folders for '${APP_NAME}'..."
fi

mkdir -p "${PROJECT_DIR}/design/stories/${APP_NAME}"
mkdir -p "${PROJECT_DIR}/design/specs/${APP_NAME}/screens"
mkdir -p "${PROJECT_DIR}/design/specs/${APP_NAME}/components"
mkdir -p "${PROJECT_DIR}/design/specs/${APP_NAME}/global"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/screens"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/scenarios"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/images"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/meta"

# Seed per-target phase checklist if missing
if [ ! -f "${PROJECT_DIR}/design/specs/${APP_NAME}/STATUS.md" ]; then
  cp "${APPEUS_DIR}/templates/specs/target-status.md" "${PROJECT_DIR}/design/specs/${APP_NAME}/STATUS.md"
fi

# Create AGENTS.md symlinks for the new target
ln -snf "../../../appeus/agent-rules/stories.md" "${PROJECT_DIR}/design/stories/${APP_NAME}/AGENTS.md"
ln -snf "../../../appeus/agent-rules/specs.md" "${PROJECT_DIR}/design/specs/${APP_NAME}/AGENTS.md"
ln -snf "../../../appeus/agent-rules/consolidations.md" "${PROJECT_DIR}/design/generated/${APP_NAME}/AGENTS.md"
ln -snf "../../../../appeus/agent-rules/scenarios.md" "${PROJECT_DIR}/design/generated/${APP_NAME}/scenarios/AGENTS.md"

# Link human guide for per-target specs folder
ln -snf "../../../appeus/user-guides/target-spec.md" "${PROJECT_DIR}/design/specs/${APP_NAME}/README.md"

# Copy templates
if [ ! -f "${PROJECT_DIR}/design/specs/${APP_NAME}/screens/index.md" ]; then
  cp "${APPEUS_DIR}/templates/specs/screens/index.md" "${PROJECT_DIR}/design/specs/${APP_NAME}/screens/index.md"
fi

if [ ! -f "${PROJECT_DIR}/design/specs/${APP_NAME}/components/index.md" ]; then
  mkdir -p "${PROJECT_DIR}/design/specs/${APP_NAME}/components"
  cp "${APPEUS_DIR}/templates/specs/components/index.md" "${PROJECT_DIR}/design/specs/${APP_NAME}/components/index.md"
fi

if [ ! -f "${PROJECT_DIR}/design/specs/${APP_NAME}/navigation.md" ]; then
  cp "${APPEUS_DIR}/templates/specs/navigation.md" "${PROJECT_DIR}/design/specs/${APP_NAME}/navigation.md"
fi

# Seed starter story if none exist for this target
STORY_COUNT=$(find "${PROJECT_DIR}/design/stories/${APP_NAME}" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$STORY_COUNT" = "0" ]; then
  cp "${APPEUS_DIR}/templates/stories/story-template.md" "${PROJECT_DIR}/design/stories/${APP_NAME}/01-first-story.md"
  echo "  Created starter story: design/stories/${APP_NAME}/01-first-story.md"
fi

# Seed images index
if [ ! -f "${PROJECT_DIR}/design/generated/${APP_NAME}/images/index.md" ]; then
  cp "${APPEUS_DIR}/templates/generated/images-index.md" "${PROJECT_DIR}/design/generated/${APP_NAME}/images/index.md"
fi

if [ "$REFRESH_MODE" = "1" ]; then
  echo "  Refreshed design folders for ${APP_NAME}"
else
  echo "  Created design folders for ${APP_NAME}"
fi
echo ""

# Create app directory
mkdir -p "${PROJECT_DIR}/apps/${APP_NAME}"

# Link AGENTS.md in the app folder
ln -snf "../../appeus/agent-rules/src.md" "${PROJECT_DIR}/apps/${APP_NAME}/AGENTS.md"

# Update root AGENTS.md to point to project.md (post-discovery)
ln -snf "appeus/agent-rules/project.md" "${PROJECT_DIR}/AGENTS.md"

# Dispatch to framework-specific script (skip if refresh mode and app exists)
if [ "$REFRESH_MODE" = "1" ] && [ "$APP_EXISTS" = "1" ]; then
  echo "Refresh mode: Skipping framework scaffold (app already exists)"
  # Enforce default: no nested repos unless explicitly requested.
  strip_nested_git_repo "${PROJECT_DIR}/apps/${APP_NAME}"
  echo ""
  echo "=== App '${APP_NAME}' refreshed successfully ==="
  echo ""
  echo "Refreshed:"
  echo "  - Symlinks in design/ and apps/${APP_NAME}/"
  echo "  - Added any missing templates"
  echo ""
else
  echo "Dispatching to framework scaffold: ${FRAMEWORK}"
  echo ""

  if bash "$FRAMEWORK_SCRIPT" "${PROJECT_DIR}/apps/${APP_NAME}" "$APP_NAME"; then
    strip_nested_git_repo "${PROJECT_DIR}/apps/${APP_NAME}"
    echo ""
    echo "=== App '${APP_NAME}' created successfully ==="
    echo ""
    echo "Next steps:"
    echo "  1. Edit design/stories/${APP_NAME}/01-first-story.md"
    echo "  2. Ask the agent to derive specs and generate code"
    echo "  3. Run the app from apps/${APP_NAME}/"
    echo ""
  else
    echo ""
    echo "Error: Framework scaffold failed" >&2
    echo ""
    echo "The following were created before the failure:"
    echo "  - design/stories/${APP_NAME}/"
    echo "  - design/specs/${APP_NAME}/"
    echo "  - design/generated/${APP_NAME}/"
    echo "  - apps/${APP_NAME}/"
    echo ""
    echo "To clean up, run:"
    echo "  rm -rf design/stories/${APP_NAME} design/specs/${APP_NAME} design/generated/${APP_NAME} apps/${APP_NAME}"
    echo ""
    exit 1
  fi
fi

