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

## Project Structure (v2)

Appeus v2 uses a **progressive structure**: single-app projects use flat layouts; multi-app projects use per-target subdirectories. The transition is automated.

### Single-App Layout

When a project has only one app (the common starting point):

```
project/
├── AGENTS.md → appeus/agent-rules/project.md
├── appeus → ../appeus-2
│
├── design/
│   ├── AGENTS.md
│   ├── specs/
│   │   ├── AGENTS.md
│   │   ├── project.md           # Toolchain decisions
│   │   ├── schema/              # Data model
│   │   ├── api/                 # API surface
│   │   ├── screens/             # Screen specs (flat)
│   │   │   ├── index.md
│   │   │   └── <screen>.md
│   │   ├── navigation.md        # Navigation spec
│   │   └── global/              # Global specs
│   ├── stories/                 # Stories (flat)
│   │   ├── AGENTS.md
│   │   └── *.md
│   └── generated/
│       ├── AGENTS.md
│       ├── screens/             # Consolidations (flat)
│       ├── scenarios/
│       ├── images/
│       ├── api/
│       └── status.json
│
├── apps/
│   └── <name>/                  # Single app scaffold
│       ├── AGENTS.md
│       ├── src/
│       └── ...
│
└── mock/
    └── data/
```

### Multi-App Layout

When a project has multiple apps (after adding a second app):

```
project/
├── AGENTS.md → appeus/agent-rules/project.md
├── appeus → ../appeus-2
│
├── design/
│   ├── AGENTS.md
│   ├── specs/
│   │   ├── AGENTS.md
│   │   ├── project.md           # Toolchain decisions
│   │   ├── schema/              # ★ Shared data model
│   │   ├── api/                 # ★ Shared API surface
│   │   ├── <target>/            # Per-target specs
│   │   │   ├── screens/
│   │   │   │   ├── index.md
│   │   │   │   └── <screen>.md
│   │   │   ├── navigation.md
│   │   │   └── global/
│   │   └── ...
│   ├── stories/
│   │   ├── AGENTS.md
│   │   ├── <target>/            # Per-target stories
│   │   │   └── *.md
│   │   └── ...
│   └── generated/
│       ├── AGENTS.md
│       ├── <target>/            # Per-target consolidations
│       │   ├── screens/
│       │   ├── scenarios/
│       │   ├── images/
│       │   └── status.json
│       ├── api/                 # Shared API consolidations
│       └── ...
│
├── apps/
│   ├── <target>/                # Per-target scaffold
│   │   ├── AGENTS.md
│   │   ├── src/
│   │   └── ...
│   └── ...
│
├── packages/                    # Optional shared code
│   └── shared/
│       └── ...
│
└── mock/
    └── data/                    # Shared mock data
```

### Single-to-Multi Migration

When you run `add-app.sh` on a single-app project, the script automatically reorganizes:

| Before | After |
|--------|-------|
| `design/stories/*.md` | `design/stories/<existing-target>/*.md` |
| `design/specs/screens/` | `design/specs/<existing-target>/screens/` |
| `design/specs/navigation.md` | `design/specs/<existing-target>/navigation.md` |
| `design/generated/screens/` | `design/generated/<existing-target>/screens/` |
| `design/generated/scenarios/` | `design/generated/<existing-target>/scenarios/` |

The script preserves all content while restructuring paths. Schema and API specs remain at the top level (shared).

## Component Purposes

### For Developing Appeus (docs/)

| File | Purpose |
|------|---------|
| DESIGN.md | Why appeus works the way it does |
| GENERATION.md | Detailed generation strategy |
| STATUS.md | What's done, what's next |
| ARCHITECTURE.md | Folder structure reference |

### For Agents Building Apps (agent-rules/)

Brief, linked rules that appear via AGENTS.md symlinks in project folders.

| File | When Linked |
|------|-------------|
| bootstrap.md | Root AGENTS.md during discovery phase |
| project.md | Root AGENTS.md after discovery |
| stories.md | design/stories/AGENTS.md |
| specs.md | design/specs/AGENTS.md |
| consolidations.md | design/generated/AGENTS.md |
| src.md | apps/<name>/AGENTS.md (all frameworks) |

### For Agents Needing Details (reference/)

Longer documents with complete workflow details, accessed via links in agent-rules.

### For Humans (user-guides/)

Human-friendly guides linked via README.md in project folders.

### For Project Setup (templates/)

Starter files copied into projects. Agents and scripts use these to seed new specs, stories, and consolidation files.

### For Automation (scripts/)

| Script | Who Uses | Purpose |
|--------|----------|---------|
| init-project.sh | Human | Bootstrap new project |
| add-app.sh | Human/Agent | Add app scaffold |
| check-stale.sh | Agent | Detect what needs regeneration |
| regenerate.sh | Agent | Plan for specific slice |
| generate-next.sh | Agent | Pick and plan next slice |
| update-dep-hashes.sh | Agent | Update metadata after generation |
| android-screenshot.sh | Agent | Capture Android screenshots |
| preview-scenarios.sh | Human | Local scenario preview |
| publish-scenarios.sh | Human | Publish to web |

## Path Detection

Scripts and agent rules detect whether a project is single-app or multi-app:

**Single-app indicators:**
- `design/specs/screens/` exists (flat)
- `design/specs/navigation.md` exists (single file)
- No `design/specs/<target>/` subdirectories

**Multi-app indicators:**
- `design/specs/<target>/screens/` directories exist
- `design/specs/<target>/navigation.md` files exist
- Multiple subdirectories under `apps/`

Scripts adjust paths automatically based on detected mode. Agent rules reference paths using variables that resolve based on mode.

