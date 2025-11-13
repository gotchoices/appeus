# Mock Variants (Appeus)

Purpose: allow scenarios to deep link into the app and select mock data variants (e.g., `happy`, `empty`, `error`) without impacting production builds.

Guidelines
- Variants exist only in mock mode; production builds should ignore variants.
- Read variant from deep links (e.g., `chat://connections?variant=empty`) rather than hard-coding values in source.
- Keep mock/variant logic in `src/mock/*`; UI reads from a small context/provider.

Reference implementation sketch
- `src/mock/config.ts`: `export const mockMode = true` (toggled by build/env).
- `src/mock/VariantContext.tsx`: provides `{ mockMode, variant, setVariant }`, parses `variant` from `Linking.getInitialURL()` and link events.
- Data adapters branch:
  - if (mockMode) use mock repository with `variant`
  - else call engine APIs

Agent notes
- When regenerating, do not thread `variant` through production engine calls.
- Prefer passing `variant` via context/params only in mock mode.


