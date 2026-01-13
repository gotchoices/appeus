# Mocking Strategy

How Appeus organizes mock data so agents can generate code and scenarios deterministically.

## Mock data location

Mock data lives in `mock/data/` (shared across targets):

```
mock/data/
├── items.happy.json        # Normal data
├── items.empty.json        # Empty state
├── items.error.json        # Error response
├── items.meta.json         # Metadata (dependencies, variants)
└── ...
```

## Variant selection

Variants are selected via a deep link query parameter, e.g. `myapp://screen/ItemList?variant=empty` (details and constraints: [Mock Variants](mock-variants.md)).

## Mock mode switch (one setting)

Each target app should have a single, centralized “mock mode” setting that selects between:
- **Mock mode**: data adapters load from `mock/data/*.json`
- **Production mode**: data adapters call the real backend/local store

This setting should be read by the data layer, not threaded through UI components.

## Data layer boundary (UI stays ignorant)

- Screens and components should call a stable data layer API that does not expose “mock” or “variant” parameters.
- The data layer decides where data comes from (mock vs production) based on the mock mode switch.

In mock mode, the data layer may consult the current variant (see [Mock Variants](mock-variants.md)) to choose `mock/data/<namespace>.<variant>.json`.

## Standard variants

| Variant | Purpose |
|---------|---------|
| `happy` | Normal state with typical data |
| `empty` | No data, empty state UI |
| `error` | Error response, error UI |
| `loading` | (Optional) Simulated slow response |

## Data shape alignment

Mock data should match the app’s domain contract as written in `design/specs/domain/*.md` (schema + operations + invariants), not the app’s internal types.

When the domain contract changes, the corresponding mock data should be treated as stale (staleness model: [Staleness](staleness.md)).

## Mock Metadata

Each namespace may include a `.meta.json` to document which files the mock data depends on.

```json
{
  "namespace": "items",
  "dependsOn": ["design/specs/domain/schema.md"],
  "depHashes": {
    "design/specs/domain/schema.md": "sha256:..."
  },
  "variants": ["happy", "empty", "error"]
}
```

For domain work, see the domain contract guide at `design/specs/domain/` (agent entry: `appeus/agent-rules/domain.md`).
