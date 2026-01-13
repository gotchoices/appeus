# Specs Human User Guide

Specs are human-authored documents describing the **user-observable UX contract**. Specs take precedence over agent-generated consolidations.

## Location

| Type | Location |
|------|------------------|
| Project decisions | `design/specs/project.md` |
| Domain contract (shared, as needed) | `design/specs/domain/*.md` |
| Target specs root | `design/specs/<target>/` |
| Screens | `design/specs/<target>/screens/*.md` |
| Components | `design/specs/<target>/components/*.md` |
| Navigation | `design/specs/<target>/navigation.md` |
| Global | `design/specs/<target>/global/*` |

For how the per-target folder is organized, see `appeus/user-guides/target-spec.md`.

## What belongs in specs (what vs how)

Specs should stay **human-readable** and describe outcomes:
- states (loading/empty/error)
- constraints and rules the user experiences
- navigation expectations
- acceptance criteria

Avoid implementation mapping (types, modules, adapters). That belongs in consolidations under `design/generated/<target>/`.

## Screen spec example

```yaml
---
id: item-list
route: ItemList
variants: [happy, empty, error]
---

## Description

Display a list of items with search and filter.

## Behavior

- Shows item name and price
- Tap to view details
- Pull to refresh
```

If you want to record “how we plan to implement this”, ask the agent to put that mapping into the slice consolidation under `design/generated/<target>/screens/<Route>.md`.

## Tips

- Keep prose clear and outcome-focused
- Use frontmatter for stable identifiers (id/route/variants)
- Keep route names stable (PascalCase)
- Keep filenames kebab-case

## After Changes

Changing a spec makes consolidations stale. The agent will refresh them before regenerating code.

## How to use the agent with specs

- If you ask “generate”, the agent should read stories and specs first, refresh the consolidation for the slice, then generate code.
- If the agent is blocked, it should ask you for missing user-observable details and help you add them to specs.
