# Agent Rules: Design Root

You are in the design surface (`design/`).

## Structure

| Folder | Purpose | Editable? |
|--------|---------|-----------|
| `stories/` | User stories | Human |
| `specs/` | Authoritative specs | Human |
| `generated/` | Consolidations, scenarios | AI only |

## Paths

- **Single-app:** `stories/*.md`, `specs/screens/*.md`
- **Multi-app:** `stories/<target>/*.md`, `specs/<target>/screens/*.md`
- **Shared:** `specs/schema/*.md`, `specs/api/*.md`

## User Commands

| User Says | Action |
|-----------|--------|
| "generate" / "next slice" | `generate-next.sh`, then generate code |
| "generate [Screen]" | `regenerate.sh --screen <Route>`, generate |
| "generate scenarios" | Write docs in `generated/scenarios/`, run `build-images.sh` |
| "generate images" | Configure `images/index.md`, run `build-images.sh` |
| "what's next" | `check-stale.sh`, summarize |
| "preview scenarios" | `preview-scenarios.sh` |

For multi-app: add `--target <name>`.

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
