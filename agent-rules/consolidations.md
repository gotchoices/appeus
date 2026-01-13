# Agent Rules: Consolidations

You are in `design/generated/`. AI-generated content lives here.

## Purpose

Consolidations are the **translator layer**: gather facts from stories/specs into a programmer-facing digest (implementation mapping) with dependency metadata. They are **regenerable** — human specs take precedence.

## Paths

- Per-target (canonical v2.1): `generated/<target>/screens/*.md`

## Metadata

Include dependency tracking in each consolidation:

```yaml
---
dependsOn:
  - design/stories/01-browsing.md
  - design/specs/<target>/screens/item-list.md
depHashes:
  design/stories/01-browsing.md: abc123...
---
```

## Do

- Refresh when dependencies change
- Include all relevant facts from stories
- Note conflicts for human resolution

## Don't

- Don't prioritize over human specs
- Don't hand-edit (regenerate instead)

## Reference

- [Generation](appeus/reference/generation.md)
