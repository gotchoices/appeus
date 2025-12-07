# Agent Rules: API

You are in `design/specs/api/`. API specs define data endpoints.

## Paths

- Specs: `specs/api/*.md` (shared)
- Consolidations: `generated/api/*.md`
- Mock data: `mock/data/*`

## Workflow

1. Analyze stories for data needs
2. Reference schema specs
3. Create API consolidation
4. Generate mock data
5. Update client adapters

## Mock Data Structure

```
mock/data/
├── items.happy.json
├── items.empty.json
└── items.error.json
```

## Reference

- [API Workflow](appeus/reference/api-agent-workflow.md)
- [Mocking](appeus/reference/mocking.md)
