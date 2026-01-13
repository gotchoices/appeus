# Appeus Design Phases

## Phase list (authoritative names)

1. **Bootstrap / Discovery** (shared)
2. **Story Generation** (per target)
3. **Navigation Planning** (per target)
4. **Domain Contract** (shared, as needed)
5. **Screen / Component Slicing** (per target)
6. **Scenario / Peer Review** (per target)
7. **Final Wiring** (per target)

## What “done” looks like (signals)

- **Bootstrap / Discovery**
  - `design/specs/project.md` is complete enough to choose frameworks and data strategy
  - At least one target has been added under `apps/<target>/`
- **Story Generation**
  - Target stories exist under `design/stories/<target>/`
- **Navigation Planning**
  - `design/specs/<target>/navigation.md` exists and matches the screens plan
  - `design/specs/<target>/screens/index.md` is populated enough to pick a slice
- **Domain Contract** (as needed)
  - `design/specs/domain/` exists with whatever minimal shared docs are required (e.g. schema,ops,rules,interfaces)
- **Screen / Component Slicing**
  - The project is iterating screen-by-screen with consolidations under `design/generated/<target>/`
  - Staleness metadata exists under `design/generated/<target>/meta/outputs.json`
- **Scenario / Peer Review**
  - Screenshots + scenario docs exist under `design/generated/<target>/images/` and `design/generated/<target>/scenarios/`
- **Final Wiring**
  - UI slices are stable and the remaining work is production wiring (real adapters, real data, end-to-end constraints)

## How to decide the current phase

Use the per-target checklist as the primary truth:
- `design/specs/<target>/STATUS.md`

Then validate by inspecting the presence/quality of the phase’s expected artifacts above.

## How to progress

- Pick the **smallest next step** that makes phase completion more true.
- Prefer completing missing human-generated specs/checklist items over generating more code.
- Keep stories/specs human-readable; push programmer mapping into consolidations.
