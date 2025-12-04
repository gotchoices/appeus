#!/usr/bin/env bash
set -euo pipefail

# build-images.sh
# Capture screenshots for stale/missing scenario images (Android).
# Reads configuration from design/generated/images/index.md frontmatter.
# Requires a running emulator or the ability to start one.
#
# Usage:
#   appeus/scripts/build-images.sh [--reuse] [--window] [--force]
#
# Env overrides:
#   APPEUS_ANDROID_AVD   (default: Medium_Phone_API_34)
#   APPEUS_SCREEN_DELAY  (default: 3)
#
# The appId and scheme are read from images/index.md frontmatter.

REUSE_FLAG=""
WINDOW_FLAG=""
FORCE=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --reuse) REUSE_FLAG="--reuse"; shift ;;
    --window) WINDOW_FLAG="--window"; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help)
      echo "Usage: $0 [--reuse] [--window] [--force]"
      echo "  --reuse   Reuse running emulator (fail if none)"
      echo "  --window  Show emulator window (not headless)"
      echo "  --force   Recapture all screenshots, even if fresh"
      exit 0
      ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
  esac
done

root="$(pwd)"
helper="${root}/appeus/scripts/android-screenshot.sh"
outdir="${root}/design/generated/images"
index_file="${outdir}/index.md"

# Check for required tools
if ! command -v yq &>/dev/null; then
  echo "Error: yq is required to parse YAML frontmatter."
  echo "Install with: brew install yq  (macOS) or see https://github.com/mikefarah/yq"
  exit 1
fi

# Check for index.md
if [[ ! -f "$index_file" ]]; then
  echo "Error: No images/index.md found at $index_file"
  echo "Run setup-appeus.sh or create one from the template."
  exit 1
fi

mkdir -p "${outdir}"

# Extract frontmatter (between first --- and second ---)
extract_frontmatter() {
  sed -n '/^---$/,/^---$/p' "$1" | sed '1d;$d'
}

frontmatter=$(extract_frontmatter "$index_file")

# Read app config from frontmatter
APP_ID=$(echo "$frontmatter" | yq -r '.appId // "com.example.app"')
SCHEME=$(echo "$frontmatter" | yq -r '.scheme // "app"')

# Read screenshots array
screenshot_count=$(echo "$frontmatter" | yq -r '.screenshots | length')

if [[ "$screenshot_count" == "0" ]] || [[ "$screenshot_count" == "null" ]]; then
  echo "No screenshots defined in $index_file frontmatter."
  echo "Add entries under 'screenshots:' in the YAML frontmatter."
  exit 0
fi

echo "App ID: $APP_ID"
echo "Scheme: $SCHEME"
echo "Screenshots defined: $screenshot_count"
echo ""

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

for i in $(seq 0 $((screenshot_count - 1))); do
  route=$(echo "$frontmatter" | yq -r ".screenshots[$i].route")
  variant=$(echo "$frontmatter" | yq -r ".screenshots[$i].variant // \"\"")
  locale=$(echo "$frontmatter" | yq -r ".screenshots[$i].locale // \"en\"")
  file=$(echo "$frontmatter" | yq -r ".screenshots[$i].file")
  
  # Build deeplink URL
  deeplink="${SCHEME}://screen/${route}"
  params=""
  if [[ -n "$variant" && "$variant" != "null" ]]; then
    params="variant=${variant}"
  fi
  if [[ -n "$locale" && "$locale" != "null" && "$locale" != "en" ]]; then
    if [[ -n "$params" ]]; then
      params="${params}&locale=${locale}"
    else
      params="locale=${locale}"
    fi
  fi
  # Add any extra params from frontmatter
  extra_params=$(echo "$frontmatter" | yq -r ".screenshots[$i].params // {} | to_entries | map(\"\(.key)=\(.value)\") | join(\"&\")")
  if [[ -n "$extra_params" && "$extra_params" != "" ]]; then
    if [[ -n "$params" ]]; then
      params="${params}&${extra_params}"
    else
      params="$extra_params"
    fi
  fi
  if [[ -n "$params" ]]; then
    deeplink="${deeplink}?${params}"
  fi
  
  output="${outdir}/${file}"
  
  # Read deps array
  deps_json=$(echo "$frontmatter" | yq -r ".screenshots[$i].deps // []")
  deps_count=$(echo "$deps_json" | yq -r 'length')
  dep_array=()
  for j in $(seq 0 $((deps_count - 1))); do
    dep=$(echo "$deps_json" | yq -r ".[$j]")
    dep_array+=("${root}/${dep}")
  done
  # Always include the screen source as a dep if it exists
  screen_file="${root}/src/screens/${route}.tsx"
  if [[ -f "$screen_file" ]]; then
    dep_array+=("$screen_file")
  fi
  
  if [[ "$FORCE" -eq 0 ]]; then
    if ! is_stale "$output" "${dep_array[@]}"; then
      echo "fresh  ${file}"
      skipped=$((skipped+1))
      continue
    fi
  fi
  
  echo "capture ${deeplink} -> ${file}"
  "${helper}" --deeplink "${deeplink}" --output "${output}" --app-id "${APP_ID}" ${REUSE_FLAG} ${WINDOW_FLAG}
  captured=$((captured+1))
done

echo ""
echo "Done. Captured: ${captured}, Skipped (fresh): ${skipped}. Images at ${outdir}"
