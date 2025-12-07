# Agent Rules: Project Root

This is an Appeus v2 project. Start here for orientation.

## Quick Links

| Area | AGENTS.md | Reference |
|------|-----------|-----------|
| Design surface | `design/AGENTS.md` | [workflow.md](../reference/workflow.md) |
| App source | `apps/<name>/AGENTS.md` | [codegen.md](../reference/codegen.md) |
| Scenarios | `design/generated/scenarios/AGENTS.md` | [scenarios.md](../reference/scenarios.md) |

## Project Structure

Check `design/specs/project.md` for:
- Target platforms and apps
- Toolchain choices
- Data strategy

See [scaffold.md](../reference/scaffold.md) for folder layout.

## Workflows

### Generate Code

Stories/specs → app code. See [generation.md](../reference/generation.md).

Scripts:
- `appeus/scripts/check-stale.sh` — Per-screen staleness
- `appeus/scripts/generate-next.sh` — Pick next slice
- `appeus/scripts/regenerate.sh --screen <Route>` — Target specific screen

### Generate Scenarios

App → screenshots → scenario docs. See [scenarios.md](../reference/scenarios.md).

Scripts:
- `appeus/scripts/build-images.sh` — Capture screenshots
- `appeus/scripts/preview-scenarios.sh` — Local preview

## Cadence

1. Run `check-stale.sh` to refresh status
2. Use `generate-next.sh` to pick next slice
3. Generate code for that slice
4. Run `check-stale.sh` again to verify

## Precedence

1. Human specs (authoritative)
2. AI consolidations (regenerable)
3. Framework defaults

## Conventions

- `design/generated/*` is regenerable — don't hand-edit
- Use deep links for variants: `?variant=happy`
- Don't modify `appeus/*` or `AGENTS.md` symlinks

## Multi-App Projects

For projects with multiple apps:
- Check `design/specs/project.md` for target list
- Paths include `<target>/` subdirectories
- Schema and API specs are shared
- Scripts accept `--target <name>`

See [scaffold.md](../reference/scaffold.md) for single-app vs multi-app layouts.

