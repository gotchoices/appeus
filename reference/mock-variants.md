# Mock Variants

How to use mock data variants for development, testing, and scenarios.

## Purpose

Variants allow scenarios to deep link into the app and select different mock data states (happy, empty, error) without affecting production builds.

## Guidelines

1. **Variants are mock-only** — Production builds ignore variant parameters
2. **Read from deep links** — Parse variant from URL, don't hardcode
3. **Isolate mock logic** — Keep in `src/mock/*`, UI reads via context

## Deep Link Format

```
<scheme>://screen/<Route>?variant=<name>
```

Examples:
```
myapp://screen/ItemList?variant=happy
myapp://screen/ItemList?variant=empty
myapp://screen/UserProfile?variant=error&id=123
```

## Standard Variants

| Variant | UI State | Data |
|---------|----------|------|
| `happy` | Normal content | Typical data set |
| `empty` | Empty state | No items, placeholder UI |
| `error` | Error state | Failed load, error message |

## Implementation

### Mock Configuration

```typescript
// src/mock/config.ts
export const mockMode = __DEV__ || process.env.MOCK_MODE === 'true';
```

### Variant Context

```typescript
// src/mock/VariantContext.tsx
import { createContext, useContext, useState, useEffect } from 'react';
import { Linking } from 'react-native';

const VariantContext = createContext({ variant: 'happy', setVariant: () => {} });

export function VariantProvider({ children }) {
  const [variant, setVariant] = useState('happy');

  useEffect(() => {
    // Parse variant from initial URL
    Linking.getInitialURL().then(url => {
      if (url) {
        const match = url.match(/variant=(\w+)/);
        if (match) setVariant(match[1]);
      }
    });

    // Listen for link events
    const sub = Linking.addEventListener('url', ({ url }) => {
      const match = url.match(/variant=(\w+)/);
      if (match) setVariant(match[1]);
    });

    return () => sub.remove();
  }, []);

  return (
    <VariantContext.Provider value={{ variant, setVariant }}>
      {children}
    </VariantContext.Provider>
  );
}

export const useVariant = () => useContext(VariantContext);
```

### Data Adapter Usage

```typescript
// src/data/items.ts
import { mockMode } from '../mock/config';
import { useVariant } from '../mock/VariantContext';

export function useItems() {
  const { variant } = useVariant();
  
  if (mockMode) {
    // Load mock data based on variant
    return useMockItems(variant);
  }
  
  // Production: call real API
  return useRealItems();
}
```

## Agent Notes

When generating code:
- Do NOT thread `variant` through production engine calls
- Pass `variant` via context/params only in mock mode
- Keep mock branching at the data adapter level, not in UI components

## Scenario Usage

Scenario docs link to specific variants:

```markdown
**Step 3: Empty State**

User sees empty state when no items exist.

[![Empty items](../images/item-list-empty.png)](myapp://screen/ItemList?variant=empty)
```

Clicking the image opens the app with that variant.

## See Also

- [Mocking Strategy](mocking.md)
- [Scenarios](scenarios.md)
- [Deep Links](codegen.md#deep-links)
