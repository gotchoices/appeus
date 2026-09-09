# Scenarios Human User Guide

Scenarios are **storyboards**: human-readable walkthrough documents that combine your stories with screenshots of the running app.

They are useful for:
- stakeholder review (without running the app)
- consistent “demo paths”
- validating UI states (happy/empty/error) with deterministic data

## Location

- Scenario docs: `design/generated/<target>/scenarios/*.md`
- Scenario index (review order): `design/generated/<target>/scenarios/index.md`
- Screenshots: `design/generated/<target>/images/*.png`
- Screenshot config: `design/generated/<target>/images/index.md`

## When scenarios are available (phases)

Scenarios become practical after these are mostly in place for a target:

- **Story Generation**: stories exist for the target (`design/stories/<target>/`)
- **Navigation Planning**: a stable-ish `design/specs/<target>/navigation.md` exists
- **Screen/Component Slicing**: the target has runnable screens and deep linking configured

Scenarios are typically created during the **Scenario / Peer Review** phase (see `appeus/docs/DESIGN.md`).

## What a scenario contains (stories + screenshots + deep links)

Each scenario step embeds a screenshot and links it to a deep link:

```markdown
[![Item list](../images/item-list-happy.png)](myapp://screen/ItemList?variant=happy)
```

- The image is what the reviewer sees.
- Clicking it opens the app to that screen and state — on your emulator when viewing the local preview, or on a phone that has the app when viewing the published site. (Desktop renderers such as GitHub ignore `myapp://` links; the preview server is what makes them live.)
- The **States** page lists every registered state, including ones worth opening that have no screenshot.

The scenario should cite the source story (so reviewers can relate the UI to user intent).

## How variants help scenarios

Variants are a mock-only way to show the UI in different states (e.g. happy/empty/error) without rewriting the story or changing production behavior.

Typical approach:
- the scenario uses deep links like `...?variant=empty`
- the app runs in mock mode and loads the corresponding mock data variant

(Details: `appeus/reference/mock-variants.md` and `appeus/reference/mocking.md`.)

## How you use scenarios (human workflow)

You typically write stories and refine specs while the agent generates screen slices. Once the screens feel stable enough to review, ask the agent for scenarios and screenshots.

### Good “user commands” to the agent

- “Generate scenarios for `<target>`”
- “Generate the next scenario from story `<id>`”
- “Generate screenshots for the current scenarios”
- “Refresh scenarios after the last slice”
- “Preview scenarios locally”
- “Show me the `<screen>` in its empty state” (opens it on the emulator)
- “Publish scenarios to a public server”

### What you should review

- The scenarios reflect the **intent** of your stories (not new requirements invented by the agent).
- The screenshot set covers important states (happy/empty/error where relevant).
- Deep links open the right screen and show the expected state — click them in the preview.
- Every variant a spec declares has real fixture data behind it (the agent runs `check-variants.sh`); otherwise the screen shows the default data and looks fine when it should not.
- The scenario index order (`scenarios/index.md`) matches how you want reviewers to walk the app.

## Preview

You can preview scenarios locally (or ask the agent to do it):

```bash
appeus/scripts/preview-scenarios.sh --port 8080
```

This renders the scenario markdown as a small local website with images inline. Click any screenshot or deep link to open that state on your emulator or simulator. The server decides which device — `--device <id>`, or `APPEUS_DEVICE`, or the only one running — and the page header says which; with several projects and emulators, run one preview per project. Add `--host 0.0.0.0` to open the same pages on a phone on your network; there the links open the installed app directly.

## Share / publish (to a public HTTP server)

You can publish scenarios to your destination (or ask the agent to do it):

```bash
appeus/scripts/publish-scenarios.sh --dest user@host:/path
```

This generates static HTML (per target) — the scenario pages plus a States page — and syncs it to the destination you provide (e.g. an Nginx/Apache-served folder). Published links cannot reach your emulator; on a phone with the app installed they still open the state.
