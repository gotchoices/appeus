# Agent Rules: Project Root

> This project uses **Appeus**, a design-first workflow for building apps.
> Agent rules, references, and scripts are provided by the `appeus/` folder.
> See `appeus/README.md` for toolkit overview.

## Orientation

| Area | AGENTS.md | Purpose |
|------|-----------|---------|
| Design surface | `design/AGENTS.md` | Stories, specs, consolidations |
| App source | `apps/<name>/AGENTS.md` | Generated code |

Project config: `design/specs/project.md`

## Precedence (Global)

1. **Human specs** — authoritative
2. **AI consolidations** — regenerable
3. **Framework defaults** — fill gaps

## User Commands

| User Says | Action |
|-----------|--------|
| "generate" / "generate a slice" | Choose target → choose a slice from `design/specs/<target>/screens/index.md` (prefer stale per `check-stale.sh`) → generate/refresh consolidations → generate code |
| "what's next" | Choose target → consult `design/specs/<target>/STATUS.md` → run `check-stale.sh` → summarize + suggest next smallest step |
| "generate scenarios/images" | See `design/AGENTS.md` |

Target selection:
- If exactly **one** app target exists, default to it.
- If multiple targets exist, ask the user which `--target` to operate on.

## Key References

- [Workflow](appeus/reference/workflow.md)
- [Generation](appeus/reference/generation.md)
