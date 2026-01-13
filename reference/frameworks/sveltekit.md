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

## Variant Handling

Variants are mock-only. If variants are used for deterministic UI states in the web target, treat them as a mock-only side-channel (stored globally/mock-only) and keep standard data access APIs free of `variant` parameters (methodology: `reference/mock-variants.md` and `reference/mocking.md`).

## Route Mapping

Appeus screen routes map to SvelteKit file paths:

| Appeus Route | SvelteKit Path |
|--------------|----------------|
| `ItemList` | `src/routes/items/+page.svelte` |
| `ItemDetail` | `src/routes/items/[id]/+page.svelte` |
| `UserProfile` | `src/routes/profile/+page.svelte` |
| `Settings` | `src/routes/settings/+page.svelte` |

