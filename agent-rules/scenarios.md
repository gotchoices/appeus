# Agent Rules: Scenarios

You are in scenario generation: storyboards whose screenshots link to the deep link that produced them. Locally those links open the running app.

## Canonical paths

- State registry: `design/generated/<target>/images/index.md` (frontmatter: `appId`, `scheme`, `screenshots:`)
- Screenshots: `design/generated/<target>/images/*.png`
- Scenario docs + review order: `design/generated/<target>/scenarios/*.md`, `index.md`

## What to confirm first

- Target is explicit (`--target <target>` when several exist); deep links are wired in the app (`appeus/reference/codegen.md` → “Deep Links”).
- Every variant a spec declares has a fixture: `appeus/scripts/check-variants.sh --target <target>`.

## Method (index)

1. Register each reviewable state in `images/index.md` — `route`, `variant`, `params`, `file`, `deps`; `capture: false` + `note` for states to open but not photograph.
2. `appeus/scripts/open-deeplink.sh --target <target> --id <entry>` to verify a link on the device (`--device <id>` when several are connected).
3. `appeus/scripts/build-images.sh --target <target> --reuse` to capture missing/stale images (`--dry-run` to see what and why).
4. Write scenario docs: cite the story; embed `![alt](../images/file.png)` — the renderer links it from the registry. Keep `scenarios/index.md` in review order.
5. `appeus/scripts/preview-scenarios.sh --target <target>` — click links to open states on the device; `publish-scenarios.sh` for a static site (raw links).

Formats, options and the deep-link formula: `appeus/reference/scenarios.md`. Lane workflow: `appeus/reference/scenarios-agent-workflow.md`.
