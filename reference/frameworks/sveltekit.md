# SvelteKit Framework Reference

Framework-specific conventions for SvelteKit apps in Appeus.

## Directory Structure

```
apps/<target>/
├── src/
│   ├── routes/            # File-based routing
│   │   ├── +page.svelte   # Home page
│   │   ├── +layout.svelte # Root layout
│   │   ├── items/
│   │   │   ├── +page.svelte
│   │   │   ├── +page.ts   # Load function
│   │   │   └── [id]/
│   │   │       ├── +page.svelte
│   │   │       └── +page.ts
│   │   └── ...
│   ├── lib/
│   │   ├── components/    # Shared components
│   │   ├── data/         # Data adapters
│   │   └── stores/       # Svelte stores
│   └── app.html          # HTML template
├── static/               # Static assets
├── package.json
├── svelte.config.js
├── vite.config.ts
└── tsconfig.json
```

## Route Pages

```svelte
<!-- apps/web/src/routes/items/+page.svelte -->

<script lang="ts">
  import type { PageData } from './$types';
  import ItemCard from '$lib/components/ItemCard.svelte';
  
  export let data: PageData;
</script>

{#if data.isLoading}
  <LoadingView />
{:else if data.error}
  <ErrorView error={data.error} />
{:else if data.items.length === 0}
  <EmptyView />
{:else}
  <div class="item-list">
    {#each data.items as item (item.id)}
      <ItemCard {item} />
    {/each}
  </div>
{/if}

<style>
  .item-list {
    display: grid;
    gap: 1rem;
  }
</style>
```

## Load Functions

```typescript
// apps/web/src/routes/items/+page.ts
import type { PageLoad } from './$types';
import { fetchItems } from '$lib/data/items';

export const load: PageLoad = async ({ url }) => {
  const variant = url.searchParams.get('variant') || 'happy';
  
  try {
    const items = await fetchItems(variant);
    return { items, variant };
  } catch (error) {
    return { error, items: [] };
  }
};
```

## Route Parameters

```typescript
// apps/web/src/routes/items/[id]/+page.ts
import type { PageLoad } from './$types';
import { fetchItem } from '$lib/data/items';

export const load: PageLoad = async ({ params, url }) => {
  const variant = url.searchParams.get('variant') || 'happy';
  const item = await fetchItem(params.id, variant);
  return { item };
};
```

## Data Adapters

```typescript
// src/lib/data/items.ts
import { dev } from '$app/environment';

const mockMode = dev;

export async function fetchItems(variant: string = 'happy') {
  if (mockMode) {
    const data = await import(`../../../mock/data/items.${variant}.json`);
    return data.default.items;
  }
  
  const res = await fetch('/api/items');
  return res.json();
}

export async function fetchItem(id: string, variant: string = 'happy') {
  if (mockMode) {
    const data = await import(`../../../mock/data/items.${variant}.json`);
    return data.default.items.find((i: any) => i.id === id);
  }
  
  const res = await fetch(`/api/items/${id}`);
  return res.json();
}
```

## Variant Handling

Variants are passed via URL query parameters:

```
/items?variant=empty
/items/123?variant=error
```

Access in load functions via `url.searchParams.get('variant')`.

## Route Mapping

Appeus screen routes map to SvelteKit file paths:

| Appeus Route | SvelteKit Path |
|--------------|----------------|
| `ItemList` | `src/routes/items/+page.svelte` |
| `ItemDetail` | `src/routes/items/[id]/+page.svelte` |
| `UserProfile` | `src/routes/profile/+page.svelte` |
| `Settings` | `src/routes/settings/+page.svelte` |

## Layout and Navigation

```svelte
<!-- src/routes/+layout.svelte -->
<script>
  import Nav from '$lib/components/Nav.svelte';
</script>

<Nav />

<main>
  <slot />
</main>

<style>
  main {
    max-width: 1200px;
    margin: 0 auto;
    padding: 1rem;
  }
</style>
```

## Testing

### Unit/Component Tests (Vitest)

```typescript
// src/lib/components/ItemCard.test.ts
import { render, screen } from '@testing-library/svelte';
import ItemCard from './ItemCard.svelte';

test('renders item name', () => {
  render(ItemCard, { props: { item: { id: '1', name: 'Test' } } });
  expect(screen.getByText('Test')).toBeTruthy();
});
```

### E2E Tests (Playwright)

```typescript
// tests/items.spec.ts
import { test, expect } from '@playwright/test';

test('shows items', async ({ page }) => {
  await page.goto('/items?variant=happy');
  await expect(page.getByText('First Item')).toBeVisible();
});

test('shows empty state', async ({ page }) => {
  await page.goto('/items?variant=empty');
  await expect(page.getByText('No items yet')).toBeVisible();
});
```

## Toolchain Options

| Option | Values | Default |
|--------|--------|---------|
| Adapter | `auto`, `node`, `static`, `vercel` | `auto` |
| Language | `ts`, `js` | `ts` |
| Package Manager | `npm`, `yarn`, `pnpm` | `npm` |

## See Also

- [Codegen Guide](../codegen.md)
- [Mock Variants](../mock-variants.md)
- [Testing Strategy](../testing.md)

