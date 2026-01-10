# GENERATION

How Appeus tracks dependencies, detects staleness, and generates outputs. This is a design-intent document; agents follow operative rules in `agent-rules/` and `reference/`.

## Overview
  Generation is the process of creating code from stories and specs.  The agent must be able to do this according to [appeus core principles](./DESIGN.md#core-principles) and the Appeus-defined workflow (explained in this file) by reading only the AGENTS.md files in the applicable folders and/or their parent folders up to the project root.

  The agent will not know every detail solely from the AGENTS.md files, but it should at least know all subjects that are available and where to find them in the exhaustive reference files when the time comes to need them.

## Working context
  An appeus project consists of [several phases](./DESIGN.md#design-phases).  Furthermore, some of these phases apply to a specific target while others are shared across the project.  Since there may be multiple targets, it will be important for the agent to know which phase and target are currently being worked on so as to guide the user effectively.

## Phases and Progression
- **Bootstrap/discovery incomplete**
  - At this point, the <project-root>/AGENTS.md file is still symlinked to agent-rules/bootstrap.md.
  - Therefore, the Agent will be focused on the instructions there until the project parameters are properly completed.
  - This phase is considered complete when the first app is added.  That script should re-point the root AGENTS.md to agent-rules/project.md whereafter the agent will be more focused on target generation.
  - When an app is created, it should be seeded with a checklist file (preferred name STATUS.md).  This contains a generic set of not-yet-completed checklist items that will indicate to the user and agent which phase of the target they are in.
- **Story Generation**
  - Some set of user stories are needed before any meaningful generation can occur and before domain contract can be designed.
  - As long as stories are incomplete or missing (according to design/stories folder and/or target checklist), the agent should strongly encourage the user to produce them.
  - If the user has input all desired stories and the agent determines they are sufficient to describe a coherent navigation and storage plan, this phase can be completed in the checklist.
- **Navigation Planning**
  - The agent may assist the user by building a minimal specs/target/navigation.md. This also implies a set of screens which can be enumerated in screens/index.md. The agent should encourage the user to review it and iterate with the agent by modifying stories and/or the navigation spec until the set of screens and the navigation spec seem complete.  This phase can then be checked off in the todo file.
- **Domain contract**
  - It is often impossible to take on this phase without first having a sufficient stories.  So even though it is a shared resource, it is listed in the target development flow.
  - If this is the first app, the domain spec will likely need to be created from scratch.
  - The agent should use the project spec to decide what documentation is needed (api, schema, etc) and work with the user to develop the needed specs. This spec should be sufficient to explain how to implement both mock and production data management.
  - If this is not the first app, care must be taken.  The domain contract must be compared to the target stories/specs for suitability.  But if it needs to be changed or augmented, the changes must be made in a way that preserves the function of previously existing apps.  Either the stories/specs in the present app must be adapted or the legacy apps must be updated.
  - When the domain spec is sufficient to support the present app, this phase may be checked off.
- **Slice iteration phase**
  - When this is the next open todo, the agent may, upon user request, proceed to generate slices.
  - Generation proceeds according to the workflow outlined below.
  - When all screens/components are at least to demonstration state, this phase may be checked off
- **Scenario/peer-review phase**
  - This phase optional phase is helpful if other team members will be reviewing the proposed screens and navigation
  - It may be that the screens so far are prototypical and all data has been mock so far
  - Based on review, the user may go back and iterate from stories again and repeat phases to refine the app
  - At the user's request, further refinements might be entered and tracked in the todo file
- **Final wiring**
  - Once UI slices are stable, further generation requests will be directed toward wiring of the production domain contract.
  - This means all data is managed, processed and stored according to the production specification.
  - This phase may also involve certain regression testing, feature addition, etc.



## Inputs and outputs (shared vs per-target)
## Generation flow (domain derivation → per-target slicing loop)
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

## Inputs and Outputs

### Shared (Cross-Target)

| Type | Location | Description |
|------|----------|-------------|
| Schema specs | `design/specs/schema/*.md` | Data model definitions |
| API specs | `design/specs/api/*.md` | Endpoint/procedure definitions |
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

## Generation Flow

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
| `generate-next.sh` | (Optional) Pick a stale screen, print a plan |
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
