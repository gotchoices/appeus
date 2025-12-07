#!/usr/bin/env bash
set -euo pipefail

# Appeus v2: Add an app to the project.
#
# Usage:
#   ./appeus/scripts/add-app.sh --name <name> --framework <framework>
#
# Examples:
#   ./appeus/scripts/add-app.sh --name mobile --framework react-native
#   ./appeus/scripts/add-app.sh --name web --framework sveltekit
#
# Supported frameworks:
#   - react-native (implemented)
#   - sveltekit (implemented)
#   - nativescript-vue (stub)
#   - nativescript-svelte (stub)
#
# This script:
#   - Detects single-app vs multi-app mode
#   - Migrates to multi-app structure if adding a second app
#   - Creates per-target design folders
#   - Dispatches to framework-specific scaffold script

PROJECT_DIR="$(pwd)"
SCRIPT_DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APPEUS_DIR="$(cd -P "${SCRIPT_DIR}/.." && pwd)"

# Defaults
APP_NAME=""
FRAMEWORK=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) APP_NAME="$2"; shift 2 ;;
    --framework) FRAMEWORK="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --name <name> --framework <framework>"
      echo ""
      echo "Options:"
      echo "  --name       App name (e.g., mobile, web)"
      echo "  --framework  Framework to use"
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
      echo ""
      echo "Examples:"
      echo "  $0 --name mobile --framework react-native"
      echo "  APPEUS_RUNTIME=expo $0 --name mobile --framework react-native"
      echo "  APPEUS_PM=pnpm $0 --name web --framework sveltekit"
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
if [ -d "${PROJECT_DIR}/apps/${APP_NAME}" ]; then
  echo "Error: App '${APP_NAME}' already exists at apps/${APP_NAME}/" >&2
  exit 1
fi

echo "Appeus v2: Adding app '${APP_NAME}' with framework '${FRAMEWORK}'"
echo ""

