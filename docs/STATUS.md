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

## New TODOs (workflows, rules, and docs audit)
- [ ] Document two separate workflows clearly:
  - [ ] Generate code (stories/specs → RN app)
  - [ ] Generate scenarios (screenshots → scenario docs with deep-link anchors)
- [ ] Verify AGENTS.md coverage: do symlinks steer the agent to both workflows with clear next-actions?
- [ ] Audit agent-rules for organization and brevity; remove duplication; ensure stepwise guidance
- [ ] Check linking from agent-rules → reference files; add missing cross-links
- [ ] Reference completeness audit: do reference/*.md files contain all details needed for both workflows?
- [ ] Consolidation step parity check:
  - [ ] Confirm why `ChatInterface` code was generated without refreshing `design/generated/screens/ChatInterface.md`
  - [ ] Clarify rules: when to regenerate consolidations vs proceed directly from specs
  - [ ] Update rules/scripts so consolidation precedence is enforced or explicitly skipped with rationale
- [ ] Naming consistency review:
  - [ ] Decide on canonical case for `design/specs/screens/*` filenames (kebab vs Pascal/Camel)
  - [ ] Update agent-rules to prompt humans to normalize names; provide rename guidance

