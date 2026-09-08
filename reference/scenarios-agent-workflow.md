# Scenarios Agent Workflow

How to produce scenario documents with screenshots and live links. Formats and script options: [Scenarios](scenarios.md); variants: [Mock Variants](mock-variants.md).

## When

- Screens and navigation are stable for the feature; deep linking works in the app
- Mock variants are in place — run `appeus/scripts/check-variants.sh --target <target>` first and fix what it reports
- Stakeholder review is coming

## Workflow

1. **Register states** in `design/generated/<target>/images/index.md` frontmatter: one entry per (route, params, variant) worth reviewing. Add `deps` (screen source, fixture files) so images go stale when they should. States worth opening but not photographing get `capture: false` and a `note`.
2. **Verify a link** before capturing: `appeus/scripts/open-deeplink.sh --target <target> --id <entry id>` (choose `--device` when several are connected).
3. **Capture**: `appeus/scripts/build-images.sh --target <target> --reuse [--dry-run]`. Check the images are not splash screens; raise `APPEUS_SCREEN_DELAY` if they are.
4. **Write scenario docs** in `design/generated/<target>/scenarios/<story-id>.md`: cite the story, one section per step, one image per state. Use the bare `![alt](../images/f.png)` form — the renderer links it from the registry. Link `capture: false` states as plain text links with their deep link.
5. **Maintain `scenarios/index.md`** in review order.
6. **Preview**: `appeus/scripts/preview-scenarios.sh --target <target>`; click through every link with a device selected. **Publish** with `publish-scenarios.sh` when the user asks; read its drift notes.

## Cross-Target

Registry, images, scenarios and site are per target. `mock/data/` is shared, so a fixture added for one target's variant serves the others.
