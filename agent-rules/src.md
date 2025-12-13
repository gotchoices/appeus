# Agent Rules: App Source

You are in an app's source tree (`apps/<name>/`).

## Framework

Check `design/specs/project.md` for framework, then see:

| Framework | Reference |
|-----------|-----------|
| React Native | [frameworks/react-native.md](appeus/reference/frameworks/react-native.md) |
| SvelteKit | [frameworks/sveltekit.md](appeus/reference/frameworks/sveltekit.md) |
| NativeScript Svelte | [frameworks/nativescript-svelte.md](appeus/reference/frameworks/nativescript-svelte.md) |

## Modification

- Do not modify without regeneration request
- All edits derived from specs and consolidations
- Embed AppeusMeta header in generated files

## After Regeneration

1. Update `design/generated/meta/outputs.json`
2. Run `update-dep-hashes.sh --route <Route>`
3. Verify with `check-stale.sh`

## Mock Variants

Variants come via deep links/URL params. Branch in data adapters, not UI.

See [mock-variants.md](appeus/reference/mock-variants.md)

## Components (Prefer Reuse)

If screen/route files are getting large, extract reusable UI into the app’s components folder:

- SvelteKit: `src/lib/components/`
- React Native: `src/components/`
- NativeScript Svelte: `app/components/`

## References

- [Codegen](appeus/reference/codegen.md)
- [Generation](appeus/reference/generation.md)
