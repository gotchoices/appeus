# AI Agent Rules: Scenarios (Appeus)

Scenarios are narrative walkthroughs with deep-linked screenshots. They live under `design/generated/scenarios/` and are fully regenerable.

## Quick Reference

- **Image config**: `design/generated/images/index.md` (YAML frontmatter)
- **Capture tool**: `appeus/scripts/build-images.sh`
- **Full workflow**: `appeus/reference/scenarios-agent-workflow.md`
- **Complete reference**: `appeus/reference/scenarios.md`

## Core Actions

1. Configure screenshots in `images/index.md` frontmatter
2. Run `build-images.sh --reuse --window` to capture
3. Write scenario docs in `design/generated/scenarios/`
4. Maintain `scenarios/index.md` with review order

## Key Rules

- One scenario doc per source story; link story at top
- Each step: 1-3 sentence narrative + clickable screenshot
- Avoid technical jargon in narrative
- Keep deep-link URLs in link targets only
- Image embed: `[![alt](../images/file.png)](scheme://screen/Route?variant=name)`

## When to Regenerate

- After screens, navigation, or specs change
- After mock variants change
- After adding screens to `images/index.md`

## Do Not

- Reference non-existent screens
- Hand-edit generated scenarios
- Hardcode tasks in scripts; use `images/index.md`

See `appeus/reference/scenarios.md` for complete details.
