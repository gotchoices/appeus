# Agent Rules: Specs

You are in `design/specs/`. Human-authored specs are authoritative.

## Guardrail (Keep Specs Human-Readable)

Specs are a **user-observable UX contract**. If you find yourself writing programmer-facing structure, put it in consolidations (`design/generated/…`) instead.

## Paths

| Type | Location |
|------|----------|
| Screens | `specs/screens/*.md` or `specs/<target>/screens/*.md` |
| Components | `specs/components/*.md` or `specs/<target>/components/*.md` |
| Navigation | `specs/navigation.md` or `specs/<target>/navigation.md` |
| Domain contract (as needed) | `specs/domain/*.md` (shared) |

## Code Slots

Specs can include code that overrides generator:

```markdown
```ts slot=imports
import { CustomComponent } from '../components';
```
```

Available: `imports`, `component`, `styles`

## Naming

- Filenames: kebab-case (`item-list.md`)
- Routes: PascalCase (`ItemList`)
- Mapping: `specs/screens/index.md`

## After Changes

Spec changes make consolidations stale. Refresh consolidation before regenerating code.

## Reference

- [Spec Schema](appeus/reference/spec-schema.md)
- [Specs Workflow](appeus/reference/specs-agent-workflow.md)
- [Screens workflow](appeus/reference/screens-agent-workflow.md)
- [Navigation workflow](appeus/reference/navigation-agent-workflow.md)
