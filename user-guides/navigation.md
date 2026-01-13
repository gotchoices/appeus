# User Guide: Navigation

Define your app's sitemap and deep links in the navigation spec.

## Location

`design/specs/<target>/navigation.md`

## Structure

```markdown
# Navigation

## Sitemap

- **Main Tab**
  - ItemList (tab root)
  - ItemDetail (push)
- **Profile Tab**
  - UserProfile (tab root)
  - Settings (push)

## Deep Links

Scheme: `myapp://`

| Pattern | Screen | Params |
|---------|--------|--------|
| `/screen/ItemList` | ItemList | variant, category |
| `/screen/ItemDetail` | ItemDetail | id, variant |

## Route Options

| Route | Title | Header |
|-------|-------|--------|
| ItemList | "Items" | large |
| ItemDetail | dynamic | standard |
```

## Tips

- Keep route names stable (PascalCase)
- Include variant param for mock data switching
- Document header options per route
- Clarify modal vs push behavior

## After Changes

Agent merges navigation spec with consolidations and updates `apps/<name>/src/navigation/` on regeneration.
