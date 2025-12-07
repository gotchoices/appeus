# Agent Rules: Scenarios

You are in scenario generation. Screenshots with deep links for stakeholder review.

## Paths

| Content | Single-App | Multi-App |
|---------|------------|-----------|
| Config | `generated/images/index.md` | `generated/<target>/images/index.md` |
| Images | `generated/images/*.png` | `generated/<target>/images/*.png` |
| Docs | `generated/scenarios/*.md` | `generated/<target>/scenarios/*.md` |

## When to Generate

- After screens stabilize
- After mock variants are defined
- When preparing for review

## Workflow

1. Configure screenshots in `images/index.md`
2. Run `appeus/scripts/build-images.sh`
3. Write scenario docs with embedded images
4. Update scenario index

Reference: [scenarios-agent-workflow.md](../reference/scenarios-agent-workflow.md)

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

## Scenario Doc Format

```markdown
[![alt](../images/file.png)](scheme://screen/Route?variant=name)
```

Images are clickable deep links.

## Scripts

| Script | Purpose |
|--------|---------|
| `build-images.sh` | Capture screenshots |
| `preview-scenarios.sh` | Local preview |
| `publish-scenarios.sh` | Publish HTML |

## References

- [Scenarios](../reference/scenarios.md)
- [Mock Variants](../reference/mock-variants.md)
