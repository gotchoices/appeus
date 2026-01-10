# ARCHITECTURE

Appeus toolkit structure and project layout reference.

## Toolkit Structure

The appeus folder itself (this toolkit):

```
appeus/
├── docs/                    # For developing appeus itself (you are here)
│   ├── DESIGN.md            # Design intent and rationale
│   ├── GENERATION.md        # Generation strategy details
│   ├── STATUS.md            # Development roadmap and tracker
│   └── ARCHITECTURE.md      # This file
│
├── agent-rules/             # Brief rules for agents, linked via AGENTS.md
│   ├── bootstrap.md         # Discovery phase (pre-decision)
│   ├── project.md           # Post-discovery project rules
│   ├── schema.md            # Shared schema derivation
│   ├── stories.md           # Story authoring
│   ├── specs.md             # Spec authoring
│   ├── consolidations.md    # AI consolidations
│   ├── scenarios.md         # Scenario generation
│   ├── api.md               # API specs
│   └── src.md               # App source rules (links to framework references)
│
├── reference/               # Detailed docs, accessed via agent-rules links
│   ├── workflow.md          # Overall workflow
│   ├── generation.md        # Generation precedence and staleness
│   ├── codegen.md           # Code generation details
│   ├── mocking.md           # Mock data strategy
│   ├── scenarios.md         # Screenshot and scenario workflow
│   ├── spec-schema.md       # Spec file format
│   ├── *-agent-workflow.md  # Per-domain workflow details
│   └── frameworks/          # Framework-specific references
│       ├── react-native.md
│       ├── sveltekit.md
│       └── nativescript-svelte.md
│
├── user-guides/             # Human-facing docs, linked via README.md
│   ├── stories.md           # How to write stories
│   ├── specs.md             # How to write specs
│   ├── scenarios.md         # How scenarios work
│   └── navigation.md        # Navigation patterns
│
├── templates/               # Starter files copied into projects
│   ├── specs/
│   │   ├── project.md       # Decision document template
│   │   ├── schema/          # Schema spec templates
│   │   ├── components/      # Component spec templates
│   │   ├── screens/         # Screen spec templates
│   │   ├── global/          # Global specs (toolchain, ui, deps)
│   │   └── navigation.md    # Navigation template
│   ├── stories/
│   │   └── story-template.md
│   └── generated/
│       └── ...              # Consolidation templates
│
├── scripts/                 # Automation scripts
│   ├── init-project.sh      # Bootstrap new project
│   ├── add-app.sh           # Add app scaffold to project
│   ├── check-stale.sh       # Staleness detection
│   ├── regenerate.sh        # Per-slice regeneration plan
│   ├── generate-next.sh     # Pick next stale screen
│   ├── update-dep-hashes.sh # Refresh dependency hashes
│   ├── android-screenshot.sh # Android screenshot capture
│   ├── build-images.sh      # Batch screenshot capture
│   ├── preview-scenarios.sh # Local scenario preview
│   └── publish-scenarios.sh # Publish scenarios as HTML
│
├── QUICKSTART.md            # Getting started guide
└── README.md                # Toolkit overview
```

## Project Structure (v2.1)

This document describes the **canonical project layout** that agents and scripts should expect. For goals and guiding principles, see `docs/DESIGN.md`.

Appeus projects are organized around:
- **Shared design**: project decisions + shared domain contract
- **Per-app design**: stories/specs/consolidations per target app
- **Per-app code**: framework scaffolds under `apps/`

### Canonical layout (one or many apps, detailed)

