# Agent Rules: Domain Contract

You are in `design/specs/domain/`.

This folder holds the **shared domain contract** (only when needed): data model, operations, rules, and interfaces that multiple targets depend on.

## Paths

- Domain contract docs: `specs/domain/*.md` (shared)
- Target specs: `specs/<target>/...` (per-target)

## Guardrail

- Keep domain docs **human-readable and user-observable** (rules, constraints, invariants, outcomes).
- Put programmer mapping (types, adapters, module structure) in consolidations under `design/generated/<target>/`.

## What to do

1. Determine whether domain docs are needed for this project (local-only apps may still need a data model, but not an API).
2. If needed, create minimal docs in `specs/domain/` (e.g. `schema.md`, `api.md`, `rules.md`) guided by `specs/domain/README.md`.
3. Ensure screens/specs reference domain concepts consistently (don’t duplicate the same “shared truth” inside multiple targets).

## References

- [Domain guide (human)](appeus/user-guides/domain.md)
- [Spec schema](appeus/reference/spec-schema.md)
- [API workflow](appeus/reference/api-agent-workflow.md)
- [Mocking](appeus/reference/mocking.md)


