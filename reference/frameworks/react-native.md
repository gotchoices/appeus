# React Native Framework Reference

Framework-specific conventions for React Native targets in an Appeus project.

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
│   ├── mock/             # Mock mode + variant side-channel (mock-only)
│   └── theme/            # Theme configuration
├── android/              # Android native code
├── ios/                  # iOS native code
├── package.json
├── app.json              # or app.config.ts
└── tsconfig.json
```

## Navigation Setup

React Navigation wiring lives under `apps/<target>/src/navigation/`.

### Deep Link Configuration

Deep link configuration lives under `apps/<target>/src/navigation/linking.ts`. It should map `myapp://screen/<Route>` into the correct screen for scenario/testing usage (deep link structure: `reference/codegen.md` → “Deep Links”).

## Mock mode + variants (React Native)

Mocking is a cross-cutting concern used for deterministic UI states (screenshots/testing). Keep these rules:

- The app has a single mock-mode switch (mock vs production).
- Variants are mock-only and are selected via deep links.
- Screens/components should not accept `variant` parameters or “know” whether data is mock vs production.
- The data layer decides mock vs production; in mock mode it consults the current variant “on the side”.

Variant and mock-mode methodology is defined in `reference/mock-variants.md` and `reference/mocking.md`.

