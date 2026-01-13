# React Native Framework Reference

Framework-specific conventions for React Native apps in Appeus.

## Directory Structure

```
apps/<target>/
├── src/
│   ├── screens/           # Screen components
│   ├── navigation/        # React Navigation setup
│   │   ├── index.tsx      # Navigator configuration
│   │   ├── linking.ts     # Deep link config
│   │   └── types.ts       # Route type definitions
│   ├── components/        # Shared components
│   ├── data/             # Data adapters
│   ├── mock/             # Mock mode config
│   │   ├── config.ts
│   │   ├── VariantContext.tsx
│   │   └── index.ts
│   └── theme/            # Theme configuration
├── android/              # Android native code
├── ios/                  # iOS native code
├── package.json
├── app.json              # or app.config.ts
└── tsconfig.json
```

## Screen Components

```typescript
// apps/mobile/src/screens/ItemList.tsx

import React from 'react';
import { View, FlatList, StyleSheet, Text } from 'react-native';

import { useItems } from '../data/items';
import { ItemCard } from '../components/ItemCard';

export function ItemList() {
  const { items, isLoading, error } = useItems();

  if (isLoading) return <LoadingView />;
  if (error) return <ErrorView error={error} />;
  if (items.length === 0) return <EmptyView />;

  return (
    <FlatList
      data={items}
      renderItem={({ item }) => <ItemCard item={item} />}
      keyExtractor={(item) => item.id}
    />
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
```

## Navigation Setup

### Navigator Configuration

```typescript
// src/navigation/index.tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { linking } from './linking';

const Stack = createNativeStackNavigator();

export function Navigation() {
  return (
    <NavigationContainer linking={linking}>
      <Stack.Navigator>
        <Stack.Screen name="ItemList" component={ItemList} />
        <Stack.Screen name="ItemDetail" component={ItemDetail} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Deep Link Configuration

```typescript
// src/navigation/linking.ts
export const linking = {
  prefixes: ['myapp://'],
  config: {
    screens: {
      ItemList: 'screen/ItemList',
      ItemDetail: {
        path: 'screen/ItemDetail',
        parse: {
          id: (id: string) => id,
          variant: (variant: string) => variant,
        },
      },
    },
  },
};
```

## Mock Variant Context

```typescript
// src/mock/VariantContext.tsx
import React, { createContext, useContext, useState, useEffect } from 'react';
import { Linking } from 'react-native';

interface VariantContextType {
  variant: string;
  setVariant: (v: string) => void;
}

const VariantContext = createContext<VariantContextType>({
  variant: 'happy',
  setVariant: () => {},
});

export function VariantProvider({ children }: { children: React.ReactNode }) {
  const [variant, setVariant] = useState('happy');

  useEffect(() => {
    Linking.getInitialURL().then(url => {
      if (url) {
        const match = url.match(/variant=(\w+)/);
        if (match) setVariant(match[1]);
      }
    });

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

## Data Adapter Pattern

```typescript
// src/data/items.ts
import { useQuery } from '@tanstack/react-query'; // or useState/useEffect
import { mockMode } from '../mock/config';
import { useVariant } from '../mock/VariantContext';

export function useItems() {
  const { variant } = useVariant();

  return useQuery({
    queryKey: ['items', variant],
    queryFn: async () => {
      if (mockMode) {
        const data = await import(`../../mock/data/items.${variant}.json`);
        return data.default;
      }
      return fetch('/api/items').then(r => r.json());
    },
  });
}
```

## Testing

### Component Tests (RNTL)

```typescript
import { render, screen } from '@testing-library/react-native';
import { ItemList } from '../ItemList';

test('renders items', () => {
  render(<ItemList />);
  expect(screen.getByText('First Item')).toBeTruthy();
});
```

### E2E Tests (Detox)

```typescript
describe('ItemList', () => {
  it('opens via deep link', async () => {
    await device.openURL({ url: 'myapp://screen/ItemList?variant=happy' });
    await expect(element(by.id('item-list'))).toBeVisible();
  });
});
```

## Toolchain Options

| Option | Values | Default |
|--------|--------|---------|
| Runtime | `bare`, `expo` | `bare` |
| Language | `ts`, `js` | `ts` |
| Navigation | `react-navigation`, `expo-router` | `react-navigation` |
| State | `zustand`, `redux`, `jotai` | `zustand` |

## See Also

- [Codegen Guide](../codegen.md)
- [Mock Variants](../mock-variants.md)
- [Testing Strategy](../testing.md)

