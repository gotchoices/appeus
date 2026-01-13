# API Agent Workflow

How to derive and maintain API specs and mock data.

## Goal

Define engine-facing procedures and data shapes needed by screens and stories.

## Paths

| Content | Path | Shared? |
|---------|------|---------|
| Domain contract (human) | `design/specs/domain/*.md` | Yes |
| Mock data | `mock/data/*` | Yes |

Domain contract files are shared across targets in multi-app projects (create only what you need).

## Sources

Derive API requirements from:
- Screen specs (`design/specs/screens/*.md`)
- Stories (`design/stories/*.md`)
- Navigation spec (for route params)
- Schema specs (for data shapes)

## Outputs

- Human domain contract docs in `design/specs/domain/*.md` (e.g. `api.md`, `schema.md`)
- Mock data files in `mock/data/`
- Client adapters in `apps/<name>/src/data/`

## Workflow

### 1. Analyze Requirements

Read stories and screen specs to identify:
- What data each screen needs
- What actions each screen performs
- What shapes the data takes

### 2. Check Schema

Refer to `design/specs/domain/` for entity definitions:
- Field names and types
- Relationships
- Validation rules

### 3. Draft API Consolidation

Create `design/generated/api/<Namespace>.md`:

```yaml
---
namespace: Items
provides: ["api:Items"]
usedBy: ["screen:ItemList", "screen:ItemDetail"]
dependsOn:
  - design/specs/domain/schema.md
  - design/stories/01-browsing.md
---

## Endpoints

### List Items
- GET /items
- Params: category, search
- Returns: { items: Item[], total: number }

### Get Item
- GET /items/:id
- Returns: Item
```

### 4. Generate Mock Data

Create mock files matching API shapes:

```
mock/data/
├── items.happy.json
├── items.empty.json
├── items.error.json
└── items.meta.json
```

Meta file tracks dependencies:
```json
{
  "namespace": "Items",
  "dependsOn": ["design/specs/domain/api.md"],
  "depHashes": { ... },
  "variants": ["happy", "empty", "error"]
}
```

### 5. Update Client Adapters

Generate/update `apps/<name>/src/data/<namespace>.ts`:

```typescript
import { mockMode, getVariant } from '../mock';
import type { Item } from '../../packages/shared/schema';

export async function fetchItems(): Promise<Item[]> {
  if (mockMode) {
    const variant = getVariant();
    const data = await import(`../../../mock/data/items.${variant}.json`);
    return data.items;
  }
  return fetch('/api/items').then(r => r.json());
}
```

## Rules

1. Human API specs override consolidations
2. Mock data must match API spec shapes
3. Keep client adapters aligned with specs
4. Update mock data when API spec changes

## Multi-Target Considerations

API specs are shared across all targets:
- Mobile and web call the same endpoints
- Mock data serves all targets
- Schema types are shared via `packages/shared/`

## See Also

- [Spec Schema - API](spec-schema.md#api-spec-format)
- [Mocking Strategy](mocking.md)
- [Mock Variants](mock-variants.md)
