# Agent Rules: Scenarios

You are in scenario generation. Screenshots with deep links for review.

## Canonical paths

- Images config: `design/generated/<target>/images/index.md`
- Screenshots: `design/generated/<target>/images/*.png`
- Scenario docs: `design/generated/<target>/scenarios/*.md`
- Scenario index: `design/generated/<target>/scenarios/index.md`

## When to Generate

After screens stabilize and mock variants are defined.

## What to confirm first

- Target is explicit (`--target <target>` when multiple targets exist).
- Deep links are wired for the target (deep link structure: `appeus/reference/codegen.md` → “Deep Links”).
- Variants are mock-only and selected via deep links (method: `appeus/reference/mock-variants.md`).

## Method (index)

1. Configure screenshots in `design/generated/<target>/images/index.md`.
2. Run `appeus/scripts/build-images.sh --target <target>` to capture missing/stale images.
3. Write scenario docs in `design/generated/<target>/scenarios/` with embedded images and deep links.
4. Maintain `design/generated/<target>/scenarios/index.md` as a stakeholder review order.

## Screenshot Config

```yaml
---
appId: com.example.myapp
scheme: myapp
screenshots:
  - route: ItemList
    variant: happy
    file: item-list-happy.png
---
```

## Image Embed Format

```markdown
[![alt](../images/file.png)](scheme://screen/Route?variant=name)
```

For the detailed scenario document format and screenshot methodology, see `appeus/reference/scenarios.md`. For the lane workflow, see `appeus/reference/scenarios-agent-workflow.md`.
