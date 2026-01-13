# Navigation Agent Workflow

How to generate navigation code from specs.

## Paths

| Content | Canonical Path (v2.1) |
|---------|------------------------|
| Navigation spec | `design/specs/<target>/navigation.md` |
| Navigation code | `apps/<target>/src/navigation/*` (framework-specific) |

## Inputs

- Human navigation spec (authoritative)
- Screen specs (for route details)
- AI consolidation (if present, lower precedence)

## Outputs

- Navigation structure: `apps/<name>/src/navigation/index.tsx`
- Deep link config: `apps/<name>/src/navigation/linking.ts`
- Route types: `apps/<name>/src/navigation/types.ts`

## Rules

1. Human spec takes precedence over any consolidation
2. Deep link routing must match app config
3. Route names must match screen component names

## Workflow

### 1. Read Navigation Spec

Parse `design/specs/<target>/navigation.md` for:
- Sitemap structure (tabs, stacks)
- Route definitions
- Deep link patterns
- Route options (titles, headers)

### 2. Merge with Consolidation

If `design/generated/navigation.md` exists:
- Use for additional context
- Spec overrides consolidation

### 3. Generate Navigation Code

Create/update navigation files:

```typescript
// apps/mobile/src/navigation/index.tsx
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

// Tab navigator
const Tab = createBottomTabNavigator();

// Stack navigators
const MainStack = createNativeStackNavigator();

// ... configure navigators based on spec
```

### 4. Configure Deep Links

Generate linking configuration:

```typescript
// apps/mobile/src/navigation/linking.ts
export const linking = {
  prefixes: ['myapp://'],
  config: {
    screens: {
      ItemList: 'screen/ItemList',
      ItemDetail: 'screen/ItemDetail',
      // ... from spec
    },
  },
};
```

### 5. Verify Consistency

- Route names match screen exports
- Deep links work with variant params
- Navigation structure matches sitemap

## Deep Link Format

```
<scheme>://screen/<Route>?variant=<name>&<params>
```

Include in generated linking:
- `variant` — Mock data variant
- `scenario` — Scenario tracking ID
- Route-specific params (id, etc.)

## Framework-Specific

### React Native

Uses React Navigation with:
- Stack navigators
- Tab navigators
- Deep linking via Linking API

### SvelteKit

Uses file-based routing:
- `src/routes/` structure
- `+page.svelte` files
- URL params for variants

## See Also

- [Spec Schema - Navigation](spec-schema.md#navigation-spec-format)
- [Codegen Guide - Deep Links](codegen.md#deep-links)
- [Mock Variants](mock-variants.md)
