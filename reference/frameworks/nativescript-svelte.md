# NativeScript Svelte Framework Guide

This document provides specific guidance for generating NativeScript Svelte applications within an Appeus project.

## Overview

NativeScript Svelte (Svelte Native) combines Svelte's reactive component model with NativeScript's native mobile capabilities. It provides truly native iOS and Android apps using Svelte syntax.

## Project Structure

```
apps/<name>/
├── app/
│   ├── App.svelte          # Root component
│   ├── app.ts              # Entry point
│   ├── components/         # Reusable components
│   ├── pages/              # Page components
│   ├── services/           # Business logic
│   └── data/               # Data adapters
├── nativescript.config.ts  # NativeScript config
├── package.json
└── tsconfig.json
```

## Codegen Conventions

### Components

- Components: PascalCase (`UserProfile.svelte`)
- Pages: PascalCase in `pages/` folder
- Use `.svelte` extension

### Navigation

NativeScript Svelte uses frame-based navigation:

```svelte
<script>
  import { navigate } from 'svelte-native'
  import DetailPage from './pages/DetailPage.svelte'
  
  function goToDetail() {
    navigate({ page: DetailPage, props: { id: '123' } })
  }
</script>
```

### Native Components

Use NativeScript components with Svelte syntax:

```svelte
<page>
  <actionBar title="My App" />
  <stackLayout>
    <label text="Hello World" />
    <button text="Tap Me" on:tap={handleTap} />
  </stackLayout>
</page>
```

## Deep Linking

NativeScript handles deep links via the application module:

```typescript
// app/app.ts
import { Application } from '@nativescript/core'

Application.on('customUrlScheme', (args) => {
  const url = args.url // e.g., myapp://screen/UserProfile?variant=happy
  // Parse and navigate
})
```

### URL Format

```
myapp://screen/<PageName>?variant=<name>&param=value
```

## Mock Variants

Handle variants via URL parameters or app state:

```svelte
<script>
  import { onMount } from 'svelte'
  import { getMockData } from '../data/mockAdapter'
  
  export let variant = 'happy'
  
  let data = []
  
  onMount(async () => {
    data = await getMockData('items', variant)
  })
</script>
```

### Data Adapter Pattern

```typescript
// app/data/mockAdapter.ts
import { Http } from '@nativescript/core'

const MOCK_SERVER = 'http://localhost:3456'

export async function getMockData(namespace: string, variant: string) {
  const response = await Http.getJSON(`${MOCK_SERVER}/${namespace}.${variant}.json`)
  return response
}
```

## Styling

NativeScript uses CSS with some platform-specific properties:

```svelte
<style>
  .title {
    font-size: 24;
    font-weight: bold;
    color: #333;
  }
  
  .container {
    padding: 16;
    background-color: #fff;
  }
</style>
```

## State Management

Use Svelte stores for state:

```typescript
// app/stores/user.ts
import { writable } from 'svelte/store'

export const currentUser = writable(null)
export const isLoading = writable(false)
```

```svelte
<script>
  import { currentUser } from '../stores/user'
</script>

{#if $currentUser}
  <label text={$currentUser.name} />
{/if}
```

## Platform-Specific Code

Use NativeScript's platform detection:

```svelte
<script>
  import { isIOS, isAndroid } from '@nativescript/core'
</script>

{#if isIOS}
  <label text="iOS specific" />
{:else if isAndroid}
  <label text="Android specific" />
{/if}
```

## Running the App

```bash
# Preview on device (via NativeScript Playground app)
ns preview

# Run on iOS simulator
ns run ios

# Run on Android emulator
ns run android

# Build for production
ns build ios --release
ns build android --release
```

## Common Issues

### Environment Setup

Run `ns doctor` to verify your environment is configured correctly.

### Hot Reload

NativeScript Svelte supports hot module replacement. If changes aren't reflecting, try:
```bash
ns clean
ns run <platform>
```

## See Also

- [Svelte Native Documentation](https://svelte.nativescript.org/)
- [NativeScript Documentation](https://docs.nativescript.org/)
- [Mock Variants](../mock-variants.md)
- [Generation Workflow](../generation.md)

