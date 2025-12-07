# Toolchain Spec

Framework and tooling configuration for this target.

## Configuration

```yaml
language: ts           # ts | js
packageManager: yarn   # yarn | npm | pnpm
```

## React Native (if applicable)

```yaml
runtime: bare          # bare | expo
navigation: react-navigation
state: zustand         # zustand | redux | jotai
http: fetch            # fetch | axios
```

## SvelteKit (if applicable)

```yaml
adapter: auto          # auto | node | static
```

## Notes

- Adjust values as needed for your project
- Regenerate after changes
