# Agent Rules: API

You are in `design/specs/api/`. API specs define data endpoints.

## Paths

- Specs: `design/specs/api/*.md` (shared across targets)
- Consolidations: `design/generated/api/*.md`
- Mock data: `mock/data/*`

## Purpose

Define engine-facing procedures and data shapes needed by screens.

## Workflow

1. Analyze stories and screen specs for data needs
2. Reference schema specs for entity shapes
3. Create/update API consolidation
4. Generate mock data matching shapes
5. Update client adapters in `apps/<name>/src/data/`

Reference: [api-agent-workflow.md](../reference/api-agent-workflow.md)

## API Spec Format

```yaml
---
id: items
namespace: Items
---

## Endpoints

### GET /items
List items with optional filtering.

**Response:**
{ items: Item[], total: number }
```

## Rules

- Human API specs override consolidations
- Keep mock data aligned with spec shapes
- API is shared across all targets

## Mock Data

```
mock/data/
├── items.happy.json
├── items.empty.json
├── items.error.json
└── items.meta.json
```

## References

- [API Workflow](../reference/api-agent-workflow.md)
- [Mocking](../reference/mocking.md)
- [Spec Schema - API](../reference/spec-schema.md#api-spec-format)
