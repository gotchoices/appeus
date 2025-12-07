# Agent Rules: Specs

You are in `design/specs/`. Human-authored specs are authoritative.

## Paths

| Type | Single-App | Multi-App |
|------|------------|-----------|
| Screens | `specs/screens/*.md` | `specs/<target>/screens/*.md` |
| Navigation | `specs/navigation.md` | `specs/<target>/navigation.md` |
| Schema | `specs/schema/*.md` | `specs/schema/*.md` (shared) |
| API | `specs/api/*.md` | `specs/api/*.md` (shared) |
| Global | `specs/global/*` | `specs/<target>/global/*` |

## Precedence

1. **Specs** (human) — authoritative
2. **Consolidations** (AI) — facts from stories
3. **Defaults** — framework conventions

## Workflow

1. Read spec for constraints
2. Update consolidation to reflect spec
3. On request, generate code
4. Keep consolidations synchronized

Reference: [specs-agent-workflow.md](../reference/specs-agent-workflow.md)

## Code Slots

Specs can include code that overrides generator:

```markdown
```ts slot=imports
import { CustomComponent } from '../components';
```
```

Available: `imports`, `component`, `styles`

## Naming

- Spec filenames: kebab-case (`item-list.md`, `user-profile.md`)
- Routes: PascalCase (`ItemList`, `UserProfile`)
- Mapping in `design/specs/screens/index.md`

## Regeneration

After spec changes:
1. Consolidation becomes stale
2. Refresh consolidation
3. Then regenerate code

Use `appeus/scripts/check-stale.sh` to verify.

## References

- [Spec Schema](../reference/spec-schema.md)
- [Generation](../reference/generation.md)
- [Codegen](../reference/codegen.md)
