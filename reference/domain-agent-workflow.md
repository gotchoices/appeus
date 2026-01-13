# Domain Contract Agent Workflow

Lane-specific guidance for maintaining the **shared domain contract** under `design/specs/domain/`.

This doc is intentionally focused on domain work only. For the overall per-slice loop, see [Workflow](workflow.md).

For spec structure conventions, see `reference/spec-schema.md`.

## What belongs in the domain contract (human)

Create only what you need, and keep it human-readable:
- Schema / entities (data model)
- Operations (API/procedures, storage operations)
- Rules / invariants
- Interfaces / integration assumptions

## Inputs

- Target stories: `design/stories/<target>/`
- Target specs (screens/navigation/global): `design/specs/<target>/`
- Project decisions: `design/specs/project.md`

## Outputs

- Domain docs: `design/specs/domain/*.md` (shared)
- Mock data + metadata: `mock/data/*` (shared, when used)

## Workflow (differences from the general workflow)

1. **Decide if domain docs are needed** for the current slice (local-only apps may still need a data model; not all apps need APIs).
2. **Draft/update minimal domain docs** required by the current slice.
   - Keep them user-observable: rules, constraints, expected shapes/outcomes.
3. **Preserve compatibility** when multiple targets exist:
   - prefer additive changes; call out breaking changes for human decision.
4. **Keep programmer mapping out of specs**:
   - put adapters/types/module structure in consolidations under `design/generated/<target>/`.

If the slice depends on deterministic UI states (screenshots/testing), use mock variants as described in `reference/mock-variants.md` and keep mock data aligned to the domain contract as described in `reference/mocking.md`.
