# NativeScript Svelte Framework Reference

Framework-specific conventions for NativeScript Svelte targets in an Appeus project.

## Directory Structure

```
apps/<target>/
├── app/
│   ├── App.svelte          # Root component
│   ├── app.ts              # Entry point
│   ├── components/         # Reusable components
│   ├── pages/              # Page components
│   └── data/               # Data adapters
├── nativescript.config.ts  # NativeScript config
├── package.json
└── tsconfig.json
```

Pages are placed under `apps/<target>/app/pages/` and components under `apps/<target>/app/components/`.

## Navigation

NativeScript Svelte uses frame-based navigation. Page-to-page navigation should map to the routes declared in `design/specs/<target>/navigation.md` (methodology: `reference/spec-schema.md` → navigation format).

## Deep Linking

Deep link handling should be wired from `apps/<target>/app/app.ts` and should map `myapp://screen/<Route>` into the correct page for scenario/testing usage (deep link structure: `reference/codegen.md` → “Deep Links”).

## Mock mode + variants (NativeScript Svelte)

- The app has a single mock-mode switch (mock vs production).
- Variants are mock-only and are selected via deep links.
- Pages/components should not accept `variant` parameters or “know” whether data is mock vs production.
- The data layer decides mock vs production; in mock mode it consults the current variant “on the side” and loads `mock/data/<namespace>.<variant>.json`.

Variant and mock-mode methodology is defined in `reference/mock-variants.md` and `reference/mocking.md`.