```
project/
├── appeus → </path/to/appeus>                 # Symlink to the toolkit
├── AGENTS.md → ./appeus/agent-rules/bootstrap.md # Root agent entrypoint (later → agent-rules/project.md)
├── design/
│   ├── AGENTS.md → ../appeus/agent-rules/design-root.md
│   │
│   ├── specs/                                 # Human-authored, authoritative
│   │   ├── AGENTS.md → ../../appeus/agent-rules/specs.md
│   │   ├── project.md                         # Project-wide decisions (toolchain, quality posture, etc.)
│   │   │
│   │   ├── domain/                            # Optional: shared domain contract (preferred in v2.1)
│   │   │   ├── schema.md                      # Optional: core data structures / entities
│   │   │   ├── api.md                         # Optional: operations/procedures (even in non-client/server apps)
│   │   │   ├── rules.md                       # Optional: invariants, validation, permissions, semantics
│   │   │   └── interfaces.md                  # Optional: external systems, storage backends, sync model
│   │   │
│   │   ├── mobile/                            # Example target: mobile app
│   │   │   ├── screens/
│   │   │   │   ├── index.md                   # Screen registry (names/routes)
│   │   │   │   └── <Screen>.md                # Screen specs (user-observable UX contract)
│   │   │   ├── components/
│   │   │   │   ├── index.md                   # Component inventory
│   │   │   │   └── <Component>.md             # Component specs (reusable UI)
│   │   │   ├── navigation.md                  # Navigation/routing spec
│   │   │   └── global/
│   │   │       ├── ui.md
│   │   │       └── dependencies.md
│   │   │
│   │   └── web/                               # Example target: web app (same structure)
│   │       └── ...
│   │
│   ├── stories/                               # Human-authored narrative (“what happens”)
│   │   ├── AGENTS.md → ../../appeus/agent-rules/stories.md
│   │   ├── mobile/
│   │   │   └── 01-first-story.md
│   │   └── web/
│   │       └── 01-first-story.md
│   │
│   └── generated/                             # Agent-generated; subject to overwrite
│       ├── AGENTS.md → ../../appeus/agent-rules/consolidations.md
│       ├── mobile/
│       │   ├── meta/outputs.json              # Dependency hashes + staleness metadata
│       │   ├── screens/                       # Consolidations (translator layer)
│       │   │   └── <Screen>.md
│       │   ├── scenarios/
│       │   └── images/
│       └── web/
│           └── ...
├── apps/
│   ├── mobile/                              # Framework scaffold per app (e.g., React Native)
│   │   ├── AGENTS.md → ../../appeus/agent-rules/src.md
│   │   └── src/
│   │       └── ...
│   └── web/                                 # Framework scaffold per app (e.g., SvelteKit)
│       ├── AGENTS.md → ../../appeus/agent-rules/src.md
│       └── src/
│           └── ...
└── mock/
    └── data/                    # Shared mock data (optional)
```

Notes:
- `<target>` is an app name like `mobile`, `web`, `desktop`, etc.
- The root `AGENTS.md` may later be repointed from `bootstrap.md` to `project.md` after discovery.

## Component Purposes

### For Developing Appeus (see `./README.md`)

### For Agents Running in an Appeus-Guided Project (agent-rules/)
These files appear in various folders of the scaffold as AGENTS.md files linked back to a particular file under agent-rules.

These files will be consumed by agents as they traverse the project tree so they should:
- Be very clean and clean so they do not unnecessarily consume limited AI context space
- Be relevant to the folder they appear in
- Contain hyperlinks to definitive documents in the `./reference` folder
- Serve as an efficient index for agents so they can look up the reference details when then need them

### Discovery Phase
In the initial scaffold, the root AGENTS.md is pointed to bootstrap.md.  This causes the agent to more aggressively guide the user to complete specs/project.md before proceeding.  Once this phase is complete, the agent should repoint this link to agent-rules/project.md.  The agent will then assume a regular development role.

Post discovery development still involves additional phases, but those should be explained and detected according to rules outlined in agent-rules/project.md.

### For More Details (reference/)
These documents contain more complete, exhaustive information agents need to know.  This information should be in plain language understandable by humans or AI agents.

Documents should be limited to a single topic so that the agent-rules files can point to them from a topical reference and the agent can read the linked topic into its context and be prepared for the applicable task.

Reference documents should not contain extra fluff or formatting which would waste valuable AI context.  They should be clear, complete and to-the-point without redundancy but still completely covering the topic.

### For Humans (user-guides/)
Human-friendly guides linked via README.md in project folders.  These files are intended to help the human understand what they should do when in the applicable folder and its children.

Examples include:
- In this folder, you should create user stories. These stories should ...
- Here you create specifications. They can oveerride everything else so keep them consistent ...
- The domain folder is intended to contain ...

### For Project Setup (templates/)

Starter files get copied into projects when the project scaffold is create. Agents and scripts use these to seed new specs, stories, and consolidation files.

