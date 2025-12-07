# User Guide: Specs

Specs are human-authored documents that take precedence over AI consolidations.

## Location

| Type | Single-App | Multi-App |
|------|------------|-----------|
| Screens | `specs/screens/*.md` | `specs/<target>/screens/*.md` |
| Navigation | `specs/navigation.md` | `specs/<target>/navigation.md` |
| Schema | `specs/schema/*.md` | `specs/schema/*.md` (shared) |
| API | `specs/api/*.md` | `specs/api/*.md` (shared) |
| Global | `specs/global/*` | `specs/<target>/global/*` |

## Screen Specs

```yaml
---
id: item-list
route: ItemList
variants: [happy, empty, error]
---

## Description

Display a list of items with search and filter.

## Behavior

- Shows item name and price
- Tap to view details
- Pull to refresh

```ts slot=imports
import { VirtualizedList } from 'react-native';
```
```

## Code Slots

Override generated code with slots:
- `imports` — Additional imports
- `component` — Component body
- `styles` — StyleSheet

## Tips

- Keep prose clear and outcome-focused
- Use frontmatter for structured data
- Spec overrides consolidation — be authoritative
- Naming: kebab-case files, PascalCase routes

## After Changes

Changing a spec makes consolidations stale. The agent will refresh them before regenerating code.
