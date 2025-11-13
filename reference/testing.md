# Testing Strategy (Appeus)

Purpose: Catch regressions as the app evolves, especially around deep linking, navigation, and mock variants, while keeping tests pragmatic and fast.

Test layers
- Unit (Jest): pure functions (e.g., variant parsing, adapters). Fastest feedback.
- Component (React Native Testing Library): screens/components with mocked data and navigation; assert accessibility and behavior.
- End‑to‑End (Detox): device-level flows (launch, deep links, navigation, variant-driven mocks). Runs on Android emulator and iOS simulator with the same test suite.

When to add tests
- Before: for utilities or tricky logic where a unit test guides correct implementation (TDD‑style).
- Right after: when a UI flow stabilizes or a manual test reveals a bug—lock behavior with a component or e2e test.
- On regressions: write a failing test first, then fix; keep it in the suite.

Detox guidance
- Use platform‑agnostic testIDs for selectors; avoid relying on timing or platform chrome.
- Provide helpers that abstract deep link invocation (adb vs simctl) so one spec runs on both platforms.
- Keep mockMode deterministic; variants come from deep links only (see mock-variants.md).

Agent notes
- Propose tests at natural boundaries (new screen wired, deep link added, variant behavior fixed).
- Default to Android first for e2e (faster CI setup), then iOS when requested.
- Keep tests minimal and high-signal; prefer a few robust checks over brittle pixel assertions.


