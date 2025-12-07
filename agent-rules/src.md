# Agent Rules: App Source

You are in an app's source tree (`apps/<name>/`).

## Check Framework

Read `design/specs/project.md` for the framework, then see the appropriate reference:

| Framework | Reference |
|-----------|-----------|
| React Native | [frameworks/react-native.md](../reference/frameworks/react-native.md) |
| SvelteKit | [frameworks/sveltekit.md](../reference/frameworks/sveltekit.md) |

## Universal Rules

These apply regardless of framework:

### Precedence

1. Human specs (authoritative)
2. AI consolidations (regenerable)
3. Framework defaults

### Modification

- Do not modify files without regeneration request
- All edits derived from specs and consolidations
- Embed AppeusMeta header in generated files

### Mock Variants

- Don't hardcode variants in production logic
- Variants come via deep links or URL params
- Branch in data adapters, not UI components
- See [mock-variants.md](../reference/mock-variants.md)

### After Regeneration

1. Update `design/generated/meta/outputs.json`
2. Run `update-dep-hashes.sh --route <Route>`
3. Verify with `check-stale.sh`

## Common Patterns

### Data Adapters

```
src/data/<namespace>.ts
```

Each adapter:
- Checks mock mode
- Reads variant from context/URL
- Returns mock data or calls real API

### Components

```
src/components/<Component>.tsx|svelte
```

Shared UI components used across screens.

### Navigation/Routing

- React Native: `src/navigation/` with React Navigation
- SvelteKit: `src/routes/` with file-based routing

## References

- [Codegen](../reference/codegen.md)
- [Generation](../reference/generation.md)
- [Mock Variants](../reference/mock-variants.md)
- [Testing](../reference/testing.md)
