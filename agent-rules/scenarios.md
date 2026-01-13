# Agent Rules: Scenarios

You are in scenario generation. Screenshots with deep links for review.

## Paths

- Config: `generated/images/index.md` or `generated/<target>/images/index.md`
- Images: `generated/images/*.png`
- Docs: `generated/scenarios/*.md`

## When to Generate

After screens stabilize and mock variants are defined.

## Workflow

1. Configure screenshots in `images/index.md`
2. Run `build-images.sh`
3. Write scenario docs with embedded images
4. Update scenario index

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

## Reference

- [Scenarios](appeus/reference/scenarios.md)
- [Scenarios workflow](appeus/reference/scenarios-agent-workflow.md)
