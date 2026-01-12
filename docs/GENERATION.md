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

Appeus tracks dependencies to answer a practical question: **what needs regeneration when an input changes?**

This section reflects v2.1 principles:
- **Human precedence**: stories/specs are authoritative; agents must not overwrite them.
- **Consolidations are the translator layer**: consolidations are regenerable and carry programmer-facing structure + dependency metadata.
- **Deterministic staleness**: generated artifacts record `dependsOn` (and hashes) so staleness can be computed reliably.

### Nodes (things we track)

- **Human inputs (authoritative)**
  - Stories: `design/stories/<target>/…`
  - Target specs: `design/specs/<target>/…` (screens/components/navigation/global)
  - Shared domain contract: `design/specs/domain/…` (schema/ops/rules/interfaces as applicable)
  - Project/toolchain spec: `design/specs/project.md` (shared; influences generation choices)
- **Generated translator artifacts (regenerable)**
  - Screen consolidations: `design/generated/<target>/screens/<Screen>.md`
- **Generated outputs**
  - App code: `apps/<target>/src/…` (framework-specific)
  - Mock data: `mock/data/…` (variants + metadata)
- **Generated metadata**
  - A per-target dependency registry under `design/generated/<target>/meta/…` used by staleness tooling.

### Relationships (typical)

- **Screen consolidation** depends on:
  - stories that reference the screen
  - target specs (screen + components + navigation + global)
  - shared domain contract assumptions
- **Generated code for a screen/page** depends on:
  - the screen consolidation (primary translator artifact)
  - any required target specs that affect wiring (navigation/global)
- **Mock data** depends on:
  - relevant domain operations/entities and mock-variant conventions

### “provides” / “needs” (conceptual)

Generated artifacts often declare what they provide and what they need. In v2.1, needs should be expressed in terms of the **domain contract** (rather than hard-coding a schema/api folder split). For example:
- provides: `screen:<target>:<Route>`
- needs: `domain:Entity:<Name>`, `domain:Op:<Name>` (and other domain primitives as applicable)

## Staleness detection (hash-based preferred; mtime fallback)

### Hash-based (preferred)

1. Compute sha256 for each `dependsOn` file
2. Compare to saved `depHashes` in the consolidation/output metadata
3. Any mismatch ⇒ stale

### Fallback (mtime-based)

When metadata is missing:
- **Inputs**: stories, target specs (screens/components/navigation/global), shared domain contract, and (when relevant) `design/specs/project.md`
- **Outputs**: consolidations, app code (and any other generated slice outputs, such as mocks)
- **Stale** if any input mtime > output mtime

## Scripts (what exists, what is optional)

This section summarizes the scripts involved in generation and staleness tracking.

| Script | Purpose | Notes |
|--------|---------|-------|
| `scripts/check-stale.sh` | Compute per-target staleness report | Primary input to deciding what to (re)generate next |
| `scripts/update-dep-hashes.sh --route <Route>` | Update dependency hashes for one route | Should not imply `--all` unless explicitly requested |
| `scripts/build-images.sh` | Capture missing/stale scenario images | Optional; used during Scenario / Peer Review |
| `scripts/preview-scenarios.sh` | Local scenario preview | Optional (human-facing) |
| `scripts/publish-scenarios.sh` | Publish scenarios as HTML | Optional; requires a publication destination |

Notes:
- Scripts operate per-target; pass `--target <name>` when a project has multiple app targets.
- If required metadata is missing or template-like, scripts should initialize/repair it for the active `<target>`.

## Metadata formats (frontmatter / JSON registries / mocks)

### Consolidation frontmatter (YAML)

Consolidations are the regenerable translator layer. They should include dependency metadata so staleness can be computed deterministically.

```yaml
---
provides: ["screen:mobile:LogHistory"]
needs: ["domain:Op:LogEntries.list", "domain:Entity:Entry"]
dependsOn:
  - design/stories/mobile/02-daily.md
  - design/specs/project.md
  - design/specs/domain/schema.md
  - design/specs/mobile/screens/log-history.md
  - design/specs/mobile/navigation.md
depHashes:
  design/stories/mobile/02-daily.md: "sha256:..."
  design/specs/project.md: "sha256:..."
  design/specs/domain/schema.md: "sha256:..."
  design/specs/mobile/screens/log-history.md: "sha256:..."
  design/specs/mobile/navigation.md: "sha256:..."
---
```

### Per-target metadata registries (JSON)

