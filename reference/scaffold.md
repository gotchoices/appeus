# Scaffold Structure

Appeus uses a single canonical layout: everything is **per-target**, and targets always live under `apps/<target>/`.

## Canonical Layout

Example targets: `mobile`, `web`.

```
project/
├── AGENTS.md → `appeus/agent-rules/bootstrap.md` (after `init-project.sh`)
│            → `appeus/agent-rules/project.md` (after first `add-app.sh`)
├── appeus → /path/to/appeus-root
├── .gitignore                    # Ignores appeus symlinks
│
├── design/
│   ├── AGENTS.md → ../appeus/agent-rules/design-root.md
│   │
│   ├── specs/
│   │   ├── AGENTS.md → ../../appeus/agent-rules/specs.md
│   │   ├── project.md            # Project-wide decisions / delivery posture
│   │   ├── domain/               # Shared domain contract (as needed)
│   │   │   └── README.md → ../../../../appeus/user-guides/domain.md
│   │   ├── mobile/               # Per-target specs
│   │   │   ├── STATUS.md         # Target phase checklist
│   │   │   ├── screens/
│   │   │   │   ├── index.md
│   │   │   │   └── *.md
│   │   │   ├── components/
│   │   │   │   ├── index.md
│   │   │   │   └── *.md
│   │   │   ├── navigation.md
│   │   │   └── global/
│   │   │       └── *.md
│   │   └── web/
│   │       └── ...
│   │
│   ├── stories/
│   │   ├── AGENTS.md → ../../appeus/agent-rules/stories.md
│   │   ├── mobile/
│   │   │   └── *.md
│   │   └── web/
│   │       └── *.md
│   │
│   └── generated/
│       ├── AGENTS.md → ../../appeus/agent-rules/consolidations.md
│       ├── mobile/
│       │   ├── screens/          # Screen consolidations
│       │   ├── scenarios/
│       │   │   └── AGENTS.md → ../../../appeus/agent-rules/scenarios.md
│       │   ├── images/
│       │   │   └── index.md      # Screenshot config
│       │   ├── meta/
│       │   │   └── outputs.json  # Dependency registry (per-target)
│       │   └── status.json       # Staleness report (per-target)
│       └── web/
│           └── ...
│
├── apps/
│   ├── mobile/
│   │   ├── AGENTS.md → ../../appeus/agent-rules/src.md
│   │   └── src/
│   │       └── ...
│   └── web/
│       └── ...
│
└── mock/
    └── data/                     # Shared mock data with variants
        ├── <namespace>.happy.json
        ├── <namespace>.empty.json
        └── <namespace>.meta.json
```

## AGENTS.md Placement

AGENTS.md files are symlinks that point to appeus agent-rules. They belong in folders where an agent needs local context:

| Location | Points To | Purpose |
|----------|-----------|---------|
| `project/AGENTS.md` | `agent-rules/project.md` | Project-level orientation |
| `design/AGENTS.md` | `agent-rules/design-root.md` | Design surface overview |
| `design/stories/AGENTS.md` | `agent-rules/stories.md` | Story authoring |
| `design/specs/AGENTS.md` | `agent-rules/specs.md` | Spec authoring |
| `design/generated/AGENTS.md` | `agent-rules/consolidations.md` | Consolidation rules |
| `design/generated/<target>/scenarios/AGENTS.md` | `agent-rules/scenarios.md` | Scenario generation |
| `apps/<target>/AGENTS.md` | `agent-rules/src.md` | App source rules (framework-specific guidance lives in reference) |

## Notes

- `design/generated/*` is regenerable; treat it as derived output.
- `design/specs/domain/` is optional; use it for shared “domain contract” docs when needed.
- If a project’s filesystem looks inconsistent, see the migration section in `appeus/CHANGELOG.md`.
