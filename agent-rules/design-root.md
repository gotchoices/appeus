# Agent Rules: Design Root

You are in the design surface (`design/`).

## Structure

| Folder | Purpose | Editable? |
|--------|---------|-----------|
| `stories/` | User stories | Human |
| `specs/` | Authoritative specs | Human |
| `generated/` | Consolidations, scenarios | AI only |

## Paths

- **Per-target (canonical v2.1):** `stories/<target>/*.md`, `specs/<target>/screens/*.md`
- **Shared (when needed):** `specs/domain/*.md`

## User Commands

| User Says | Action |
|-----------|--------|
| "generate" / "next slice" | `check-stale.sh`, then select a slice deliberately and generate |
| "generate [Screen]" | Treat `[Screen]` as the chosen slice; generate consolidation(s), generate code, update metadata |
| "generate scenarios" | Write docs in `generated/scenarios/`, run `build-images.sh` |
| "generate images" | Configure `images/index.md`, run `build-images.sh` |
| "what's next" | `check-stale.sh`, summarize |
| "preview scenarios" | `preview-scenarios.sh` |

If you need a script to operate on a specific app, pass `--target <name>` (it defaults when only one target exists).

## Workflow

1. Human writes stories
2. Agent derives consolidations (with metadata)
3. Human refines specs
4. On request, generate code
5. Validate via scenarios

## Guardrail

If specs are becoming complex/programmer-facing, **stop and update consolidations**. Keep specs user-observable.

## References

- [Generation](appeus/reference/generation.md)
- [Spec Schema](appeus/reference/spec-schema.md)