### For Automation (scripts/)

This section documents **what exists under `scripts/` today**, what each script is for, and where it fits in the workflow.

#### Entry points (human or agent)

- **`init-project.sh` — initialize an Appeus-guided project**
  - **Who runs it**: typically the human (an agent can run it if instructed)
  - **What it does**: creates the core project scaffold non-destructively (design folders, symlinks, starter templates, `.gitignore` entries).
  - **Expected behavior**: idempotent; refreshes symlinks; never overwrites existing user-authored files.

- **`add-app.sh` — add a new app target**
  - **Who runs it**: human or agent
  - **What it does**: creates `apps/<target>/` via a framework adapter and ensures the matching `design/*/<target>/` folders exist.
  - **Notable behavior**: supports `--refresh` for idempotent updates; prevents nested git repos under `apps/<target>/` by default.

#### Staleness + “what should I do next?”

- **`check-stale.sh` — compute staleness for a target**
  - **Who runs it**: typically the agent
  - **What it does**: reports which routes/screens appear stale by comparing inputs (stories/specs/navigation/global/domain) to outputs (generated app code).
  - **How it decides dependencies**: prefers the per-target dependency registry in `design/generated/<target>/meta/outputs.json` when present; falls back to a heuristic input set when missing.
  - **What it writes**: a per-target JSON staleness report under `design/generated/<target>/` (scripts should treat malformed/missing reports as regenerable and rebuild them).

- **`generate-next.sh` — convenience: pick one stale slice and print a plan**
  - **Status**: recommended convenience (not strictly required)
  - **Why keep it**: it standardizes “what next?” across agents, reduces indecision, and produces a deterministic next step (especially helpful when many screens are stale).
  - **If you prefer a manual flow**: agents can run `check-stale.sh`, pick a screen based on priority, then follow the workflow in `reference/`.

- **`regenerate.sh` — DEPRECATED (plan-only)**
  - **Why deprecate**: it does not perform regeneration; it only prints static “plan text,” which is better expressed in `agent-rules/` + `reference/` (and it has caused confusion for some agents/users).
  - **Replacement**: use `generate-next.sh` for an automated “next plan,” or follow the relevant reference workflow directly (starting from `check-stale.sh` and the chosen slice).

#### Dependency metadata

- **`update-dep-hashes.sh` — refresh dependency hashes**
  - **Who runs it**: agent
  - **What it does**: recomputes SHA256 hashes for the `dependsOn` files already registered per route and writes them into `depHashes` in `design/generated/<target>/meta/outputs.json`.
  - **Important behavior**:
    - It updates **only** the route you pass via `--route`, or **all registered routes** when you pass `--all`.
    - It does **not** “freshen” other stale slices by itself; staleness is driven by input/output timestamps (and by whether `dependsOn` is complete).
    - If `outputs.json` is missing or empty/template-like (no routes registered), this script will not infer routes; it will print “No outputs registered” and exit.

#### Scenarios and images

- **`build-images.sh` — capture missing/stale scenario images**
  - **Who runs it**: agent
  - **What it does**: iterates scenario definitions and captures screenshots where needed (mobile-first).

- **`android-screenshot.sh` — capture a screenshot from an Android emulator**
  - **Who runs it**: agent (usually indirectly via `build-images.sh`)
  - **What it does**: performs a deep-link + screenshot capture for an Android target.

- **`preview-scenarios.sh` — local scenario preview**
  - **Who runs it**: human
  - **What it does**: serves the scenarios folder locally for review.

- **`publish-scenarios.sh` — publish scenarios site**
  - **Who runs it**: human
  - **What it does**: packages scenarios and optionally syncs them to a destination.

#### Framework adapters and shared script libraries

- **`frameworks/*.sh` — framework-specific app scaffolding**
  - Called by `add-app.sh`. Each adapter owns how to scaffold, configure, and (when possible) make the scaffold reproducible/idempotent.

- **`lib/project-root.sh` — shared project-root detection**
  - Used by scripts to locate the project root reliably (including when `appeus/` is a symlink).

#### Legacy scripts (retained for now)

These remain in the repo but are not the v2.1 workflow entry points: `rn-init.sh`, `setup-appeus.sh`.
