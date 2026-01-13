# Testing Strategy

Appeus methodology for testing slices as they are generated and iterated.

## What to test

Prioritize tests that protect the regeneration loop and review tooling:

- **Deep links open the correct route** (deep link structure: `reference/codegen.md` → “Deep Links”)
- **Navigation wiring is consistent** with `design/specs/<target>/navigation.md`
- **Mock mode switch works** and does not leak into production behavior (mocking: `reference/mocking.md`)
- **Variant-selected UI states work** via deep links (variants: `reference/mock-variants.md`)

## Per-slice expectations

When a slice stabilizes (user is ready to test/commit):

- **One smoke test** proving the screen renders from the data layer (mock mode allowed)
- If the slice is used in scenarios, **one deep link check** for the route (often E2E)
- If the slice introduces a new mock variant behavior, **one variant check** (happy/empty/error as applicable)

## Where tests live

Each target owns its test setup under `apps/<target>/`. Appeus does not prescribe a framework; keep the test footprint local to the target.

## Notes on variants and mocks

- Variants are **mock-only** and are selected via deep links (see `reference/mock-variants.md`).
- Screens/components should not accept `variant` parameters; the data layer decides mock vs production and, in mock mode, consults the variant “on the side”.

## When to add tests

- After a screen’s behavior matches its spec and is worth protecting from regression
- When a deep link route is added/changed (scenario/testing depends on it)
- When a bug is found manually and the fix should be locked in
