# DESIGN

Design decisions, rationale, and vision for Appeus v2.

## Vision

Appeus is a design-first workflow that turns user stories into running applications. The agent guides developers from initial project conception through working code, with stories as the source of truth.

**v1 (RN-first):** Scaffold React Native first, then add design surface.

**v2 (Design-first):** Create project and design surface first, then instantiate app scaffolds based on documented decisions.

## Core Principles

1. **Design precedes scaffolding** — Toolchain decisions are made and documented before any framework code is generated.

2. **Multi-target native** — A project may contain multiple apps (mobile, web, desktop) with distinct stories but shared schema and API.

3. **Agent-guided discovery** — The agent leads the developer through architecture decisions, capturing them in specs before proceeding.

4. **Shared data layer** — Schema and API specs are defined once and shared across all targets.

5. **Human precedence** — Stories + specs (human) > consolidations (AI) > defaults.

6. **Artifact lanes (anti–spec creep)** —
   - Stories: user narrative (“what happens”)
   - Specs: user-observable UX contract (“how it behaves”), human-readable
   - Consolidations: programmer-facing digest + metadata (regenerable translator layer)

7. **Vertical slicing** — Generate one navigable screen/page at a time, top-to-bottom.

## Key Differences from v1

| Aspect | v1 | v2 |
|--------|----|----|
| Bootstrap | `rn-init.sh` → `setup-appeus.sh` | `init-project.sh` → (discovery) → `add-app.sh` |
| Toolchain | Template filled after RN exists | Decision document before any scaffold |
| Targets | Single RN app | One or many: mobile, web, etc. |
| Stories | One set | Per-target sets, plus optional shared |
| Schema | Implicit in screens | Explicit shared specs |
| Folder structure | RN app with design/ inside | Project root with apps/ inside |

## Architecture

### Progressive Structure

Appeus uses a **progressive structure** that starts simple and scales:

- **Single-app projects** use a flat layout (no subdirectories for targets)
- **Multi-app projects** use per-target subdirectories
- **Transition is automated** — when you add a second app, `add-app.sh` reorganizes the folder structure

This avoids unnecessary complexity for simple projects while supporting growth.

### Single-App Structure

When a project has only one app:

```
project/
├── AGENTS.md
├── appeus → ../appeus-2
├── design/
│   ├── specs/
│   │   ├── project.md           # Toolchain decisions
│   │   ├── schema/              # Data model (still shared, just not with other apps yet)
│   │   ├── api/                 # API surface
│   │   ├── screens/             # Screen specs (flat)
│   │   ├── navigation.md        # Navigation spec
│   │   └── global/              # Global specs
│   ├── stories/                 # Stories (flat, no subdirectory)
│   │   └── *.md
│   └── generated/
│       ├── screens/             # Consolidations (flat)
│       ├── scenarios/
│       └── images/
├── apps/
│   └── <name>/                  # Single app scaffold
└── mock/
    └── data/
```

### Multi-App Structure

When a project has multiple apps:

```
project/
├── AGENTS.md
├── appeus → ../appeus-2
├── design/
│   ├── specs/
│   │   ├── project.md           # Toolchain decisions
│   │   ├── schema/              # ★ Shared data model
│   │   ├── api/                 # ★ Shared API surface
│   │   ├── <target>/            # Per-target specs
│   │   │   ├── screens/
│   │   │   ├── navigation.md
│   │   │   └── global/
│   │   └── ...
│   ├── stories/
│   │   ├── <target>/            # Per-target stories
│   │   └── ...                  # (shared/ subfolder optional)
│   └── generated/
│       ├── <target>/            # Per-target consolidations, scenarios
│       │   ├── screens/
│       │   ├── scenarios/
│       │   └── images/
│       └── ...
├── apps/
│   ├── <target>/                # Framework scaffold per target
│   └── ...
├── packages/
│   └── shared/                  # Shared TypeScript types (optional)
└── mock/
    └── data/                    # Shared mock data
```

### Adding Apps Later

A project can start with one app and add more later:

1. User runs `add-app.sh --name web --framework sveltekit`
2. Script detects existing single-app structure
3. Script automatically reorganizes:
   - `design/stories/*.md` → `design/stories/<existing-target>/*.md`
   - `design/specs/screens/` → `design/specs/<existing-target>/screens/`
   - `design/specs/navigation.md` → `design/specs/<existing-target>/navigation.md`
   - `design/generated/screens/` → `design/generated/<existing-target>/screens/`
   - etc.
