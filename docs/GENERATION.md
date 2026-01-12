# GENERATION

How Appeus tracks dependencies, detects staleness, and generates outputs. This is a design-intent document; agents follow operative rules in `agent-rules/` and `reference/`.

## Overview
Generation is the process of creating code from stories and specs. The agent must be able to do this according to the [Appeus core principles](./DESIGN.md#core-principles) and the Appeus-defined workflow (explained in this file) by reading only the `AGENTS.md` files in the applicable folders (and/or their parents up to the project root).

The agent will not know every detail solely from `AGENTS.md`, but it should know what subjects exist and where to find the exhaustive details in the `reference/` documents when needed.

## Working context
An Appeus project consists of [several phases](./DESIGN.md#design-phases). Some phases are shared across the project; others are per-target. Since a project may contain multiple targets, it is important for the agent to know which **phase** and which **target** is currently being worked on in order to guide the user effectively.

## Phases and progression
- **Bootstrap/discovery**
  Human-specified details about how the project will be structured:
  - At this point, the project root `AGENTS.md` is still symlinked to `appeus/agent-rules/bootstrap.md` and no particular app is yet being worked on.
  - The agent is focused on discovery and completing `design/specs/project.md` (project/toolchain specification).
  - This phase is considered complete once project/toolchain decisions are captured and the first app target is added; `add-app.sh` then repoints the root `AGENTS.md` to `appeus/agent-rules/project.md` (post-discovery development).
  - When an app target is created, the script will seed a per-target checklist file (e.g., `STATUS.md`) to track target-level phases and remaining work.
- **Story Generation**
  Human-specified descriptions of app user experiences:
  - A set of app-specific user stories is needed before meaningful generation can occur and before the domain contract can be designed.
  - As long as stories are missing or clearly incomplete (per `design/stories/<target>/` and/or the target checklist), the agent should encourage the user to produce them before going further.
  - If stories are sufficient to describe a coherent navigation and storage plan, this phase can be checked off in the target checklist.
- **Navigation Planning**
  Optionally human-generated else agent-inferred, human-reviewed:
  - If necessary, the agent will assist the user by building a minimal `design/specs/<target>/navigation.md` file.
  - This navigation spec implies a set of screens which should also be enumerated in `design/specs/<target>/screens/index.md`.
  - The agent should encourage the user to review and iterate (by modifying stories and/or navigation) until the screen set and navigation spec seem complete; then check this phase off in the target checklist.
- **Domain Contract**
  Optionally human-generated else agent-inferred, human-reviewed:
  - Unless much is known in advance about the intent for data management, it can be difficult or even impossible to complete this phase without sufficient stories first being built. Even though the domain contract is shared, it is listed in the target development flow because all targets depend on it.
  - If this is the first app, the domain spec will likely be created from scratch.
  - The agent should use the common project spec to decide what documentation is needed (API, schema, rules, interfaces, etc.) and prompt the user to develop the needed specs. These specs should be sufficient to describe both mock and production data handling.
  - If this is not the first app, care must be taken: changes must preserve compatibility with previously generated targets.  Either adapt the new target’s stories/specs, or update legacy targets as needed.
  - When the domain spec is sufficient to support the present target, this phase may be checked off.
- **Screen/Component Slicing**
  Agent generated code based on stories, specs:
  - When this is the next open checklist item, the agent may, upon user request, proceed to generate slices.
  - Generation proceeds according to the workflow outlined below.
  - When all screens/components are at least in a demonstration state, this phase may be checked off.
- **Scenario / Peer Review**
  Agent generated storyboards with screenshots based on stories:
  - This optional phase is helpful if other team members will be reviewing the proposed screens and navigation.
  - It is possible that the screens so far are prototypical and data is still mocked.
  - A local review may be generated for the user using prevew-scenarios.sh.
  - Or a review may be made available more publicly as html using publish-scenarios.sh, assuming an available web server.
  - Based on review, the user may iterate back to stories/navigation/specs and repeat phases to refine the app; further refinements should be tracked in the target checklist.
- **Final wiring**
  Agent generated code based on stories, specs:
  - Once UI slices are stable, further generation requests should be directed toward wiring the production domain contract and/or other program logic.
  - This means all data is managed, processed and stored according to the production specification.
  - This phase might also involve regression testing, feature addition, etc.

## Inputs and Outputs

### Shared (Cross-Target)

| Type | Location | Description |
|------|----------|-------------|
| Domain contract | `design/specs/domain/` | Shared domain specs (schema/ops/rules/interfaces); exact files vary by project |
| Mock data | `mock/data/` | Shared mock JSON with variants |

### Per-Target

| Type | Location | Description |
|------|----------|-------------|
| Stories | `design/stories/<target>/` | User stories for this target |
| Screen/page specs | `design/specs/<target>/screens/` | Human-authored specs |
| Navigation/routing | `design/specs/<target>/navigation.md` | Nav structure, deep links |
| Consolidations | `design/generated/<target>/screens/` | AI-derived from stories |
| Scenarios | `design/generated/<target>/scenarios/` | Screenshots + deep links |
| App code | `apps/<target>/src/` | Generated screens, routes, etc. |

## Generation Flow

This section describes the **code-generation loop** for a single target.  It applies to the phases above Screen Iteration and Final Wiring.

### Preconditions (before generating code)

- **Target is explicit**: the agent knows which `<target>` it is working on (to avoid cross-target writes).
- **Stories exist**: `design/stories/<target>/` contains enough stories to justify the slice.
- **Slice registry exists**: `design/specs/<target>/screens/index.md` lists the screen/route to generate.
- **Navigation exists** (at least minimal): `design/specs/<target>/navigation.md`.
- **Domain contract is usable** (shared): `design/specs/domain/` is present and sufficient for the slice, or the agent/user agrees to extend it first.

### Step 1: Select a slice

The user may name the slice directly (“generate ItemList”), or the agent may choose a candidate from the screens index:
- Prefer a screen reachable from the current navigation root.
- Prefer missing/stale screens first (optionally using `check-stale.sh`).

### Step 2: Read authoritative inputs

For the selected slice, read (in precedence order):
- **Human specs** for the target (screen/component/navigation/global)
- **Human stories** for the target
- **Shared domain contract** (`design/specs/domain/`)
- Existing consolidations (if present) as regenerable translator state

### Step 3: Generate/refresh consolidation(s)

Write or refresh `design/generated/<target>/screens/<Screen>.md` as the programmer-facing digest that:
- references the relevant stories/specs/domain assumptions
- identifies needed components and data interactions
- records dependency metadata (`dependsOn` and hashes) so staleness is deterministic

### Step 4: Generate code for the slice

Generate/update framework code under `apps/<target>/src/` (screen/page + any necessary routing/nav updates), using the consolidation as the primary translator artifact while preserving human-authored specs.

### Step 5: Validate and iterate

- Prompt the user to run/reload the target app and validate the slice behavior against the spec.
- If behavior is wrong, the user should iterate by updating **stories/specs** (human lane) and then prompt the agent to regenerate the slice
- The agent should not “fix the spec by writing programmer structure into it” (that belongs in consolidations).

### Step 6 (optional): Scenario review artifacts

If stakeholder review is needed, capture/refresh scenarios and screenshots for the slice and make them available for review (local preview and/or published HTML).

### Step 7: Update metadata + confirm freshness

After generating a slice, update dependency metadata for the slice and confirm it is no longer stale:
- Update per-route hashes/registries (e.g., `update-dep-hashes.sh --route <Route>`)
- Optionally re-run staleness reporting (e.g., `check-stale.sh`) to confirm the slice is fresh.  This can also occur as the first step of selecting the next slice.

### Step 8: Commit at stable milestones

Once the slice is stable and tested, the user should commit a clean milestone.  This is facilitated by the agent pausing between slices and waiting for the user to start the next generation slice.

## Dependency model (nodes, relationships, and what “dependsOn” means)
## Staleness detection (hash-based preferred; mtime fallback)
## Scripts (what exists, what is optional)
## Metadata formats (frontmatter / code headers / mocks)
## Notes for agent-rules and reference (design constraints for workflow docs)
## Testing (per-slice expectations)

===================================== Eventual EOF =====================================

## Old content below will be integrated into new outline above

## Working context: target selection

Before discussing phases, the generator must know **which app/target** it is operating on.

- Projects may contain multiple app targets (e.g. `mobile`, `web`), each with its own stories/specs/generated outputs and app code under `apps/<target>/`.
- Any workflow guidance in `agent-rules/` and `reference/` should make the active target explicit (or require it), to avoid cross-target writes.
- If a target is ambiguous (or missing), the safe behavior is to stop and ask the user which target is being worked on.

## Common user command intents (for workflow mapping)

Users often issue short commands. Agent workflows should map these to concrete actions:

- **“generate” / “generate a slice”**: identify target → identify candidate slice → refresh consolidations/specs as needed → generate code → update dependency metadata → (optional) scenarios.
- **“generate next slice”**: like “generate,” but using an optional helper to pick a candidate slice when multiple are stale.
- **“what should I do next?”**: identify target + phase → point to the next prerequisite or next stale slice, with minimal steps.

## Phases and progression (for reviewing agent workflows)

This section is not operative “agent instruction.” Its purpose is to describe the **phase model** that `agent-rules/` and `reference/` should make observable and actionable for an agent working in a project repo.

### How an agent can detect the current phase

Signals an agent can use (in rough order):

- **Bootstrap/discovery incomplete**
  - `design/specs/project.md` missing or clearly incomplete.
  - No app targets exist yet under `apps/`.
- **Domain contract missing or immature**
  - Domain specs exist but are too sparse to support consistent generation across targets.
  - Stories exist but shared schema/API specs have not been derived/refined.
- **Per-target planning missing**
  - No per-target screens index; no navigation spec; or screens are present but not registered for slicing.
- **Slice iteration phase**
  - Screens are registered; staleness reporting identifies one or more slices as missing/stale.
- **Scenario/peer-review phase**
  - Slices exist but scenarios/screenshots are missing or stale for review.
- **Final wiring**
  - UI slices are stable; remaining work is integrating the real data model and production connections.

### How an agent should help progress through phases

At a high level:

- Ensure the **prerequisites of the next phase** exist (folders/files/specs), without overwriting user-authored content.
- Prefer **small, testable increments**: one slice at a time, then validate (run/test) and record the result (scenarios optional).
- When phase assumptions are violated (missing/malformed generated metadata), treat them as **repairable outputs** and rebuild rather than hand-editing.

### Generation flow (as phases)

### Phase 1: Schema Derivation (Multi-Target)

When multiple targets exist:

1. Agent reads stories from ALL targets (`design/stories/*/`)
2. Identifies entities and relationships mentioned across stories
3. Proposes schema specs in `design/specs/schema/`
4. Human reviews and refines

This ensures the data model supports all target experiences.

### Phase 2: Per-Target Generation (Vertical Slice)

For each target, the standard flow applies:

1. **Screen consolidation** — Refresh `design/generated/<target>/screens/<Screen>.md`
2. **API consolidations** — Refresh needed namespaces
3. **Mocks** — Generate/refresh mock data for required namespaces
4. **App code** — Generate screen/page and update navigation
5. **Scenarios** — Capture screenshots, generate scenario docs (mobile targets)
6. **Update status** — Write to `status.json`, print report

### Slice Selection

Build navigation graph from `design/specs/<target>/navigation.md` and screens index.

Selection order:
1. First stale screen reachable from root
2. Then stale neighbors (navigable from fresh screens)
3. Remaining stale screens

## What Goes Where (Anti–Spec Creep)

To keep the workflow sustainable and human-readable:

| Artifact | Audience | Intent | Notes |
|----------|----------|--------|-------|
| **Stories** (`design/stories/…`) | Humans | “What happens” (narrative) | Avoid implementation detail |
| **Specs** (`design/specs/…`) | Humans | “How it behaves” (user-observable UX contract) | Keep readable; avoid programmer-facing APIs/state machines |
| **Consolidations** (`design/generated/…`) | Agents/engineers | Programmer-facing digest + dependency metadata | Translator layer; regenerable |

Rule of thumb: if a spec is getting hard for the human to read, move programmer-structure into the consolidation instead.

## Dependency Model

### Nodes and Relationships

**Schema consolidation** (`design/specs/schema/<entity>.md`)
- dependsOn: stories from ALL targets that reference the entity
- Shared across targets

**Screen consolidation** (`design/generated/<target>/screens/<Screen>.md`)
- provides: `["screen:<target>:<Screen>"]`
- needs: `["api:<Namespace>", "schema:<Entity>"]`
- dependsOn: stories, specs, navigation, schema specs

**API consolidation** (`design/generated/api/<Namespace>.md`)
- provides: `["api:<Namespace>"]`
- dependsOn: schema specs, stories, screen specs that dictate shape

**App code** (`apps/<target>/src/screens/<Screen>.tsx` or equivalent)
- AppeusMeta header with dependsOn and depHashes

**Scenarios** (`design/generated/<target>/scenarios/<story-id>.md`)
- dependsOn: stories + screens referenced

### Status Registry

`design/generated/<target>/status.json` tracks per-target staleness:
```json
{
  "screens": [
    {
      "route": "LogHistory",
      "stale": false,
      "reason": ""
    }
  ],
  "timestamp": "2025-12-07T...",
  "staleCount": 0
}
```

## Staleness Detection

### Hash-Based (Preferred)

1. Compute sha256 for each dependsOn file
2. Compare to saved depHashes in consolidation/output
3. Mismatch = stale

### Fallback (mtime-Based)

When metadata missing:
- Inputs: stories, specs, navigation, schema
- Outputs: generated consolidations, app code
- stale = any input mtime > output mtime

## Scripts

| Script | Purpose |
|--------|---------|
| `check-stale.sh` | Per-screen staleness report + JSON |
| `update-dep-hashes.sh --route <Route>` | Refresh depHashes after generation |

Scripts operate per-target; pass `--target <name>` when project has multiple apps.

## File Metadata Formats

### Consolidation Frontmatter (YAML)

  ```yaml
---
provides: ["screen:mobile:LogHistory"]
needs: ["api:LogEntries", "schema:Entry"]
  dependsOn:
  - design/stories/mobile/02-daily.md
  - design/specs/mobile/screens/log-history.md
  - design/specs/mobile/navigation.md
  - design/specs/schema/entry.md
  depHashes:
  design/specs/mobile/screens/log-history.md: "sha256:..."
  design/specs/schema/entry.md: "sha256:..."
---
  ```

### Generated Code Header

```typescript
  /* AppeusMeta:
  {
  "target": "mobile",
    "dependsOn": [
    "design/generated/mobile/screens/LogHistory.md",
    "design/specs/mobile/navigation.md"
    ],
    "depHashes": {
    "design/generated/mobile/screens/LogHistory.md": "sha256:..."
    },
  "generatedAt": "2025-12-07T12:34:56Z"
  }
  */
  ```

### Mock Meta

  ```json
  {
  "namespace": "LogEntries",
  "dependsOn": ["design/specs/api/log-entries.md"],
  "depHashes": { "design/specs/api/log-entries.md": "sha256:..." },
  "variants": ["happy", "empty", "error"]
}
```

## Notes for agent-rules and reference (not operative guidance)

- Always refresh consolidations first when dependencies changed
- Never overwrite human specs; only write consolidations and generated outputs
- For multi-target projects, derive schema before per-target generation
- After each slice, re-run `check-stale.sh` and update status
- Stop when clean or on user request

## Testing

Per slice:
- Add basic render test for the screen/page
- Add smoke test to open via deep link with variant (mobile)
- Defer E2E until several slices are ready
