# Scaffold Structure

Appeus v2 uses a progressive structure that scales from single-app to multi-app projects.

## Single-App Layout

When a project has one app (the common starting point):

```
project/
├── AGENTS.md → appeus/agent-rules/project.md
├── appeus → ../appeus
├── .gitignore                    # Ignores appeus symlinks
│
├── design/
│   ├── AGENTS.md → ../appeus/agent-rules/design-root.md
│   │
│   ├── specs/
│   │   ├── AGENTS.md → ../../appeus/agent-rules/specs.md
│   │   ├── project.md            # Toolchain decisions
│   │   ├── schema/               # Data model specs
│   │   │   └── index.md
│   │   ├── api/                  # API specs
│   │   │   ├── AGENTS.md → ../../../appeus/agent-rules/api.md
│   │   │   └── *.md
│   │   ├── screens/              # Screen specs (flat)
│   │   │   ├── index.md
│   │   │   └── *.md
│   │   ├── navigation.md         # Navigation spec
│   │   └── global/               # Global specs (ui, deps)
│   │
│   ├── stories/                  # Stories (flat)
│   │   ├── AGENTS.md → ../../appeus/agent-rules/stories.md
│   │   └── *.md
│   │
│   └── generated/
│       ├── AGENTS.md → ../../appeus/agent-rules/consolidations.md
│       ├── screens/              # Screen consolidations
│       ├── api/                  # API consolidations
│       ├── scenarios/
│       │   └── AGENTS.md → ../../../appeus/agent-rules/scenarios.md
│       ├── images/
│       │   └── index.md          # Screenshot config
│       ├── meta/
│       │   └── outputs.json      # Dependency tracking
│       └── status.json           # Staleness status
│
├── apps/
│   └── <name>/                   # App scaffold
│       ├── AGENTS.md → ../../appeus/agent-rules/<framework>-src.md
│       ├── src/
│       │   ├── screens/          # (or routes/, pages/)
│       │   ├── navigation/
│       │   ├── components/
│       │   ├── data/
│       │   └── ...
│       ├── package.json
│       └── ...
│
└── mock/
    └── data/                     # Mock data with variants
        ├── <namespace>.happy.json
        ├── <namespace>.empty.json
        └── <namespace>.meta.json
```

## Multi-App Layout

When a project has multiple apps (after adding a second):

```
project/
├── AGENTS.md → appeus/agent-rules/project.md
├── appeus → ../appeus
│
├── design/
│   ├── AGENTS.md
│   │
│   ├── specs/
│   │   ├── AGENTS.md
│   │   ├── project.md            # Toolchain decisions
│   │   ├── schema/               # ★ Shared data model
│   │   ├── api/                  # ★ Shared API specs
│   │   │
│   │   ├── <target>/             # Per-target specs
│   │   │   ├── screens/
│   │   │   │   ├── index.md
│   │   │   │   └── *.md
│   │   │   ├── navigation.md
│   │   │   └── global/
│   │   └── ...
│   │
│   ├── stories/
│   │   ├── AGENTS.md
│   │   ├── <target>/             # Per-target stories
│   │   │   └── *.md
│   │   └── ...
│   │
│   └── generated/
│       ├── AGENTS.md
│       ├── api/                  # Shared API consolidations
│       ├── <target>/             # Per-target consolidations
│       │   ├── screens/
│       │   ├── scenarios/
│       │   ├── images/
│       │   └── status.json
│       └── ...
│
├── apps/
│   ├── <target>/                 # Per-target scaffold
│   │   ├── AGENTS.md
│   │   └── ...
│   └── ...
│
├── packages/                     # Optional shared code
│   └── shared/
│       └── src/
│
└── mock/
    └── data/                     # Shared mock data
```

## AGENTS.md Placement

AGENTS.md files are symlinks that point to appeus agent-rules. They belong in any folder where an agent needs context about what to do:

| Location | Points To | Purpose |
|----------|-----------|---------|
| `project/AGENTS.md` | `agent-rules/project.md` | Project-level orientation |
| `design/AGENTS.md` | `agent-rules/design-root.md` | Design surface overview |
| `design/stories/AGENTS.md` | `agent-rules/stories.md` | Story authoring |
| `design/specs/AGENTS.md` | `agent-rules/specs.md` | Spec authoring |
| `design/generated/AGENTS.md` | `agent-rules/consolidations.md` | Consolidation rules |
| `design/generated/scenarios/AGENTS.md` | `agent-rules/scenarios.md` | Scenario generation |
| `apps/<name>/AGENTS.md` | `agent-rules/<framework>-src.md` | Framework-specific source rules |

## Path Detection

Scripts and agent rules detect single-app vs multi-app mode:

**Single-app indicators:**
- `design/specs/screens/` exists (flat)
- `design/specs/navigation.md` exists (single file)

**Multi-app indicators:**
- `design/specs/<target>/screens/` directories exist
- `design/specs/<target>/navigation.md` files exist

## Adding Apps Later

When `add-app.sh` is run on a single-app project, it automatically reorganizes:

| Before | After |
|--------|-------|
| `design/stories/*.md` | `design/stories/<existing>/*.md` |
| `design/specs/screens/` | `design/specs/<existing>/screens/` |
| `design/specs/navigation.md` | `design/specs/<existing>/navigation.md` |
| `design/generated/screens/` | `design/generated/<existing>/screens/` |

Domain contract specs remain at the top level (shared, as needed).

## Shared vs Per-Target Specs

| Location | Scope | Examples |
|----------|-------|----------|
| `design/specs/project.md` | Project-wide | Toolchain, platforms, data strategy |
| `design/specs/domain/` | Shared (as needed) | Data model, operations, rules, interfaces |
| `design/specs/*.md` (top level) | Shared | Cross-app workflows, shared patterns |
| `design/specs/<target>/` | Per-target | Screens, components, navigation, target-specific global |

**Note:** Not all projects use a client/server model. For local-first apps without a backend API:
- `domain/` can hold the data model (local storage entities) and other shared rules
- Put cross-cutting specs (shared workflows, components) directly in `design/specs/`

## Notes

- `design/generated/*` is fully regenerable — do not hand-edit
- App code lives in `apps/<name>/src/` — framework-specific layout
- Mock data in `mock/data/` is shared across all targets
- Symlinks are gitignored; collaborators run init to set up their environment
