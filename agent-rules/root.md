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
| "generate" / "next slice" | `check-stale.sh`, then select a slice deliberately and generate code |
| "what's next" | `check-stale.sh`, summarize, suggest |
| "add an app" | `add-app.sh --name <name> --framework <framework>` |

If you need a script to operate on a specific app, pass `--target <name>` (it defaults when only one target exists).

## Key References

- [Workflow](appeus/reference/workflow.md)
- [Generation](appeus/reference/generation.md)
- [Scaffold](appeus/reference/scaffold.md)
