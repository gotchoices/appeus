# Agent Rules: Project Root

> This project uses [Appeus](appeus/README.md), a design-first workflow for building apps.
> Agent rules, references, and scripts are provided by links to the `appeus/` folder.

## Orientation

Stories, specs, consolidations maintained in [design surface](./design).
Code generated in [app source](./apps/) (`apps/<target>/`).
See [project config](./design/specs/project.md).

## Precedence

See: [Precedence](appeus/reference/precedence.md)

## User Commands

| User Says | Action |
|-----------|--------|
| "generate" / "generate a slice" | See [generation](appeus/reference/generation.md) |
| "what's next" | Determine phase and/or next slice to work on, see [workflow](appeus/reference/workflow.md) |
| "generate scenarios/images" | See [scenarios](appeus/reference/scenarios.md) |

Target selection:
- If exactly one target exists, default to it.
- If multiple targets exist, ask which `--target` to operate on.
