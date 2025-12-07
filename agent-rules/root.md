# Agent Rules: Project Root

This is an Appeus v2 project.

## Orientation

| Area | Location | Purpose |
|------|----------|---------|
| Project config | `design/specs/project.md` | Toolchain decisions |
| Design surface | `design/AGENTS.md` | Stories, specs, consolidations |
| App source | `apps/<name>/AGENTS.md` | Screen code, navigation |

## Key Workflows

### Code Generation

Stories/specs → app code.

1. `appeus/scripts/check-stale.sh` — Check what's stale
2. `appeus/scripts/generate-next.sh` — Pick next slice
3. Generate code for that screen
4. Verify with `check-stale.sh`

Reference: [generation.md](../reference/generation.md)

### Scenario Generation

Screenshots with deep links for review.

Reference: [scenarios.md](../reference/scenarios.md)

## Precedence

1. Human specs > AI consolidations > defaults
2. `design/generated/*` is regenerable — don't hand-edit

## Conventions

- Deep links: `<scheme>://screen/<Route>?variant=<name>`
- Don't modify `appeus/*` or `AGENTS.md` symlinks

## Multi-App Projects

For projects with multiple targets:
- Check `design/specs/project.md` for target list
- Paths use `<target>/` subdirectories
- Schema and API are shared across targets

## References

- [Workflow](../reference/workflow.md)
- [Scaffold](../reference/scaffold.md)
- [Generation](../reference/generation.md)
