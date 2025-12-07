#!/usr/bin/env bash
set -euo pipefail

# SvelteKit framework scaffold for Appeus v2
# Called by add-app.sh, not directly.
#
# Arguments:
#   $1 - App directory (e.g., /path/to/project/apps/web)
#   $2 - App name (e.g., web)
#
# Environment variables (optional):
#   APPEUS_LANG - ts | js (default: ts)
#   APPEUS_PM   - npm | yarn | pnpm (default: npm)

APP_DIR="$1"
APP_NAME="$2"

LANG_CHOICE="${APPEUS_LANG:-ts}"
PM_CHOICE="${APPEUS_PM:-npm}"

echo "SvelteKit scaffold:"
echo "  Language: ${LANG_CHOICE}"
echo "  Package manager: ${PM_CHOICE}"
echo ""

cd "$APP_DIR"

# Create SvelteKit app
# Using create-svelte with non-interactive options
echo "Creating SvelteKit app..."

# Determine template based on language
if [ "${LANG_CHOICE}" = "ts" ]; then
  TEMPLATE="skeleton"
  TYPES="typescript"
else
  TEMPLATE="skeleton"
  TYPES="null"
fi

# Use npx to run create-svelte
# Note: create-svelte is interactive, so we use a workaround
cat > "${APP_DIR}/package.json" <<JSON
{
  "name": "${APP_NAME}",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "dev": "vite dev",
    "build": "vite build",
    "preview": "vite preview",
    "check": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json",
    "check:watch": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json --watch"
  },
  "devDependencies": {
    "@sveltejs/adapter-auto": "^3.0.0",
    "@sveltejs/kit": "^2.0.0",
    "@sveltejs/vite-plugin-svelte": "^4.0.0",
    "svelte": "^5.0.0",
    "svelte-check": "^4.0.0",
    "typescript": "^5.0.0",
    "vite": "^6.0.0"
  },
  "type": "module"
}
JSON

# Create svelte.config.js
cat > "${APP_DIR}/svelte.config.js" <<'JS'
import adapter from '@sveltejs/adapter-auto';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
  preprocess: vitePreprocess(),
  kit: {
    adapter: adapter()
  }
};

export default config;
JS

# Create vite.config.ts
cat > "${APP_DIR}/vite.config.ts" <<'TS'
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
  plugins: [sveltekit()]
});
TS

# Create tsconfig.json
cat > "${APP_DIR}/tsconfig.json" <<'JSON'
{
  "extends": "./.svelte-kit/tsconfig.json",
  "compilerOptions": {
    "allowJs": true,
    "checkJs": true,
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "skipLibCheck": true,
    "sourceMap": true,
    "strict": true,
    "moduleResolution": "bundler"
  }
}
JSON

# Create directory structure
mkdir -p "${APP_DIR}/src/routes"
mkdir -p "${APP_DIR}/src/lib/components"
mkdir -p "${APP_DIR}/src/lib/data"
mkdir -p "${APP_DIR}/static"

# Create app.html
cat > "${APP_DIR}/src/app.html" <<'HTML'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%sveltekit.assets%/favicon.png" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    %sveltekit.head%
  </head>
  <body data-sveltekit-preload-data="hover">
    <div style="display: contents">%sveltekit.body%</div>
  </body>
</html>
HTML

# Create root layout
cat > "${APP_DIR}/src/routes/+layout.svelte" <<'SVELTE'
<script>
  import { page } from '$app/stores';
</script>

<nav>
  <a href="/">Home</a>
</nav>

<main>
  <slot />
</main>

<style>
  nav {
    padding: 1rem;
    border-bottom: 1px solid #eee;
  }
  nav a {
    margin-right: 1rem;
  }
  main {
    padding: 1rem;
    max-width: 1200px;
    margin: 0 auto;
  }
</style>
SVELTE

# Create home page
cat > "${APP_DIR}/src/routes/+page.svelte" <<'SVELTE'
<script lang="ts">
  // Home page
</script>

<h1>Welcome</h1>
<p>Your SvelteKit app is ready.</p>
<p>Edit <code>src/routes/+page.svelte</code> to get started.</p>
SVELTE

# Create a placeholder favicon
touch "${APP_DIR}/static/favicon.png"

# Create global specs for this target
SPECS_DIR="$(dirname "$(dirname "$APP_DIR")")/design/specs/${APP_NAME}"
mkdir -p "${SPECS_DIR}/global"

# Write toolchain spec
cat > "${SPECS_DIR}/global/toolchain.md" <<EOF
# Toolchain Spec

language: ${LANG_CHOICE}
packageManager: ${PM_CHOICE}
adapter: auto

notes:
- Adjust as needed; regenerate to apply.
EOF

# Copy UI template if missing (adapted for web)
if [ ! -f "${SPECS_DIR}/global/ui.md" ]; then
  cat > "${SPECS_DIR}/global/ui.md" <<'MD'
# UI Spec

theme: system                # system | light | dark

colors:
  # Light mode
  backgroundLight: "#ffffff"
  textPrimaryLight: "#111111"
  textSecondaryLight: "#555555"
  borderLight: "#dddddd"
  # Dark mode
  backgroundDark: "#0a0a0a"
  textPrimaryDark: "#eeeeee"
  textSecondaryDark: "#bbbbbb"
  borderDark: "#333333"

typography:
  fontFamily: "system-ui, -apple-system, sans-serif"
  title:
    size: 1.5rem
    weight: 600
  body:
    size: 1rem
    weight: 400

notes:
- Adjust for your design system.
MD
fi

echo ""
echo "SvelteKit scaffold complete."
echo "  App location: ${APP_DIR}"
echo "  Routes: ${APP_DIR}/src/routes/"
echo "  Components: ${APP_DIR}/src/lib/components/"
echo ""
echo "To run:"
echo "  cd apps/${APP_NAME}"
case "${PM_CHOICE}" in
  npm) echo "  npm install && npm run dev" ;;
  yarn) echo "  yarn install && yarn dev" ;;
  pnpm) echo "  pnpm install && pnpm dev" ;;
esac

