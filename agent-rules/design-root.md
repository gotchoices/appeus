# Agent Rules: Design Root

You are in the design surface (`design/`).

## Structure (what lives here)

| Folder | Purpose | Editable? |
|--------|---------|-----------|
| `stories/` | User stories | Human |
| `specs/` | Authoritative specs | Human |
| `generated/` | Consolidations, scenarios, metadata | Derived (agent-generated) |

## Canonical paths

- Per-target stories: `design/stories/<target>/`
- Per-target specs: `design/specs/<target>/` (screens/components/navigation/global)
- Shared domain contract (as needed): `design/specs/domain/*.md`
- Per-target generated: `design/generated/<target>/` (screens consolidations, scenarios/images, meta)

## What to confirm first

- Current target: if multiple targets exist, ask which `--target <target>` they want.
- Current phase checklist: `design/specs/<target>/STATUS.md` (phase model: [phases](appeus/reference/phases.md)).

## Where to go next (index)

- Working on stories: see `design/stories/AGENTS.md` → `agent-rules/stories.md`
- Working on specs: see `design/specs/AGENTS.md` → `agent-rules/specs.md` (spec format: [spec schema](appeus/reference/spec-schema.md))
- When checking for staleness follow [staleness checking procedure](appeus/reference/staleness.md).
- Regenerating code: follow procedures in [workflow](appeus/reference/workflow.md), [generation](appeus/reference/generation.md), and [codegen](appeus/reference/codegen.md)
- Scenarios/screenshots: see [scenarios](appeus/reference/scenarios.md) and `design/generated/<target>/scenarios/AGENTS.md` → `agent-rules/scenarios.md`

## Guardrail

If specs are becoming complex/programmer-facing, stop and help the user simplify and organize them into human-facing content.  Then re-generate consolidations as part of next slice generation.
