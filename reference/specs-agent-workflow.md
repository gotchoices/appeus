# Specs Agent Workflow

How to process human-authored specs and keep consolidations synchronized.

## Paths

| Type | Single-App | Multi-App |
|------|------------|-----------|
| Screen specs | `design/specs/screens/*.md` | `design/specs/<target>/screens/*.md` |
| Navigation | `design/specs/navigation.md` | `design/specs/<target>/navigation.md` |
| Schema | `design/specs/schema/*.md` | `design/specs/schema/*.md` (shared) |
| API | `design/specs/api/*.md` | `design/specs/api/*.md` (shared) |
| Global | `design/specs/global/*` | `design/specs/<target>/global/*` |

## Principles

- Specs are human-authored Markdown
- Specs override consolidations and defaults
- Code slots in specs override generator output

## Workflow

### 1. Read Spec

Parse the spec for:
- Frontmatter (id, route, variants, etc.)
- Layout and behavior descriptions
- Code slots (imports, component, styles)
- Dependencies (needs, provides)

### 2. Update Consolidations

Refresh the corresponding consolidation to reflect spec constraints:
- Update `design/generated/screens/<id>.md`
- Include spec in dependsOn
- Update depHashes

### 3. Generate Code (On Request)

When user requests regeneration:
- Read spec and consolidation
- Apply spec slots to generated code
- Write to `apps/<name>/src/screens/`
- Update navigation

### 4. Keep Synchronized

After any spec change:
- Consolidation becomes stale
- Regenerate consolidation before codegen
- Run `check-stale.sh` to verify

## Code Slots

Specs can include code blocks that override generator defaults:

```markdown
```ts slot=imports
import { CustomHook } from '../hooks/useCustom';
```

```tsx slot=component
export function MyScreen() {
  // Custom implementation
}
```
```

Available slots:
- `imports` — Additional import statements
- `component` — Full component body
- `styles` — StyleSheet definitions

## See Also

- [Spec Schema](spec-schema.md)
- [Generation Workflow](generation.md)
- [Codegen Guide](codegen.md)
