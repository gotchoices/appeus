# Specs Agent Workflow

How to process human-authored specs and keep consolidations synchronized.

This doc is intentionally focused on spec handling only. For the overall per-slice loop, see [Workflow](workflow.md) and [Precedence](precedence.md).

## Paths

| Type | Canonical Path (v2.1) |
|------|------------------------|
| Screen specs | `design/specs/<target>/screens/*.md` |
| Navigation | `design/specs/<target>/navigation.md` |
| Domain contract (as needed) | `design/specs/domain/*.md` |
| Global | `design/specs/<target>/global/*` |

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
- Update `design/generated/<target>/screens/<Route>.md`
- Include spec in dependsOn
- Ensure the per-target registry exists and reflects the slice’s `dependsOn`: `design/generated/<target>/meta/outputs.json`

### 3. Generate Code (On Request)

When user requests regeneration:
- Read spec and consolidation
- Apply spec slots to generated code
- Write to `apps/<target>/src/` (framework-specific)
- Update navigation

### 4. Keep Synchronized

After any spec change:
- Consolidation becomes stale
- Regenerate consolidation before codegen
- Run `check-stale.sh --target <target>` to verify

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
