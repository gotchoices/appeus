# Screens Agent Workflow

How to generate screen code from specs and consolidations.

## Paths

| Content | Single-App | Multi-App |
|---------|------------|-----------|
| Screen specs | `design/specs/screens/*.md` | `design/specs/<target>/screens/*.md` |
| Consolidations | `design/generated/screens/*.md` | `design/generated/<target>/screens/*.md` |
| Screen code | `apps/<name>/src/screens/*.tsx` | `apps/<name>/src/screens/*.tsx` |

## Principles

- Semantic-first thinking; map requirements to components
- Specs drive "how"; consolidations capture multi-story "what"
- Precedence: specs > consolidations > defaults

## Workflow

### 1. Check Spec

Look for a human spec at:
- `design/specs/screens/<screen-id>.md` (single-app)
- `design/specs/<target>/screens/<screen-id>.md` (multi-app)

If spec exists, it takes precedence.

### 2. Read Consolidation

Merge with consolidation if present:
- `design/generated/screens/<Screen>.md`
- Contains aggregated facts from stories
- Includes dependency metadata

### 3. Generate Screen Code (On Request)

When user requests regeneration:
- Apply spec slots (imports, component, styles)
- Fill gaps from consolidation
- Use framework defaults for remaining structure
- Write to `apps/<name>/src/screens/<Screen>.tsx`
- Embed AppeusMeta header

### 4. Update Navigation

Keep navigation consistent:
- Read `design/specs/navigation.md` or `design/specs/<target>/navigation.md`
- Update `apps/<name>/src/navigation/`
- Verify route names match screen outputs
- Configure deep links

## Framework-Specific Output

### React Native

```typescript
// apps/mobile/src/screens/ItemList.tsx
/* AppeusMeta: { ... } */

import React from 'react';
import { View, FlatList, StyleSheet } from 'react-native';
// ... spec imports slot ...

export function ItemList() {
  // ... spec component slot or generated body ...
}

const styles = StyleSheet.create({
  // ... spec styles slot or generated styles ...
});
```

### SvelteKit

```svelte
<!-- apps/web/src/routes/items/+page.svelte -->
<script>
  // Generated or spec-provided script
</script>

<!-- Generated or spec-provided markup -->
```

## See Also

- [Codegen Guide](codegen.md)
- [Generation Workflow](generation.md)
- [Spec Schema](spec-schema.md)
