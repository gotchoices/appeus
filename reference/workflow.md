# Appeus Workflow

## Overview

Appeus v2 follows a design-first workflow:

```
Init Project → Discovery → Add Apps → Stories → Schema → Specs → Codegen → Run → Iterate
```

## Phases

### Phase 1: Project Initialization

Run `init-project.sh` to create the project structure:
- `AGENTS.md` — Bootstrap agent rules
- `design/specs/project.md` — Decision document template
- `appeus` symlink — Points to appeus installation

### Phase 2: Discovery

Agent guides user through `project.md`:
- Purpose and goals
- Target platforms (mobile, web, desktop)
- Toolchain choices per target
- Data strategy (local-first, cloud sync, etc.)
- Delivery posture (prototype/MVP/production) and quality/performance expectations

Do not proceed until decisions are documented.

### Phase 3: Add Apps

Run `add-app.sh` for each target:
```bash
./appeus/scripts/add-app.sh --name mobile --framework react-native
./appeus/scripts/add-app.sh --name web --framework sveltekit
```

Creates app scaffolds in `apps/<name>/` and design folders.

### Phase 4: Story Authoring

Write stories in `design/stories/` (single-app) or `design/stories/<target>/` (multi-app).

Stories define user-facing requirements:
- Goal (As a user, I want...)
- Sequence (numbered steps)
- Acceptance criteria
- Variants (happy, empty, error)

### Phase 5: Schema Derivation

For multi-target projects, agent reads ALL stories to derive a shared data model:
- Creates `design/specs/schema/` with entity definitions
- Ensures schema supports all target experiences

### Phase 6: Specs and Consolidations

- **Stories** stay user-narrative (“what happens”).
- **Specs** stay a human-readable UX contract (user-observable behavior: states, rules, acceptance).
- **Consolidations** are the translator layer: programmer-facing digest (implementation mapping, edge-case completeness, dependency metadata) and are regenerable.
- Precedence: Specs > Consolidations > Defaults

### Phase 7: Code Generation

Vertical slicing — generate one screen/page at a time:
1. Refresh consolidations if stale
2. Generate API consolidations
3. Create mock data
4. Generate app code
5. Update navigation
6. Update staleness tracking

### Phase 8: Validation

- Run the app with mock data
- Generate scenarios (mobile): screenshots with deep links
- Review with stakeholders
- Iterate as needed

## Precedence Rules

1. **Human specs** — Always authoritative
2. **AI consolidations** — Facts gathered from stories; regenerable
3. **Defaults** — Framework conventions; fill gaps

## Regeneration

Human-triggered only. Use:
- `appeus/scripts/check-stale.sh` — Per-screen staleness summary
- `appeus/scripts/generate-next.sh` — Pick next stale screen
- `appeus/scripts/regenerate.sh --screen <Route>` — Target specific screen

## Multi-Target Workflow

When project has multiple apps:
- Schema derivation reads from ALL target stories
- Each target generates independently
- Shared specs (schema, API) are respected by all targets
- Scripts accept `--target <name>` to scope operations

## See Also

- [Scaffold Structure](scaffold.md)
- [Generation Details](generation.md)
- [Staleness and Dependencies](generation.md#staleness-and-dependencies)
