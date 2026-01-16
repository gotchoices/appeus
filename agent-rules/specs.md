# Agent Rules: Specs

You are in `design/specs/`. Human-authored specs are authoritative.

## Guardrail (Keep Specs Human-Readable)

Specs are a **user-observable UX contract**. If you find yourself writing programmer-facing structure, put it in consolidations (`design/generated/…`) instead.

## Canonical paths

| Type | Location |
|------|----------|
| Target checklist | `design/specs/<target>/STATUS.md` |
| Screens | `design/specs/<target>/screens/*.md` |
| Components | `design/specs/<target>/components/*.md` |
| Navigation | `design/specs/<target>/navigation.md` |
| Global | `design/specs/<target>/global/*` |
| Domain contract (as needed) | `design/specs/domain/*.md` (shared) |

## What to do next (index)

- If the target is unclear, ask which `--target <target>` is being worked on.
- Use `design/specs/<target>/STATUS.md` to understand the current phase checklist (phase model: [phases](appeus/reference/phases.md)).
- Use `appeus/reference/spec-schema.md` for recommended spec structure and conventions.
- If specs imply shared domain behavior, capture it in `design/specs/domain/*.md` (lane method: `appeus/reference/domain-agent-workflow.md`).

## Naming

- Filenames: kebab-case (`item-list.md`)
- Routes: PascalCase (`ItemList`)
- Mapping: `design/specs/<target>/screens/index.md`

## Workflow (critical)

When generating slices, follow the [appeus workflow](../reference/workflow.md) and the [generation methodology](../reference/generation.md) and [code generation guide](../reference/codegen.md).
