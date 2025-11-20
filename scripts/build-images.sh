#!/usr/bin/env bash
set -euo pipefail

# build-images.sh
# Capture screenshots only for stale/missing scenario images (Android).
# Requires a running emulator or the ability to start one.
#
# Usage:
#   appeus/scripts/build-images.sh [--reuse] [--window] [--force]
# Env overrides:
#   APPEUS_ANDROID_AVD   (default: Medium_Phone_API_34)
#   APPEUS_APP_ID        (default: org.sereus.chat)
#   APPEUS_SCREEN_DELAY  (default: 3)
#

REUSE_FLAG=""
WINDOW_FLAG=""
FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --reuse) REUSE_FLAG="--reuse"; shift ;;
    --window) WINDOW_FLAG="--window"; shift ;;
    --force) FORCE=1; shift ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

root="$(pwd)"
helper="${root}/appeus/scripts/android-screenshot.sh"
outdir="${root}/design/generated/images"
mkdir -p "${outdir}"

# Map: deeplink | output | deps (comma-separated)
tasks=(
  # Home / ConnectionsList
  "chat://connections?variant=empty&locale=en|${outdir}/connections-list-empty.png|design/generated/scenarios/connections-list-empty.md,src/screens/ConnectionsList.tsx,design/specs/navigation.md"
  "chat://connections?variant=happy&locale=en|${outdir}/connections-list-happy.png|design/generated/scenarios/connections-list-happy.md,src/screens/ConnectionsList.tsx,design/specs/navigation.md"
  # Invite
  "chat://invite?variant=happy&locale=en|${outdir}/invitation-generator.png|design/generated/scenarios/invitation-generator.md,src/screens/InvitationGenerator.tsx,design/specs/navigation.md"
  "chat://invite/demo-1234?variant=happy&locale=en|${outdir}/invitation-acceptance.png|design/generated/scenarios/invitation-acceptance.md,src/screens/InvitationAcceptance.tsx,design/specs/navigation.md"
  # Chat
  "chat://chat/t-susan?variant=empty&locale=en|${outdir}/chat-interface-empty.png|design/generated/scenarios/chat-interface-empty.md,src/screens/ChatInterface.tsx,design/specs/navigation.md"
  "chat://chat/t-susan?variant=happy&locale=en|${outdir}/chat-interface-happy.png|design/generated/scenarios/chat-interface-happy.md,src/screens/ChatInterface.tsx,design/specs/navigation.md"
  # Search
  "chat://search?locale=en|${outdir}/search-interface.png|design/generated/scenarios/search-interface.md,src/screens/SearchInterface.tsx,design/specs/navigation.md"
  # QR
  "chat://scan?locale=en|${outdir}/qr-scanner.png|design/generated/scenarios/qr-scanner.md,src/screens/QrScanner.tsx,design/specs/navigation.md"
  # Profile
  "chat://profile?locale=en|${outdir}/profile-setup.png|design/generated/scenarios/profile-setup.md,src/screens/ProfileSetup.tsx,design/specs/navigation.md"
)

is_stale() {
  local output="$1"; shift
  # If output missing, it's stale
  [[ ! -f "$output" ]] && return 0
  local out_mtime
  out_mtime="$(stat -f %m "$output" 2>/dev/null || stat -c %Y "$output" 2>/dev/null || echo 0)"
  local dep
  for dep in "$@"; do
    [[ -f "$dep" ]] || continue
    local dep_mtime
    dep_mtime="$(stat -f %m "$dep" 2>/dev/null || stat -c %Y "$dep" 2>/dev/null || echo 0)"
    if [[ "$dep_mtime" -gt "$out_mtime" ]]; then
      return 0
    fi
  done
  return 1
}

captured=0
skipped=0
for t in "${tasks[@]}"; do
  IFS='|' read -r deeplink output deps <<< "$t"
  IFS=',' read -r -a dep_array <<< "$deps"
  if [[ "$FORCE" -eq 0 ]]; then
    if ! is_stale "$output" "${dep_array[@]}"; then
      echo "fresh  ${output}"
      skipped=$((skipped+1))
      continue
    fi
  fi
  echo "capture ${deeplink} -> ${output}"
  "${helper}" --deeplink "${deeplink}" --output "${output}" ${REUSE_FLAG} ${WINDOW_FLAG}
  captured=$((captured+1))
done

echo "Done. Captured: ${captured}, Skipped (fresh): ${skipped}. Images at ${outdir}"


