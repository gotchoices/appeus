# User Guide: Scenarios

Scenarios are visual walkthroughs with screenshots and deep links.

## Location

`design/generated/<target>/scenarios/*.md`

## Usage

1. **Browse** — View scenarios in your editor or serve locally
2. **Click** — Deep links open the running app with that screen/variant
3. **Review** — Share with stakeholders for feedback
4. **Iterate** — Update stories/specs and regenerate

## Generating Scenarios

1. Configure screenshots in `images/index.md`
2. Run `appeus/scripts/build-images.sh`
3. Agent writes scenario docs

## Preview

```bash
appeus/scripts/preview-scenarios.sh --port 8080
```

## Publish

```bash
appeus/scripts/publish-scenarios.sh --dest user@host:/path
```

## Format

Each scenario links a story to screenshots:

```markdown
[![Item list](../images/item-list-happy.png)](myapp://screen/ItemList?variant=happy)
```

Clicking the image opens the app with that variant.
