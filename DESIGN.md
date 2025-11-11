# DESIGN

Purpose
- Capture design decisions, rationale, alternatives considered, and historical notes for Appeus. Operational guidance for agents lives in `appeus/agent-rules/*` and detailed docs live in `appeus/reference/*`.

Vision
- Design and execution happen on the same surface. Stories expand into scenarios and immediately render as live React Native screens (device/simulator). Deep links from scenario pages open exact screens/variants; an optional overlay guides reviews.

Relationship to AppGen (as inspiration, not dependency)
- AppGen proved: story-first workflows, consolidations for multi-story screens, spec-first precedence, and regeneration scripts are effective.
- Appeus keeps those patterns but goes directly to React Native code (no SVG step), and provides scenario deep links into the running app.

Selected Architecture and Decisions
- Rendering strategy: Code generation of RN screens + navigation from stories/specs. Rationale: idiomatic source, full flexibility, easy to hand-tune when needed. Alternative (runtime schema) parked/out of scope.
- Mock layer: Tiny Express server serving local JSON; variants via `?variant` or `X-Mock-Variant`. Rationale: minimal effort, fast iteration, easy to expose via tunnel when needed.
- Generation governance: Human-triggered regeneration only; commit discipline; mtime-based stale checks to prompt regeneration. Rationale: avoids clobbering; easy rollback.
- Precedence: Human specs > AI consolidations > defaults. Rationale: specs are the authoritative “how”; consolidations capture multi-story facts; defaults fill gaps.
- Navigation as specs: Human `design/specs/navigation.md` plus generated `design/generated/navigation.md`; codegen merges with human precedence.
- API surface: Human `design/specs/api/*.md` and generated `design/generated/api/*.md` define engine-facing procedures and shapes; mock data aligns with these docs.

Scope Boundaries
- Out of scope: runtime schema/JSON/MDX-driven rendering path.
- In scope later: engine adapter integration, end-to-end multi-engine tests, production data sources.

Notes and Future Considerations
- Optional generated vs custom split in `src/` can be introduced later if needed; current governance allows direct generation into `src/` safely.
- Consider adding a “materialize” switch if teams want to freeze a screen and stop regeneration for that file.
- Wire precise AST-based edits (ts-morph) for navigation/index updates when codegen matures.

References
- Operational how-to and workflows live in `appeus/reference/`. Key entries:
  - Scaffold: `appeus/reference/scaffold.md`
  - Workflow overview: `appeus/reference/workflow.md`
  - Code generation: `appeus/reference/codegen.md`
  - Mocking strategy: `appeus/reference/mocking.md`
  - API workflow: `appeus/reference/api-agent-workflow.md`
  - Folder workflows:
    - Navigation: `appeus/reference/navigation-agent-workflow.md`
    - Specs: `appeus/reference/specs-agent-workflow.md`
    - Stories: `appeus/reference/stories-agent-workflow.md`
    - Scenarios: `appeus/reference/scenarios-agent-workflow.md`


