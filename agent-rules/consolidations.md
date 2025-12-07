# Agent Rules: Consolidations

You are in `design/generated/`. AI-derived consolidations live here.

## Paths

| Type | Single-App | Multi-App |
|------|------------|-----------|
| Screens | `generated/screens/*.md` | `generated/<target>/screens/*.md` |
| API | `generated/api/*.md` | `generated/api/*.md` (shared) |
| Scenarios | `generated/scenarios/*.md` | `generated/<target>/scenarios/*.md` |
| Status | `generated/status.json` | `generated/<target>/status.json` |

## Purpose

Consolidations capture facts from multiple stories about a screen. They are regenerable and should not be hand-edited.

## Dependency Metadata

Include frontmatter:

```yaml
---
provides: ["screen:ItemList"]
needs: ["api:Items", "schema:Item"]
dependsOn:
  - design/stories/01-browsing.md
  - design/specs/screens/item-list.md
depHashes:
  design/specs/screens/item-list.md: "sha256:..."
---
```

## Workflow

1. Read stories that reference this screen
2. Read spec if exists (spec takes precedence)
3. Write consolidation with complete metadata
4. Before codegen, ensure consolidation is fresh

Reference: [generation.md](../reference/generation.md)

## Regeneration Trigger

Create/refresh consolidations when:
- Stories are added or edited
- Specs clarify behavior
- Dependencies change

## Rules

- Never override human specs
- Keep metadata accurate
- Be explicit about variants and data requirements

## References

- [Generation](../reference/generation.md)
- [Staleness](../reference/generation.md#staleness-and-dependencies)
