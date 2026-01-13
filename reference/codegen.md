# Code Generation Guide

Appeus methodology for generating app code from stories/specs via consolidations.

## Inputs

### Human Specs (Authoritative)

| Type | Canonical Path |
|------|------------------------|
| Screen specs | `design/specs/<target>/screens/*.md` |
| Component specs | `design/specs/<target>/components/*.md` |
| Navigation | `design/specs/<target>/navigation.md` |
| Domain contract (as needed) | `design/specs/domain/*.md` |
| Global | `design/specs/<target>/global/*` |

### AI Consolidations (Regenerable)

| Type | Canonical Path |
|------|------------------------|
| Screen consolidations | `design/generated/<target>/screens/*.md` |

## Outputs

| Type | Path |
|------|------|
| Screen code | `apps/<target>/src/screens/<Screen>.tsx` |
| Navigation | `apps/<target>/src/navigation/*` |
| Data adapters | `apps/<target>/src/data/*` |
| Mock data | `mock/data/<namespace>.<variant>.json` |

## Rules

1. **Human specs override consolidations** — Always check for a spec before using consolidation
2. **Idempotent writes** — Only change files when inputs have changed
3. **Human-triggered only** — Don't write unless user requests regeneration
4. **Track metadata** — Keep dependency metadata in consolidation frontmatter and `design/generated/<target>/meta/outputs.json` (not in source headers); scripts can seed missing registry entries, but the agent must keep `dependsOn` meaningful
5. **Vertical slicing** — Generate one screen at a time (selected deliberately via priorities + staleness from `appeus/scripts/check-stale.sh --target <target>`)

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Screen spec file | kebab-case | `item-list.md`, `user-profile.md` |
| Screen code file | PascalCase | `ItemList.tsx`, `UserProfile.tsx` |
| Route name | PascalCase | `ItemList`, `UserProfile` |

### Mapping Example

```
spec: item-list.md → route: ItemList → file: ItemList.tsx
spec: user-profile.md → route: UserProfile → file: UserProfile.tsx
```

## Avoid “Spec Creep”

Specs are for humans and should stay **user-observable**. Don’t embed source-code overrides in specs.

If you need programmer-facing structure (types, modules, adapters, event wiring), put it in the consolidation under `design/generated/<target>/`.

## Deep Links

Format: `<scheme>://screen/<RouteName>?scenario=<id>&variant=<name>`

Examples:
```
myapp://screen/ItemList?variant=happy
myapp://screen/UserProfile?variant=empty&id=123
```

Parameters:
- `scenario` — Scenario identifier for tracking
- `variant` — Mock data variant (happy, empty, error)
- Additional params as needed by the screen

## Dependency Tracking

Dependency tracking lives in per-target JSON metadata under:

- `design/generated/<target>/meta/outputs.json`

This keeps source files free of injected metadata and allows scripts to repair/init missing registries automatically.

## Framework-Specific Output

### React Native

```
apps/<target>/src/
├── screens/
│   ├── ItemList.tsx
│   └── UserProfile.tsx
├── navigation/
│   ├── index.tsx
│   └── linking.ts
├── components/
├── data/
└── mock/
```

### SvelteKit

```
apps/<target>/src/
├── routes/
│   ├── items/
│   │   └── +page.svelte
│   └── profile/
│       └── +page.svelte
├── lib/
│   ├── components/
│   └── data/
└── ...
```

## Agent Guidance

1. Check for human spec before reading consolidation
2. Treat specs as human-readable constraints; put programmer mapping into consolidations
3. Maintain navigation consistency with `design/specs/<target>/navigation.md`
4. After writing code, update staleness metadata via `appeus/scripts/update-dep-hashes.sh --target <target> --route <Route>` (method: [Generation](generation.md))
5. If asked to verify, rerun `appeus/scripts/check-stale.sh --target <target>` (staleness model: [Staleness](staleness.md))
