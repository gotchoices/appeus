# Generation Workflow

Detailed reference for code generation, staleness detection, and dependency tracking.

## Two Workflows

### 1. Code Generation

Transform stories and specs into app code.

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
- Stories: `design/stories/` or `design/stories/<target>/`
- Specs: `design/specs/` with screens, navigation, schema, api, global

**Outputs:**
- Consolidations: `design/generated/screens/` or `design/generated/<target>/screens/`
- App code: `apps/<name>/src/screens/`, `apps/<name>/src/navigation/`
- Mock data: `mock/data/`

**Steps (vertical slice):**
1. Refresh screen consolidation if dependencies are stale
2. Refresh API consolidations if needed
3. Generate/update mock data
4. Generate app code (screen + navigation)
5. Update staleness tracking

**Scripts:**
- `check-stale.sh` — Per-screen staleness summary
- `generate-next.sh` — Pick next stale screen
- `regenerate.sh --screen <Route>` — Target specific screen

**Trigger phrases:**
- "generate code"
- "regenerate next slice"
- "generate ItemList screen"

### 2. Scenario Generation

Capture screenshots with deep links for stakeholder review.

**Inputs:**
- Running app with deep link support
- Screen routes and variants

**Outputs:**
- Screenshots: `design/generated/images/` or `design/generated/<target>/images/`
- Scenario docs: `design/generated/scenarios/` or `design/generated/<target>/scenarios/`

**Steps:**
1. Determine target images (missing or stale)
2. Capture screenshots via deep link
3. Generate scenario Markdown with embedded images
4. (Optional) Publish as HTML

**Scripts:**
- `android-screenshot.sh` — Capture single screenshot
- `build-images.sh` — Batch capture
- `preview-scenarios.sh` — Local preview
- `publish-scenarios.sh` — Publish to web

**Trigger phrases:**
- "generate scenarios"
- "refresh scenarios for ItemList"

## Staleness and Dependencies

### Dependency Metadata

Consolidations include frontmatter tracking dependencies:

```yaml
---
provides: ["screen:ItemList"]
needs: ["api:Items", "schema:Item"]
dependsOn:
  - design/stories/01-browsing.md
  - design/specs/screens/item-list.md
  - design/specs/navigation.md
  - design/specs/schema/item.md
depHashes:
  design/specs/screens/item-list.md: "sha256:abc123..."
  design/specs/schema/item.md: "sha256:def456..."
---
```

### Dependency Registry

Central tracking in `design/generated/meta/outputs.json` (single-app) or `design/generated/<target>/meta/outputs.json` (multi-app):

```json
{
  "outputs": [
    {
      "route": "ItemList",
      "output": "apps/mobile/src/screens/ItemList.tsx",
      "dependsOn": [
        "design/generated/screens/ItemList.md",
        "design/specs/screens/item-list.md",
        "design/specs/navigation.md"
      ],
      "depHashes": {
        "design/specs/screens/item-list.md": "sha256:..."
      }
    }
  ]
}
```

### Generated Code Headers

Optional inline metadata for human readers:

```typescript
/* AppeusMeta:
{
  "target": "mobile",
  "dependsOn": [
    "design/generated/screens/ItemList.md",
    "design/specs/navigation.md"
  ],
  "depHashes": { ... },
  "generatedAt": "2025-12-07T12:34:56Z"
}
*/
```

### Staleness Detection

**Hash-based (preferred):**
1. Compute sha256 for each dependsOn file
2. Compare to saved depHashes
3. Mismatch = stale

**Fallback (mtime-based):**
When metadata missing, compare file modification times:
- Inputs: stories, specs, navigation, schema
- Outputs: consolidations, app code
- Stale if any input mtime > output mtime

## Vertical Slice Selection

### Navigation Graph

Build from `design/specs/navigation.md` (single-app) or `design/specs/<target>/navigation.md` (multi-app) plus screens index.

### Selection Order

1. First stale screen reachable from root
2. Stale neighbors (navigable from fresh screens)
3. Remaining stale screens

### Definition of Stale

A screen is stale if:
- Consolidation is stale or missing
- Any output (code, mock) is stale or missing

## Generation Flow (Per Slice)

### Step 1: Screen Consolidation

Refresh `design/generated/screens/<Screen>.md`:
- Read stories that reference this screen
- Read spec if exists
- Merge with navigation and global specs
- Write consolidation with complete dependsOn/depHashes

### Step 2: API Consolidations

For each namespace in screen's `needs`:
- Refresh `design/generated/api/<Namespace>.md`
- Derive from stories, schema specs, screen specs

### Step 3: Mock Data

Generate/refresh mock files:
- `mock/data/<namespace>.happy.json`
- `mock/data/<namespace>.empty.json`
- `mock/data/<namespace>.error.json`
- `mock/data/<namespace>.meta.json` (tracks dependencies)

### Step 4: App Code

Generate screen and update navigation:
- Screen: `apps/<name>/src/screens/<Screen>.tsx` (or equivalent)
- Navigation: Update `apps/<name>/src/navigation/`
- Embed AppeusMeta header

### Step 5: Update Status

- Run `update-dep-hashes.sh --route <Route>`
- Run `check-stale.sh` to confirm freshness
- Status written to `design/generated/status.json`

## Conventions

### Naming

| Type | Convention | Example |
|------|------------|---------|
| Route names | PascalCase | `ItemList`, `UserProfile` |
| Screen spec files | kebab-case | `item-list.md`, `user-profile.md` |
| Screen code files | PascalCase | `ItemList.tsx`, `UserProfile.tsx` |

### Mapping

Maintain in `design/specs/screens/index.md`:

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
5. For multi-target: derive schema from ALL stories first
6. After each slice, re-run `check-stale.sh`
7. Stop when clean or on user request

## Precedence

Always respect:
1. **Human specs, stories** — Authoritative, never overwritten
2. **AI consolidations** — Regenerable, derived from stories, specs
3. **Defaults** — Framework conventions

## Multi-Target Considerations

For projects with multiple apps:
- Schema specs are shared; read all target stories before deriving
- API specs are shared; all targets call the same endpoints
- Each target has its own consolidations, scenarios, status
- Scripts accept `--target <name>` to scope operations

## See Also

- [Workflow Overview](workflow.md)
- [Scaffold Structure](scaffold.md)
- [Codegen Details](codegen.md)
- [Mocking Strategy](mocking.md)
