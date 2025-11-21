# Quickstart

This quickstart helps you spin up the agent-guided scaffold so your stories become a running React Native app as you design it.

Prerequisites
- Node.js LTS and Yarn (or npm)
- Expo tooling (CLI or Dev Client) and an iOS/Android simulator (or device)
- A Git repo for your app (recommended)

Defaults and choices (you can override via env vars)
- Runtime: bare (set APPEUS_RUNTIME=expo for Expo)
- Language: ts (set APPEUS_LANG=js for JavaScript)
- Package manager: yarn (set APPEUS_PM=npm or pnpm)
- App name: sanitized folder name (set APPEUS_APP_NAME=YourAppName to override)
- Git init: on (set APPEUS_GIT=0 to skip)

1) Initialize React Native app
- Create and enter your app folder:
  - `mkdir <your-new-app-name> && cd <your-new-app-name>`
- Optionally set overrides (see choices above)
- Run RN init (choose one):
  - Absolute path: `/absolute/path/to/appeus/scripts/rn-init.sh`
  - Relative path (from your new app folder): `../relative/path/to/appeus/scripts/rn-init.sh`
- Example:
  ```bash
  APPEUS_RUNTIME=expo APPEUS_LANG=ts APPEUS_PM=yarn APPEUS_GIT=1 APPEUS_APP_NAME=ChatApp /absolute/path/to/appeus/scripts/rn-init.sh
  ```

2) Set up Appeus scaffold (idempotent)
- Run setup (absolute or relative path):
  - `/absolute/path/to/appeus/scripts/setup-appeus.sh`
  - `../relative/path/to/appeus/scripts/setup-appeus.sh`
- Example:
  ```bash
  /absolute/path/to/appeus/scripts/setup-appeus.sh
  ```
- The setup uses the current directory as the project root and will:
  - Create `design/` folders and AGENTS.md links
  - Seed `design/specs/navigation.md`, `design/specs/global/*`, and `design/specs/api/README.md`
  - Create a convenient `./regen` symlink to `appeus/scripts/regenerate.sh`

3) Write your first story
- Add `design/stories/01-first-story.md` with goal, sequence, acceptance, variants

4) Derive consolidations and specs
- Ask the agent to create `design/generated/screens/<id>.md` and `design/specs/screens/<id>.md` as needed
- Update `design/specs/navigation.md` with sitemap and deep links
- Define API procedures in `design/specs/api/*.md` (agent can seed from the template)

5) Generate RN code (on request)
- Ask the agent to “generate code” for the next slice. It will create/update `src/screens/*` and `src/navigation/*`, and keep internal staleness tracking up to date.

6) Scenario images
- Ask the agent to “generate scenarios” (or “refresh scenarios”). It will capture screenshots for any stale/missing targets and update the narrative Markdown files. If you prefer to do it yourself later, see Preview/Publish below.

7) Preview scenarios locally (appgen-style)
- `./appeus/scripts/preview-scenarios.sh --port 8080`
- Opens `design/generated/scenarios/index.md` rendered via markserv; images appear inline and are clickable deep links

8) Publish scenarios (static HTML)
- `./appeus/scripts/publish-scenarios.sh --dest user@host:/var/www/your-site/path`
- Generates `design/generated/site/` with `scenarios/*.html` and `images/*.png` and rsyncs to the destination

9) Run and iterate
- Launch the app (Expo or bare RN). Use scenario pages to deep-link into the app.
- Edit stories/specs; ask the agent to regenerate code and refresh scenarios. The agent will handle staleness checks and bookkeeping for you.

There are AGENTS.md files in the various folders that should help your AI agent guide you through the process of building your app.  Ask questions about what you need to do next.

