# Generation Workflow

Detailed reference for code generation (per target, per slice).

For staleness detection and dependency metadata, see [Staleness](staleness.md). For scenarios/screenshots, see [Scenarios](scenarios.md).

## What Goes Where (Anti-“Spec Creep” Guardrail)

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

**Inputs:**
- Stories: `design/stories/<target>/`
- Specs: `design/specs/` (screens, navigation, global, target specs, and shared `domain/` when needed)

**Outputs:**
- Consolidations: `design/generated/<target>/screens/`
- App code: `apps/<target>/src/screens/`, `apps/<target>/src/navigation/`
- Mock data: `mock/data/`

**Steps (vertical slice):**
1. Refresh screen consolidation if dependencies are stale
2. Ensure domain contract docs are adequate (as needed)
3. Generate/update mock data
4. Generate app code (screen + navigation)
5. Update staleness tracking

**Scripts:**
- Slice selection is deliberate (priority + staleness). Use `check-stale.sh` as input; see [Staleness](staleness.md).

**Trigger phrases:**
- "generate code"
- "regenerate next slice"
- "generate ItemList screen"

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
  - Run `update-dep-hashes.sh --target <target> --route <Route>`
  - Optionally rerun `check-stale.sh --target <target>` to confirm freshness

## Conventions

### Naming

| Type | Convention | Example |
|------|------------|---------|
| Route names | PascalCase | `ItemList`, `UserProfile` |
| Screen spec files | kebab-case | `item-list.md`, `user-profile.md` |
| Screen code files | PascalCase | `ItemList.tsx`, `UserProfile.tsx` |

### Mapping

Maintain in `design/specs/<target>/screens/index.md`:

```markdown
| Screen Name | Route | Spec File | Status |
|-------------|-------|-----------|--------|
| Item List | ItemList | item-list.md | draft |
| User Profile | UserProfile | user-profile.md | complete |
```

## Agent Guidance

1. Always run `check-stale.sh` before generation
2. Consolidate first if stale; then generate code
3. Never overwrite human stories or specs
4. If asked to “improve/normalize” stories or specs, keep them user-observable; put programmer-facing structure in consolidations
5. For multi-target: ensure shared domain docs under `design/specs/domain/` remain compatible across targets
6. After each slice, re-run `check-stale.sh`
7. Stop when clean or on user request

## Precedence

See: [Precedence](precedence.md)

## Multiple Targets

When multiple app targets exist, scripts accept `--target <target>` to scope operations.

## See Also

- [Workflow Overview](workflow.md)
- [Scaffold Structure](scaffold.md)
- [Codegen Details](codegen.md)
- [Staleness and Dependencies](staleness.md)
- [Scenarios and Screenshots](scenarios.md)
- [Mocking Strategy](mocking.md)
