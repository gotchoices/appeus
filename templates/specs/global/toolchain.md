# Toolchain Spec

Framework and tooling configuration for this target.

## Configuration

```yaml
language: ts           # ts | js
packageManager: yarn   # yarn | npm | pnpm
```

## Notes

- Keep this file high-level and human-readable; avoid implementation mapping.
- Specify platform (React-Native, NativeScript, Svelte, etc)
- Specify other tools used in implementation
