# Generation Workflow

Appeus methodology for code generation (per target, per slice).

For staleness detection and dependency metadata, see [Staleness](staleness.md). For scenarios/screenshots, see [Scenarios](scenarios.md).

## Artifact Lanes (anti “spec creep”)

Appeus works best when each artifact stays in its lane:

| Artifact | Audience | Content (intent) | Avoid |
|----------|----------|------------------|-------|
| **Stories** (`design/stories/…`) | Humans | **What happens** (user narrative) | UI implementation detail |
| **Specs** (`design/specs/…`) | Humans | **How it behaves**, still **user-observable** (rules, states, acceptance) | Programmer-facing APIs, class diagrams, exhaustive internal state machines |
| **Consolidations** (`design/generated/…`) | Agents/engineers | **Programmer mapping**: how we’ll implement from specs + stories (components, events, data adapters, routing) + dependency metadata | Overwriting or “upgrading” human specs |

**Rule:** If a spec is getting hard for the human to read, stop and move “programmer-structure” detail into the consolidation instead.

Before committing to “quick and simple” vs “scalable and robust” implementations, consult `design/specs/project.md` for the project’s delivery posture and quality/performance expectations.

### Example (Where to put it)

- “User can filter transactions by account; filter persists while the page is open.” → **spec**
- “Implement filter persistence via store + URL params + debounce.” → **consolidation**
- “Component `AccountAutocomplete` exposes `onSelect(accountId)`.” → **consolidation**

## Inputs
- Stories: `design/stories/<target>/`
- Specs: `design/specs/` (screens, navigation, global, target specs, and shared `domain/` when needed)

## Outputs
- Consolidations: `design/generated/<target>/screens/`
- App code: `apps/<target>/src/screens/`, `apps/<target>/src/navigation/`
- Mock data: `mock/data/`

## Slice selection (input to generation)

Slice selection is deliberate (priority + staleness). Use `appeus/scripts/check-stale.sh --target <target>` as input; see [Staleness](staleness.md) for how staleness is computed.

## Generation Flow (Per Slice)

### Step 1: Screen Consolidation

Refresh `design/generated/<target>/screens/<Route>.md`:
- Read stories that reference this screen
- Read spec if exists
- Merge with navigation and global specs
- Write consolidation with complete dependsOn/depHashes

### Step 2: Domain Contract (as needed)

Ensure shared domain docs under `design/specs/domain/` are adequate for this slice.

### Step 3: Mock Data

Generate/refresh mock files:
- `mock/data/<namespace>.happy.json`
- `mock/data/<namespace>.empty.json`
- `mock/data/<namespace>.error.json`
- `mock/data/<namespace>.meta.json` (tracks dependencies)

### Step 4: App Code

Generate screen and update navigation:
- Screen: `apps/<target>/src/screens/<Screen>.tsx` (or equivalent)
- Navigation: Update `apps/<target>/src/navigation/`

### Step 5: Update Status

- Update dependency metadata:
  - Run `appeus/scripts/update-dep-hashes.sh --target <target> --route <Route>`
  - Optionally rerun `appeus/scripts/check-stale.sh --target <target>` to confirm freshness

When multiple app targets exist, `--target <target>` scopes generation scripts (see [Workflow Overview](workflow.md)).