4. Script creates new target folders for the added app
5. Agent rules now operate in multi-app mode

This transition is **safe and automated** — no manual folder shuffling required.

### Bootstrap Flow

1. **Project init** — `init-project.sh` creates project folder with minimal `AGENTS.md` and `design/specs/project.md` template.

2. **Discovery phase** — Agent guides user through `project.md`: purpose, platforms, toolchain choices, data strategy.

3. **Add apps** — For each target, `add-app.sh --name <name> --framework <framework>` creates `apps/<name>/` with appropriate scaffold.

4. **Story authoring** — User writes stories in `design/stories/<target>/`.

5. **Schema derivation** — Agent derives shared schema from all stories, writes to `design/specs/schema/`.

6. **Per-target generation** — Standard appeus flow per target: consolidations → specs → codegen.

## Multi-Target Coordination

When a project has multiple targets (e.g., mobile + web):

- **Schema awareness** — When deriving schema, agent reads stories from ALL targets to ensure data model supports both.

- **API consistency** — API specs are shared; both apps call the same endpoints.

- **Cross-reference** — Agent rules in each target reference shared specs and can consult sibling target stories for context.

- **Independent generation** — Each target generates independently but respects shared constraints.

## Framework Adapters

Appeus v2 supports multiple frameworks via adapters:

| Framework | Scaffold Command | Reference | Output Path |
|-----------|------------------|-----------|-------------|
| React Native | `add-app.sh --framework react-native` | `reference/frameworks/react-native.md` | `apps/<name>/src/screens/` |
| SvelteKit | `add-app.sh --framework sveltekit` | `reference/frameworks/sveltekit.md` | `apps/<name>/src/routes/` |
| NativeScript Vue | `add-app.sh --framework nativescript-vue` | TBD | TBD |

Each adapter provides:
- Scaffold initialization script
- Framework-specific reference doc
- Codegen templates and conventions
- Navigation/routing patterns

All apps use the same `agent-rules/src.md` which links to the appropriate framework reference.

## Scope Boundaries

### In Scope (v2)
- Design-first bootstrap with discovery phase
- Multi-target project structure
- Shared schema/API specs
- React Native adapter (carried from v1)
- Web adapter (SvelteKit initially)

### Deferred
- Scenario generation for web (can add later)
- NativeScript adapters (can add when needed)
- Shared component libraries across targets

### Out of Scope
- Runtime schema rendering (appeus generates code, not runtime interpreters)
- Backend/server code generation

## Migration from v1

Existing v1 projects (single RN app with design/ inside):
- Continue working with appeus-1 (v1 branch)
- Optionally migrate by wrapping in project folder and moving app to `apps/mobile/`
- Migration is mechanical but not required

## Operational Principles

### Idempotent Setup

Running `init-project.sh` or `add-app.sh` multiple times is safe:
- Symlinks are refreshed (always point to current appeus)
- New folders/templates are added if missing
- Existing user files are never overwritten
- A report shows what was added vs. skipped

This allows projects to pick up new appeus features by re-running setup.

### Non-Destructive in Existing Projects

Appeus can be added to an existing project (e.g., a manually created codebase):
- Init detects existing content and works around it
- Only adds the appeus scaffolding that's missing
- Never clobbers existing files

### Version Control

Appeus symlinks should be gitignored:

```gitignore
# Appeus (recreate with: path/to/appeus/scripts/init-project.sh)
appeus
AGENTS.md
**/AGENTS.md
```

Rationale: Symlink targets are machine-specific. The project documents its appeus dependency in `design/specs/project.md`; collaborators run init to set up their environment.

### Detaching Appeus

A finished project can be detached from appeus:
- `detach-appeus.sh` removes all symlinks
- All user content (stories, specs, src, generated) remains
- The project becomes a standalone codebase

Use cases: archival, handoff to non-appeus teams, simplifying finished projects.

## References

- Generation strategy: `docs/GENERATION.md`
- Status/roadmap: `docs/STATUS.md`
- Agent rules: `agent-rules/*.md`
- Reference docs: `reference/*.md`
