# STATUS

Tracker only. Design decisions live in `appeus/DESIGN.md`. Operational docs live in `appeus/reference/` and are indexed via `appeus/agent-rules/*`.

## Completed
- Appeus toolkit structure (agent-rules, templates, scripts, reference, user-guides)
- init-project.sh seeds design tree, AGENTS.md links, global/navigation/api specs
- check-stale.sh and regenerate.sh added
- RN-first workflows and codegen guidance added (see reference/)
- API spec/consolidation structure and docs added

## In Progress
- Codegen pipeline: generate RN screens and navigation from specs + consolidations
- Scenario pages under design/generated/scenarios with deep links
- Deep linking config across platforms (linking, universal/app links)
- ScenarioRunner overlay (guide, variant switcher, feedback)
- HTTP client adapter in src/data for mock server + variant header/param

## Backlog / Future Enhancements
- Initialize Expo RN app skeleton (navigation + linking)
- Stand up tiny Express JSON mock server implementation
- Global scenario/variant state and engine adapter wiring
- Define spec frontmatter schema and consolidation format (finalize)
- Wire codegen to consult global specs + navigation spec by default
- Sample end-to-end: story → consolidation/spec → generate → run → iterate
- Feedback capture flow syncing back to stories/specs
- Test scaffolding (render, navigation, data) and CI recipe
- Contribution workflow doc

