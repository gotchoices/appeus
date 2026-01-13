# Mock Variants

How to use mock data variants for scenarios and deterministic UI states.

## Purpose

Variants allow scenarios to deep link into the app and select different mock data states (happy, empty, error) without affecting production builds.

## Guidelines

1. **Variants are mock-only** — Production builds ignore variant parameters
2. **Selected only via deep links** — Parse variant from the deep link URL; do not select via other channels
3. **Not part of data interfaces** — Do not add `variant` parameters to standard data access functions
4. **Isolate mock logic** — Keep variant branching at the data adapter boundary (not in UI components)

## Deep Link Format

```
<scheme>://screen/<Route>?variant=<name>
```

Examples:
```
myapp://screen/ItemList?variant=happy
myapp://screen/ItemList?variant=empty
myapp://screen/UserProfile?variant=error&id=123
```

## Standard Variants

| Variant | UI State | Data |
|---------|----------|------|
| `happy` | Normal content | Typical data set |
| `empty` | Empty state | No items, placeholder UI |
| `error` | Error state | Failed load, error message |

## Method (Appeus)

Variants are a side-channel used for deterministic UI states (screenshots/tests). The method is:

1. The deep link is parsed.
2. The `variant` is extracted and stored in a global/mock-only location.
3. The UI runs a normal data fetch (no variant parameters).
4. The data layer sees mock mode is enabled, reads the stored variant, and loads `mock/data/<namespace>.<variant>.json`.

Mock vs production selection is controlled by a single mock-mode setting (described in [Mocking Strategy](mocking.md)).

## Agent Notes

When generating code:
- Do NOT thread `variant` through production engine calls
- Pass `variant` “on the side” (context/global/mock-only store) only in mock mode
- Keep mock branching at the data adapter level, not in UI components

## Scenario Usage

Scenario docs link to specific variants:

```markdown
**Step 3: Empty State**

User sees empty state when no items exist.

[![Empty items](../images/item-list-empty.png)](myapp://screen/ItemList?variant=empty)
```

Clicking the image opens the app with that variant.

## See Also

- [Mocking Strategy](mocking.md)
- [Scenarios](scenarios.md)
- [Deep Links](codegen.md#deep-links)
