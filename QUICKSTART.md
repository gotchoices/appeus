# Quickstart

This guide walks you through creating a new project with Appeus v2.

## Prerequisites

- Node.js LTS
- Git
- For mobile apps: Expo CLI or React Native CLI, iOS/Android simulator
- For web apps: Node.js (framework-specific tooling installed by add-app)

## Step 1: Initialize Project

Create your project folder and run init:

```bash
mkdir myproject && cd myproject
/path/to/appeus/scripts/init-project.sh
```

This creates:
- `AGENTS.md` — Bootstrap rules for the agent
- `appeus` symlink — Points to your appeus installation
- `design/specs/project.md` — Decision document template
- `.gitignore` — Ignores appeus symlinks

## Step 2: Discovery Phase

Open the project in your IDE with an AI agent. The agent will guide you through completing `design/specs/project.md`:

- **Purpose** — What problem does this project solve?
- **Platforms** — Mobile (iOS/Android)? Web? Both?
- **Toolchain** — React Native, SvelteKit, etc.
- **Data strategy** — Local-first, cloud sync, backend API?

Take your time here. These decisions shape the project structure.

## Step 3: Add Your First App

Once decisions are documented, add an app scaffold:

```bash
# For React Native mobile app
./appeus/scripts/add-app.sh --name mobile --framework react-native

# For SvelteKit web app
./appeus/scripts/add-app.sh --name web --framework sveltekit
```

This creates:
- `apps/<name>/` — Framework scaffold with AGENTS.md
- `design/stories/<name>/` — Folder for user stories (per-target)
- `design/specs/<name>/screens/` — Folder for screen specs (per-target)
- `design/specs/<name>/navigation.md` — Navigation structure (per-target)

## Step 4: Write Stories

Create your first story in `design/stories/<target>/`:

```markdown
# 01-first-feature.md

## Goal
As a user, I want to see a list of items so that I can browse available options.

## Sequence
1. User opens the app
2. App displays a list of items with name and description
3. User taps an item to see details

## Acceptance
- List shows at least item name and description
- Tapping navigates to detail screen
- Empty state shown when no items exist

## Variants
- happy: Several items displayed
- empty: No items, empty state shown
- error: Failed to load, error message shown
```

## Step 5: Derive Schema and Specs

Ask the agent to:
1. Read your stories and propose a data schema
2. Create screen consolidations in `design/generated/<target>/screens/`
3. Draft screen specs in `design/specs/<target>/screens/`
4. Update `design/specs/<target>/navigation.md` with routes

Review and refine the specs. Your specs take precedence over AI consolidations.

## Step 6: Generate Code

Ask the agent to generate code for the next vertical slice:

```
"Generate code for the ItemList screen"
```

The agent will:
1. Check staleness (`check-stale.sh`)
2. Refresh consolidations if needed
3. Generate screen code in `apps/<name>/src/`
4. Update navigation
5. Generate mock data in `mock/data/`

## Step 7: Run and Test

For React Native:
```bash
cd apps/mobile
yarn install
yarn start
```

For SvelteKit:
```bash
cd apps/web
npm install
npm run dev
```

Use deep links to test specific screens with mock variants.

## Step 8: Iterate

- Edit stories or specs
- Ask agent to regenerate affected screens
- For mobile: Generate scenarios (screenshots) for stakeholder review
- Commit working slices regularly

## Adding More Apps Later

To add a second app (e.g., web after mobile):

```bash
./appeus/scripts/add-app.sh --name web --framework sveltekit
```

Appeus v2.1 uses a single canonical per-target layout; targets always live under `apps/<name>/` and design artifacts are per-target under `design/*/<name>/`.

## Environment Variables

For React Native apps, you can customize the scaffold:

| Variable | Default | Options |
|----------|---------|---------|
| `APPEUS_RUNTIME` | `bare` | `bare`, `expo` |
| `APPEUS_LANG` | `ts` | `ts`, `js` |
| `APPEUS_PM` | `yarn` | `yarn`, `npm`, `pnpm` |
| `APPEUS_RN_VERSION` | `0.82.1` | Any RN version |
| `APPEUS_GIT` | `1` | `1` (init git), `0` (skip) |

## Re-running Setup

Init and add-app are idempotent:
- Symlinks are refreshed
- New folders/templates are added if missing
- Existing user files are never overwritten

Re-run after updating appeus to pick up new features.

## Next Steps

- Read `reference/scenarios.md` for screenshot workflow
- See `docs/DESIGN.md` for architecture details
- Check `docs/STATUS.md` for what's implemented

The AGENTS.md files throughout the project guide your AI agent. When in doubt, ask the agent "What should I do next?"
