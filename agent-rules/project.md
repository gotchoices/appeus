# Agent Rules: Project Root

> This project uses [Appeus](appeus/README.md), a design-first workflow for building apps.
> Agent rules, references, and scripts are provided by links to the `appeus/` folder.

## Orientation

Stories, specs, and consolidations are maintained in the [design surface](./design). Code is generated per target under [apps](./apps/) (`apps/<target>/`).

Always confirm the current target and phase checklist:
- Target checklist: `design/specs/<target>/STATUS.md`
- Project decisions: `design/specs/project.md`

## Precedence

See: [Precedence](appeus/reference/precedence.md)

## User Commands

| User Says | Action |
|-----------|--------|
| "generate" / "generate a slice" | See [generation](appeus/reference/generation.md) |
| "what's next" | Determine phase and/or next slice to work on (phase model: [phases](appeus/reference/phases.md); slice selection + staleness: [workflow](appeus/reference/workflow.md), [staleness](appeus/reference/staleness.md)) |
| "generate scenarios/images" | See [scenarios](appeus/reference/scenarios.md) |

Target selection:
- If exactly one target exists, default to it.
- If multiple targets exist, ask which `--target` to operate on.
