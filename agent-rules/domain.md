# Agent Rules: Domain Contract

You are in `design/specs/domain/`.

This folder holds the **shared domain contract** (only when needed): data model, operations, rules, and interfaces that multiple targets depend on.

## Paths

- Domain contract docs: `design/specs/domain/*.md` (shared)
- Target specs: `design/specs/<target>/...` (per-target)

## Guardrail

- Keep domain docs **human-readable and user-observable** (rules, constraints, invariants, outcomes).
- Put programmer mapping (types, adapters, module structure) in consolidations under `design/generated/<target>/`.

## What to do

1. Determine whether domain docs are needed for this project (local-only apps may still need a data model, but not an API).
2. If data model is unclear from stories, specs, prompt user with quality questions to help them augment stories, specs and obtain needed details.
3. If needed, create minimal docs in `design/specs/domain/` (typically a flat set of files like `schema.md`, `ops.md`, `rules.md`, `interfaces.md`).  Solicit human review.
4. Ensure screens/specs reference domain concepts consistently (don’t duplicate the same “shared truth” inside multiple targets).

Use `appeus/reference/domain-agent-workflow.md` for the domain lane method and `appeus/reference/spec-schema.md` for spec conventions. If the current slice needs deterministic UI states, follow `appeus/reference/mocking.md` and `appeus/reference/mock-variants.md`.


