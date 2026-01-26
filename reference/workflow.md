# Appeus Workflow

## Overview

Appeus follows a design-first workflow:

```
Init Project → Discovery → Add Apps → Stories → Navigation → Domain (as needed) → Slice → Validate → Iterate
```

## Phase Model

For named development phases (and how to detect/progress them), see [Phases](phases.md).

## Precedence Rules

See: [Precedence](precedence.md)

## Regeneration

Human-triggered. Per target, the loop is:

1. **Pick target** (`--target`) and confirm phase checklist: `design/specs/<target>/STATUS.md`
2. **Pick a slice** (screen/route) from `design/specs/<target>/screens/index.md` (use `appeus/scripts/check-stale.sh --target <target>` unless you are intentionally targeting a specific route, or you recently ran it to confirm freshness and nothing has changed since)
3. **Read inputs**: target stories/specs + shared domain contract (as needed) + `design/specs/project.md`
4. **Refresh consolidation**: write/update `design/generated/<target>/screens/<Route>.md`
5. **Generate code** under `apps/<target>/src/` (screen + navigation wiring as needed)
6. **Update dependency registry**: ensure `design/generated/<target>/meta/outputs.json` has an entry for the route and that its `dependsOn` list is accurate enough for deterministic staleness
   - Scripts can seed missing entries conservatively, but the agent must refine `dependsOn` to match what was actually used
7. **Hash the declared dependencies**:
   - `appeus/scripts/update-dep-hashes.sh --target <target> --route <Route>`
8. **Confirm freshness** (optional): rerun `appeus/scripts/check-stale.sh --target <target>`
9. **Run/validate** the target app (human); iterate by updating stories/specs (human lane) and regenerating

## Multiple Targets

When multiple app targets exist, scripts accept `--target <target>` to scope operations.

## See Also

- [Scaffold Structure](scaffold.md)
- [Generation Details](generation.md)
- [Staleness and Dependencies](staleness.md)
- [Design Phases](phases.md)
- [Precedence](precedence.md)