# Detect current mode
is_single_app_mode() {
  # Single-app mode if specs/screens exists (flat) and no target subdirs
  if [ -d "${PROJECT_DIR}/design/specs/screens" ]; then
    # Check if there are target subdirs in specs
    local target_count
    target_count=$(find "${PROJECT_DIR}/design/specs" -mindepth 1 -maxdepth 1 -type d ! -name "screens" ! -name "schema" ! -name "api" ! -name "global" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$target_count" = "0" ]; then
      return 0  # single-app mode
    fi
  fi
  return 1  # multi-app mode or fresh
}

count_existing_apps() {
  if [ -d "${PROJECT_DIR}/apps" ]; then
    find "${PROJECT_DIR}/apps" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' '
  else
    echo "0"
  fi
}

# Get existing app name (for migration)
get_existing_app_name() {
  if [ -d "${PROJECT_DIR}/apps" ]; then
    find "${PROJECT_DIR}/apps" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | head -1
  fi
}

migrate_to_multi_app() {
  local existing_name="$1"
  echo "Migrating from single-app to multi-app structure..."
  echo "  Existing app will be placed under: ${existing_name}"
  echo ""
  
  # Migrate stories
  if [ -d "${PROJECT_DIR}/design/stories" ]; then
    mkdir -p "${PROJECT_DIR}/design/stories/${existing_name}"
    # Move story files (not AGENTS.md or README.md)
    find "${PROJECT_DIR}/design/stories" -maxdepth 1 -type f -name "*.md" ! -name "AGENTS.md" ! -name "README.md" -exec mv {} "${PROJECT_DIR}/design/stories/${existing_name}/" \; 2>/dev/null || true
    echo "  Moved stories to design/stories/${existing_name}/"
  fi
  
  # Migrate specs/screens
  if [ -d "${PROJECT_DIR}/design/specs/screens" ]; then
    mkdir -p "${PROJECT_DIR}/design/specs/${existing_name}"
    mv "${PROJECT_DIR}/design/specs/screens" "${PROJECT_DIR}/design/specs/${existing_name}/screens"
    echo "  Moved specs/screens to design/specs/${existing_name}/screens/"
  fi
  
  # Migrate specs/navigation.md
  if [ -f "${PROJECT_DIR}/design/specs/navigation.md" ]; then
    mkdir -p "${PROJECT_DIR}/design/specs/${existing_name}"
    mv "${PROJECT_DIR}/design/specs/navigation.md" "${PROJECT_DIR}/design/specs/${existing_name}/navigation.md"
    echo "  Moved navigation.md to design/specs/${existing_name}/"
  fi
  
  # Migrate specs/global
  if [ -d "${PROJECT_DIR}/design/specs/global" ]; then
    mkdir -p "${PROJECT_DIR}/design/specs/${existing_name}"
    mv "${PROJECT_DIR}/design/specs/global" "${PROJECT_DIR}/design/specs/${existing_name}/global"
    echo "  Moved specs/global to design/specs/${existing_name}/global/"
  fi
  
  # Migrate generated/screens
  if [ -d "${PROJECT_DIR}/design/generated/screens" ]; then
    mkdir -p "${PROJECT_DIR}/design/generated/${existing_name}"
    mv "${PROJECT_DIR}/design/generated/screens" "${PROJECT_DIR}/design/generated/${existing_name}/screens"
    echo "  Moved generated/screens to design/generated/${existing_name}/screens/"
  fi
  
  # Migrate generated/scenarios
  if [ -d "${PROJECT_DIR}/design/generated/scenarios" ]; then
    mkdir -p "${PROJECT_DIR}/design/generated/${existing_name}"
    mv "${PROJECT_DIR}/design/generated/scenarios" "${PROJECT_DIR}/design/generated/${existing_name}/scenarios"
    echo "  Moved generated/scenarios to design/generated/${existing_name}/scenarios/"
  fi
  
  # Migrate generated/images
  if [ -d "${PROJECT_DIR}/design/generated/images" ]; then
    mkdir -p "${PROJECT_DIR}/design/generated/${existing_name}"
    mv "${PROJECT_DIR}/design/generated/images" "${PROJECT_DIR}/design/generated/${existing_name}/images"
    echo "  Moved generated/images to design/generated/${existing_name}/images/"
  fi
  
  # Migrate status.json
  if [ -f "${PROJECT_DIR}/design/generated/status.json" ]; then
    mkdir -p "${PROJECT_DIR}/design/generated/${existing_name}"
    mv "${PROJECT_DIR}/design/generated/status.json" "${PROJECT_DIR}/design/generated/${existing_name}/status.json"
    echo "  Moved status.json to design/generated/${existing_name}/"
  fi
  
  echo ""
  echo "Migration complete."
  echo ""
}

# Check if we need to migrate
EXISTING_APPS=$(count_existing_apps)

if [ "$EXISTING_APPS" = "1" ] && is_single_app_mode; then
  EXISTING_NAME=$(get_existing_app_name)
  if [ -n "$EXISTING_NAME" ]; then
    echo "Detected single-app structure with existing app: ${EXISTING_NAME}"
    echo ""
    migrate_to_multi_app "$EXISTING_NAME"
  fi
fi

# Create design folders for the new app
echo "Creating design folders for '${APP_NAME}'..."

mkdir -p "${PROJECT_DIR}/design/stories/${APP_NAME}"
mkdir -p "${PROJECT_DIR}/design/specs/${APP_NAME}/screens"
mkdir -p "${PROJECT_DIR}/design/specs/${APP_NAME}/global"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/screens"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/scenarios"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/images"
mkdir -p "${PROJECT_DIR}/design/generated/${APP_NAME}/meta"

# Create AGENTS.md symlinks for the new target
ln -snf "../../../appeus/agent-rules/scenarios.md" "${PROJECT_DIR}/design/generated/${APP_NAME}/scenarios/AGENTS.md"

# Copy templates
if [ ! -f "${PROJECT_DIR}/design/specs/${APP_NAME}/screens/index.md" ]; then
  cp "${APPEUS_DIR}/templates/specs/screens/index.md" "${PROJECT_DIR}/design/specs/${APP_NAME}/screens/index.md"
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

echo "  Created design folders for ${APP_NAME}"
echo ""

# Create app directory
mkdir -p "${PROJECT_DIR}/apps/${APP_NAME}"

# Link AGENTS.md in the app folder
ln -snf "../../appeus/agent-rules/src.md" "${PROJECT_DIR}/apps/${APP_NAME}/AGENTS.md"

# Update root AGENTS.md to point to project.md (post-discovery)
ln -snf "appeus/agent-rules/project.md" "${PROJECT_DIR}/AGENTS.md"

echo "Dispatching to framework scaffold: ${FRAMEWORK}"
echo ""

# Dispatch to framework-specific script
if bash "$FRAMEWORK_SCRIPT" "${PROJECT_DIR}/apps/${APP_NAME}" "$APP_NAME"; then
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
  exit 1
fi

