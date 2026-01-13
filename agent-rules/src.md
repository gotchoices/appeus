# Agent Rules: App Source

You are in an app's source tree (`apps/<target>/`).

## What to confirm first

- Target is explicit (`<target>`).
- The phase checklist: `design/specs/<target>/STATUS.md` (phase model: [phases](appeus/reference/phases.md)).
- Framework selection in `design/specs/project.md`, then use the framework reference for folder conventions:

| Framework | Reference |
|-----------|-----------|
| React Native | [frameworks/react-native.md](appeus/reference/frameworks/react-native.md) |
| SvelteKit | [frameworks/sveltekit.md](appeus/reference/frameworks/sveltekit.md) |
| NativeScript Svelte | [frameworks/nativescript-svelte.md](appeus/reference/frameworks/nativescript-svelte.md) |

## Edits in app code

- Only write code when the user requests regeneration.
- Code edits should be derived from the consolidation for the slice (`design/generated/<target>/screens/<Route>.md`) plus authoritative specs/stories.
- Do not inject metadata into source headers; staleness metadata lives in consolidation frontmatter + `design/generated/<target>/meta/outputs.json`.

## After Regeneration

1. Ensure `design/generated/<target>/meta/outputs.json` reflects the slice’s `dependsOn`
2. Run `appeus/scripts/update-dep-hashes.sh --target <target> --route <Route>`
3. Optionally verify with `appeus/scripts/check-stale.sh --target <target>`

## Mock Variants

Variants come via deep links/URL params. Branch in data adapters, not UI.

See [mock-variants.md](appeus/reference/mock-variants.md)

For code generation methodology, see [generation](appeus/reference/generation.md) and [codegen](appeus/reference/codegen.md). For staleness rules, see [staleness](appeus/reference/staleness.md). For per-slice testing expectations, see [testing](appeus/reference/testing.md).
