# GENERATION

How Appeus tracks dependencies, detects staleness, and generates outputs. This is a design-intent document; agents follow operative rules in `agent-rules/` and `reference/`.

## Overview

Generation in Appeus v2 operates at two levels:

1. **Shared layer** — Schema and API specs derived from stories across all targets
2. **Per-target layer** — Screens/pages, navigation, and scenarios specific to each app

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

## Core Principles

1. **Human-first precedence:** stories + specs > consolidations > defaults
2. **Schema-first for multi-target:** Derive shared schema before per-target generation
3. **Vertical slicing:** Implement one navigable screen/page at a time
4. **Deterministic generation:** consolidate → schema → api → mocks → app code → scenarios
5. **Accurate dependency tracking:** Hash-based metadata for staleness detection

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
| `regenerate.sh --screen <Route>` | Print plan for specific slice |
| `generate-next.sh` | Pick next stale screen, print plan |
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

## Agent Guidance

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

## Appendix: Progressive Structure

Appeus uses a progressive structure that starts simple and scales:

### Single-App Projects

For projects with only one app, paths are flat:

| Content | Path |
|---------|------|
| Stories | `design/stories/*.md` |
| Screen specs | `design/specs/screens/*.md` |
| Navigation | `design/specs/navigation.md` |
| Consolidations | `design/generated/screens/*.md` |
| Scenarios | `design/generated/scenarios/*.md` |
| Status | `design/generated/status.json` |

### Multi-App Projects

For projects with multiple apps, paths include target subdirectories:

| Content | Path |
|---------|------|
| Stories | `design/stories/<target>/*.md` |
| Screen specs | `design/specs/<target>/screens/*.md` |
| Navigation | `design/specs/<target>/navigation.md` |
| Consolidations | `design/generated/<target>/screens/*.md` |
| Scenarios | `design/generated/<target>/scenarios/*.md` |
| Status | `design/generated/<target>/status.json` |

Shared content (schema, API) remains at the top level in both modes.

### Path Detection

Scripts detect mode by checking for:
- Single-app: `design/specs/screens/` exists, no `design/specs/<target>/` subdirectories
- Multi-app: `design/specs/<target>/screens/` directories exist

### Adding Apps Later

When `add-app.sh` is run on a single-app project, it automatically reorganizes the folder structure to multi-app layout before creating the new app scaffold.
