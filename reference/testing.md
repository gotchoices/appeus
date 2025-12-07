# Testing Strategy

How to test apps built with Appeus.

## Purpose

Catch regressions as the app evolves, especially around:
- Deep linking
- Navigation
- Mock variants
- Data adapters

Keep tests pragmatic and fast.

## Test Layers

### Unit Tests (Jest)

**Scope:** Pure functions, utilities, data transformations

**Examples:**
- Variant parsing from URLs
- Data adapter logic
- Formatting utilities

**Location:** `apps/<name>/__tests__/` or colocated `*.test.ts`

```typescript
// apps/mobile/src/utils/__tests__/variant.test.ts
import { parseVariant } from '../variant';

test('parses variant from URL', () => {
  expect(parseVariant('myapp://screen/ItemList?variant=empty')).toBe('empty');
});

test('defaults to happy when no variant', () => {
  expect(parseVariant('myapp://screen/ItemList')).toBe('happy');
});
```

### Component Tests (React Native Testing Library)

**Scope:** Screens and components with mocked data

**Focus:**
- Rendering correctness
- User interactions
- Accessibility

**Location:** `apps/<name>/src/screens/__tests__/`

```typescript
// apps/mobile/src/screens/__tests__/ItemList.test.tsx
import { render, screen } from '@testing-library/react-native';
import { ItemList } from '../ItemList';
import { mockItems } from '../../../mock/data/items.happy.json';

test('renders item names', () => {
  render(<ItemList items={mockItems} />);
  expect(screen.getByText('First Item')).toBeTruthy();
});

test('shows empty state when no items', () => {
  render(<ItemList items={[]} />);
  expect(screen.getByText('No items yet')).toBeTruthy();
});
```

### End-to-End Tests (Detox)

**Scope:** Full device flows

**Focus:**
- App launch
- Deep links
- Navigation
- Variant-driven mocks

**Location:** `apps/<name>/e2e/`

```typescript
// apps/mobile/e2e/itemList.e2e.ts
describe('Item List', () => {
  beforeAll(async () => {
    await device.launchApp();
  });

  it('shows items via deep link', async () => {
    await device.openURL({ url: 'myapp://screen/ItemList?variant=happy' });
    await expect(element(by.id('item-list'))).toBeVisible();
    await expect(element(by.text('First Item'))).toBeVisible();
  });

  it('shows empty state', async () => {
    await device.openURL({ url: 'myapp://screen/ItemList?variant=empty' });
    await expect(element(by.text('No items yet'))).toBeVisible();
  });
});
```

## When to Add Tests

| Trigger | Test Type | Rationale |
|---------|-----------|-----------|
| New utility function | Unit | Validate logic before integration |
| Screen stabilizes | Component | Lock down rendering behavior |
| Deep link added | E2E | Verify navigation works |
| Bug found manually | Any | Prevent regression |
| Variant behavior fixed | E2E | Ensure mock selection works |

## Detox Guidelines

1. **Platform-agnostic testIDs** — Use `testID` props, not platform-specific selectors
2. **Abstract deep links** — Helper functions that work on both Android and iOS
3. **Deterministic mocks** — Variants come from deep links only (see mock-variants.md)
4. **Avoid timing issues** — Use Detox's built-in synchronization

### Cross-Platform Helpers

```typescript
// e2e/helpers/deepLink.ts
export async function openDeepLink(path: string) {
  const url = `myapp://screen/${path}`;
  await device.openURL({ url });
}

export async function openWithVariant(route: string, variant: string) {
  await openDeepLink(`${route}?variant=${variant}`);
}
```

## Multi-Target Testing

For projects with multiple apps:

| Target | Unit/Component | E2E |
|--------|---------------|-----|
| Mobile (RN) | Jest + RNTL | Detox |
| Web (SvelteKit) | Vitest + Testing Library | Playwright |

Each target has its own test configuration in `apps/<name>/`.

## CI Integration

### React Native (Mobile)

```yaml
# .github/workflows/test-mobile.yml
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install deps
        run: cd apps/mobile && yarn install
      - name: Unit tests
        run: cd apps/mobile && yarn test
      - name: E2E tests
        run: cd apps/mobile && yarn e2e:build && yarn e2e:test
```

### SvelteKit (Web)

```yaml
# .github/workflows/test-web.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install deps
        run: cd apps/web && npm install
      - name: Unit tests
        run: cd apps/web && npm test
      - name: E2E tests
        run: cd apps/web && npx playwright test
```

## Agent Notes

1. Propose tests at natural boundaries (new screen, deep link, variant)
2. Default to Android first for mobile E2E (faster CI)
3. Keep tests minimal and high-signal
4. Avoid brittle pixel assertions
5. Prefer accessibility queries over implementation details

## See Also

- [Mock Variants](mock-variants.md)
- [Scenarios](scenarios.md)
- [Deep Links](codegen.md#deep-links)
