# DESIGN
Design decisions, rationale, and vision for Appeus v2.

## Approach
Appeus is a design-first workflow that turns user stories into running applications. The agent guides developers from initial project conception through working code, with stories as the source of truth.

## Vision
Figma helps UX designers prototype UIs without coding, but once a design exists, engineers still need to implement it in real code. Sometimes it is not optimal (or even feasible) to implement a design that was created with no thought to the realities of code, data, and performance.

Appeus aims to bring real application code in from the start, so prototypes are generated from actual framework code rather than an abstract set of pixels.

## History
**v0:**
Used AI to transform user stories into a set of screens and components, authored as XML renderings. The hope was that XML would be more readily parseable by AI than Figma output.

**v1:**
Built solely around React Native. The user would instantiate a React Native project, then insert a `design/` folder into the project and begin authoring stories.

**v2:**
Built to accommodate multiple apps (“targets”) in one project. The user initializes a project with a design surface, then adds one or more apps (mobile, web, desktop, etc.).

## Core Principles

1. **Design precedes scaffolding** — Toolchain decisions are made and documented before framework code is generated.

2. **Multi-target native** — A project may contain any number of apps (mobile, web, desktop), each with distinct stories/specs, while sharing domain decisions.

3. **Shared domain contract** — The project’s “domain” (data model and behavior) is defined once and reused across all targets. Depending on the project, this may include schema, operations (API/procedures), rules/invariants, external interfaces, and other storage/access decisions.

4. **Agent-guided discovery** — The agent leads the developer through implementation phases, capturing user intent as stories and proposing specs for details that can't reasonably be inferred.

5. **Vertical slicing** — Generate one testable feature at a time. For example:
   - a navigable screen (top-to-bottom)
   - a reusable component (invoked by a screen)
   - a user-observable data flow

6. **Artifact lanes (anti–spec creep)** —
   - Stories: user narrative (“what happens”)
   - Specs: user-observable UX contract (“how it behaves”), human-readable
   - Consolidations: programmer-facing digest + metadata (regenerable translator layer)

7. **Human precedence, agent inference** — For each slice, the agent generates consolidations with this priority:
   1. Human-authored specs (authoritative)
   2. Human-authored stories (agent should report and recommend resolution of any inconsistencies in stories)
   3. Prior consolidations, if present (treated as regenerable translator state)
   4. Defaults and best-practice inference (based on stories/specs)

8. **Iteration** — At any point, the user can modify stories/specs and ask the agent to regenerate one or more slices.

9. **Peer review** — Stories can be developed into scenarios: storyboards like the original stories, augmented with screenshots from the app in various (mock) data states.

   Mocking and variants are a UI validation mechanism:
   - A target app should have a single “mock mode” switch (mock vs production).
   - Variants apply to mock data only and are selected via deep links (primarily for screenshots/testing).
   - Screens/components should not accept `variant` parameters or otherwise know whether data is mock vs production.
   - The data layer decides mock vs production; in mock mode, it may consult the selected variant “on the side” (global/context) to load the appropriate `mock/data/<namespace>.<variant>.json`.

## Design Phases
The user and agent will work in various phases of the project, some phases are specific to a particular target.  Others are shared across all targets of the project.
  - Initial project and Appeus scaffold (shared): the user creates a workspace and installs Appeus.
  - Bootstrap/Discovery (shared): the user answers basic questions about how the project will be structured and developed (what apps exist, how data is stored/processed/accessed, etc.). This phase is completed by initializing the project for at least one app target.
  - Story Generation (per target): the user is responsible for generating stories but will likely request agent assistance in drafting them. The agent should help keep them in an appropriate tone, style and format.
  - Navigation Planning (per target): if no navigation spec exists yet, the agent infers a minimal navigation layout from stories (screen/component list + starter navigation template). The user reviews and updates the navigation spec before proceeding.
  - Domain Contract (shared): if no shared domain specs exist yet, the agent proposes them based on the project decisions and target stories/specs. If domain specs do exist, this might not be the first app on the project. In any case, the agent should help review the domain specifications to make sure they are compatible with the present target and without losing compatibility with other previously generated targets. The user should review updates before proceeding.
  - Screen/Component Slicing (per target): under user direction, the agent implements the UI one slice at a time, giving the user a chance to test and commit at each stable milestone. This phase typically uses mock data so the UI can be validated in multiple states.
  - Scenario / Peer Review (per target, optional): the agent can generate storyboard-like scenarios with screenshots to support review and iteration.
  - Final wiring (target): after screen/UI approval, slices are finished and tested against the production data model.


## Example project scaffold (high level)

For more complete scaffold structure, see `docs/ARCHITECTURE.md`.

Appeus projects are organized around:
- **Shared design**: project decisions + shared domain contract
- **Per-target design**: stories/specs/consolidations per app target
- **Per-target code**: framework scaffolds under `apps/`

```
project/
├── appeus → </path/to/appeus>
├── design/
│   ├── specs/                   # Human-generated, human-readable material
│   │   ├── project.md           # Project-wide specs
│   │   ├── domain/              # Optional: shared domain contract (schema/ops/rules/interfaces)
│   │   └── <target>/            # Per-app specs (screens/components/navigation/global)
│   ├── stories/
│   │   └── <target>/            # Per-app stories
│   └── generated/               # Agent-generated content, subject to overwrite
│       └── <target>/            # Per-app consolidations, scenarios, metadata
├── apps/
│   └── <target>/                # Framework scaffold per app (react-native, svelte, etc)
└── mock/
    └── data/                    # Shared mock data for testing, scenarios (optional)
```

## Operational goals

Appeus should be safe to adopt early, and easy to remove later:

- **Idempotent setup**: running `scripts/init-project.sh` or `scripts/add-app.sh` multiple times should be safe and should refresh links and add missing scaffold without overwriting user-authored files.
- **Non-destructive adoption**: Appeus should be usable inside an existing repo by adding only what’s missing and never clobbering existing project files.
- **Detachable**: a finished project should be able to remove Appeus symlinks and agent scaffolding while keeping the resulting app code and human-authored design artifacts intact (stories/specs).
- **Self-checking guidance**: agents should be generally aware of the expected scaffold layout and be able to detect older/malformed project structure or generated artifacts, then advise and assist the user in reorganizing to the current layout.

Framework adapter details, version-control guidance, and migration notes are intentionally documented in `docs/ARCHITECTURE.md` rather than here.
