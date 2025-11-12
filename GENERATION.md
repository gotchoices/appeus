# Appeus Generation Strategy (Design Intent)

Purpose
- Define how Appeus tracks dependencies, detects staleness, chooses the next vertical slice, and regenerates outputs incrementally.
- This is a design-intent document. Agents will follow the operative rules in `appeus/agent-rules/*` and `appeus/reference/*` linked via `AGENTS.md` files.

Scope
- Inputs: stories, human specs (screens, navigation, api, global), screens plan
- Intermediates: screen consolidations, api consolidations, scenarios, status registry
- Outputs: RN code (screens, navigation), mock data, engine stubs/adapters

Core principles
1) Human-first precedence: specs > consolidations > defaults
2) Vertical slicing: implement one navigable screen at a time, top-to-bottom
3) Deterministic, idempotent generation: consolidate → api → mocks → engine → RN code → scenarios
4) Accurate dependency tracking: hash-based, embedded metadata + a status registry


Dependency model

Nodes
- Screen consolidation (`design/generated/screens/<Screen>.md|.json`)
  - provides: ["screen:<Screen>"]
  - needs: ["api:<Namespace>", ...] (optional)
  - dependsOn: explicit file paths (stories, specs/screens/<Screen>.md if any, specs/navigation.md, screens/index.md, global/*)
  - depHashes: { filePath: sha256(content) }
- API consolidation (`design/generated/api/<Namespace>.md|.json`)
  - provides: ["api:<Namespace>"]
  - usedBy: ["screen:<Screen>", ...] (optional)
  - dependsOn: stories, specs/api/*.md, specs/screens/* (when screens dictate shape), global/*
  - depHashes: { filePath: sha256(content) }
- RN code (`src/screens/<Screen>.tsx`, `src/navigation/*`)
  - AppeusMeta header (JSON) with dependsOn (consolidations + specs) and depHashes snapshot
- Mock data (`mock/data/<Namespace or Screen>/<variant>.json` + `.meta.json`)
  - .meta.json: dependsOn (API consolidation) and depHashes
- Scenarios (`design/generated/scenarios/<story-id>.md`)
  - frontmatter: dependsOn (stories + screens/routes referenced) and depHashes

Status registry
- `design/generated/status.json` records a graph of nodes with:
  - id, type, outputs, dependsOn, depHashes, lastBuiltAt, stale (bool), reason (text)
- Scripts update this registry after each generation step and use it for fast checks.


Staleness detection
1) Consolidations first
  - Recompute sha256 for each dependsOn file; compare to saved depHashes → mismatch = stale
  - If no depHashes yet, compare mtimes of inputs vs consolidation file
2) Outputs next
  - RN code: if AppeusMeta depHashes don’t match current hashes, stale
  - Mocks: if `.meta.json` depHashes don’t match API consolidation hash, stale
  - Scenarios: if any referenced story/screen hash differs from saved depHashes, stale
3) Fallback
  - When metadata missing, conservatively mark stale if any likely input mtime > output mtime


Vertical slice selection
- Build a navigation graph from `design/specs/navigation.md` and `design/specs/screens/index.md`
- Selection order:
  1) First stale screen reachable from root ( ConnectionsList or declared root )
  2) Then stale neighbors (screens that can be navigated to from fresh screens)
  3) Remaining stale screens
- A “screen is stale” if its consolidation or any of its outputs are stale or missing.


Generation flow (per slice)
1) Screen consolidation: refresh `design/generated/screens/<Screen>.md` with complete dependsOn and depHashes; record provides/needs
2) API consolidations: refresh needed namespaces first (from screen needs or inferred from stories/specs)
3) Mocks: generate/refresh mock/data sets for required namespaces with `.meta.json`
4) Engine stubs: minimal adapters/stubs in `src/data/*` and `src/engine/*` to read mocks; plumb variant
5) RN code: generate/update `src/screens/<Screen>.tsx` and `src/navigation/*`; embed AppeusMeta header (dependsOn/depHashes snapshot)
6) Scenarios: generate/update `design/generated/scenarios/<story-id>.md` with deep links for the slice
7) Update `design/generated/status.json`; print a concise report


Commands
- `appeus/scripts/check-stale.sh` (agent-oriented)
  - Output: human-readable summary + JSON staleness report
  - Strategy: use status.json and metadata; fallback to mtime
- `appeus/scripts/regenerate.sh [--screen <Screen> | --api <Namespace>]` (prompt-only)
  - Prints an AI-facing plan for the specific target; agents perform actions accordingly
  - Use this to scope prompts to a single slice
- `appeus/scripts/generate-next.sh` (agent-oriented)
  - Picks next stale screen (vertical), prints plan, and invokes `regenerate.sh` with the target
  - Updates status.json after the agent completes steps (agent reruns check-stale)
- `appeus/scripts/generate-all.sh` (agent-oriented)
  - Iterates generate-next until clean (agents apply changes per step)


File metadata formats
- Consolidations frontmatter (YAML):
  ```yaml
  provides: ["screen:ChatInterface"]
  needs: ["api:Threads"]
  dependsOn:
    - design/stories/01-first-story.md
    - design/specs/screens/chat-interface.md
    - design/specs/navigation.md
  depHashes:
    design/specs/navigation.md: "sha256:..."
    design/specs/screens/chat-interface.md: "sha256:..."
  ```

- Generated RN code header (JS/TS comment, JSON inside):
  ```
  /* AppeusMeta:
  {
    "dependsOn": [
      "design/generated/screens/ChatInterface.md",
      "design/generated/api/Threads.md",
      "design/specs/navigation.md"
    ],
    "depHashes": {
      "design/generated/screens/ChatInterface.md": "sha256:...",
      "design/specs/navigation.md": "sha256:..."
    },
    "generatedAt": "2025-11-12T12:34:56Z"
  }
  */
  ```

- Mock dataset meta (JSON in `mock/data/<Namespace>/meta.json` or alongside per-variant):
  ```json
  {
    "namespace": "Threads",
    "dependsOn": ["design/generated/api/Threads.md"],
    "depHashes": { "design/generated/api/Threads.md": "sha256:..." },
    "variants": ["happy","empty","error"]
  }
  ```


Agent guidance (operational)
- Always refresh consolidations first; ensure frontmatter is complete.
- Never overwrite human specs; only write consolidations and generated outputs.
- After each slice, re-run `check-stale.sh` and update status.json; stop when clean or on user request.


Testing
- For each slice: add a basic render test for the screen; add a smoke test to open it via deep link with a variant.
- Defer E2E until several slices are ready.


Appendix: Minimal staleness (initial implementation)
- Until all metadata is embedded, scripts use:
  - Screens list: from `design/specs/screens/index.md`
  - For each screen:
    - Inputs mtimes: stories/*, specs/screens/<Screen>.md?, specs/navigation.md, specs/global/*
    - Outputs mtimes: src/screens/<Screen>.tsx?
    - stale = outputs missing or any input newer than outputs
- JSON report is written to `design/generated/status.json` and printed to stdout