Staleness tooling may maintain per-target JSON registries under `design/generated/<target>/meta/…` as an index for “what exists” and “what is stale.” These registries are **generated metadata** and should be initialized/repaired automatically when missing, malformed, or template-like.

### Mock meta

Mock data often has a companion metadata file describing what variants exist and what inputs it was derived from.

```json
{
  "namespace": "LogEntries",
  "dependsOn": ["design/specs/domain/api.md"],
  "depHashes": { "design/specs/domain/api.md": "sha256:..." },
  "variants": ["happy", "empty", "error"]
}
```
## Notes for agent-rules and reference (design constraints for workflow docs)

These points exist to keep workflow docs consistent and to avoid confusion for agents and humans:

- Keep `agent-rules/` very **brief** and use them primarily as an index into the detailed `reference/` docs.
- Reference (`reference/`) docs cover a single topic so agent context is not encumbered with extra tokens.
- Stories and specs should be primarily human generated.  If an agent is asked to assist with them, keep the language human-readable.  Programmer-facing structure is inferred and generated into **consolidations**.
- When generating, always refresh **consolidations first** where inputs have changed; treat them as the translator layer.
- Never overwrite human specs as part of generation; only write consolidations, generated outputs, and generated metadata.
- Treat per-target JSON registries under `design/generated/<target>/meta/…` as **repairable generated metadata** (initialize/repair when missing/template-like).
- Pause after each stable slice so the user can run/test/commit before proceeding.

Artifact lanes (anti–spec creep):
- **Stories**: what happens (human narrative)
- **Specs**: how it behaves (user-observable contract; still human-readable)
- **Consolidations**: programmer-facing digest + dependency metadata (regenerable translator layer)

## Testing (per-slice expectations)

- Check with the user and/or project specifications to know if render/screen tests are required.
- If applicable, agent can recommend at least one basic render/smoke test for the screen/page when feasible.
- Prefer fast checks (lint/typecheck/unit/smoke) during slicing; defer heavier E2E until multiple slices are stable.

## Common user command intents (for workflow mapping)

Users may issue short commands. Agent workflows should map these to concrete actions:

- **“what's next?”**: identify target + phase → point to the next prerequisite or next stale slice, with minimal steps.
- **“generate” / “generate a slice” / "generate next"**: identify target → identify candidate slice → refresh consolidations/specs as needed → generate code → update dependency metadata → (optional) scenarios.
- **“generate scenarios”**: identify target → select slice(s) → generate/refresh scenario docs under `design/generated/<target>/scenarios/` → (optionally) preview/publish.
- **“generate screenshots”**: identify target → build/refresh scenario images for missing/stale scenarios (optionally using `scripts/build-images.sh`) → confirm scenarios are no longer stale.

===================================== Eventual EOF =====================================

## Old content below will be integrated into new outline above

## Phases and progression (for reviewing agent workflows)

This section is not operative “agent instruction.” Its purpose is to describe the **phase model** that `agent-rules/` and `reference/` should make observable and actionable for an agent working in a project repo.

### How an agent can detect the current phase

Primary source of truth is the per-target checklist file (e.g., a `STATUS.md` for each app target). When iterating, an agent can also look for **revisit signals** that indicate an earlier phase needs to be revisited:

- **Bootstrap/discovery revisit**
  - `design/specs/project.md` is missing/clearly incomplete, or toolchain/quality posture has changed materially.
- **Domain contract revisit**
  - Stories/specs require new or changed domain operations/entities/rules, or generation is blocked by missing domain contract details.
- **Per-target planning revisit**
  - Navigation/screens index is missing/clearly incomplete, or generation keeps thrashing due to unclear routing/screen set.
- **Slicing revisit**
  - Staleness reporting indicates slices are missing/stale, or a “fresh” slice behaves incorrectly vs the spec (spec/story needs revision).
- **Scenario/peer-review revisit**
  - Scenario docs/images are missing/stale for the current slice set, or review feedback requires story/spec changes.
- **Final wiring revisit**
  - UI slices are stable, but production wiring work requires changes to earlier specs (often domain contract + target wiring specs).

### How an agent should help progress through phases

At a high level:

- Ensure the **prerequisites of the next phase** exist (folders/files/specs), without overwriting user-authored content.
- Prefer **small, testable increments**: one slice at a time, then validate (run/test) and record the result (scenarios optional).
- When phase assumptions are violated (missing/malformed generated metadata), treat them as **repairable outputs** and rebuild rather than hand-editing.

