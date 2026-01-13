# Agent Rules: App Source

You are in an app's source tree (`apps/<target>/`).

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
- Do not inject metadata into source headers; metadata lives in consolidations + JSON registries

## After Regeneration

1. Ensure `design/generated/<target>/meta/outputs.json` reflects the slice’s `dependsOn`
2. Run `update-dep-hashes.sh --target <target> --route <Route>`
3. Verify with `check-stale.sh --target <target>`

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
- [Testing](appeus/reference/testing.md)
