# STATUS

Appeus v2 development tracker. Design decisions live in `docs/DESIGN.md`. Operational docs are in `agent-rules/` and `reference/`.

## v1 Completed (Inherited)

These items were completed in v1 and carry forward:

- [x] Toolkit structure (agent-rules, templates, scripts, reference, user-guides)
- [x] RN scaffold initialization (`rn-init.sh`)
- [x] Design tree setup (`setup-appeus.sh`)
- [x] Staleness detection (`check-stale.sh`)
- [x] Regeneration planning (`regenerate.sh`, `generate-next.sh`)
- [x] Agent rules for stories, specs, consolidations, src
- [x] Reference docs for workflows, codegen, mocking, scenarios
- [x] API spec/consolidation structure
- [x] Android screenshot capture (`android-screenshot.sh`)
- [x] Scenario preview and publish scripts

## v2 Documentation Complete

- [x] `docs/DESIGN.md` — v2 vision, principles, architecture
- [x] `docs/GENERATION.md` — Updated for multi-target
- [x] `docs/ARCHITECTURE.md` — Single-app and multi-app layouts
- [x] `docs/STATUS.md` — v2 roadmap
- [x] `README.md` — v2 overview
- [x] `QUICKSTART.md` — v2 bootstrap flow

## v2 Reference Docs Complete

- [x] `reference/workflow.md` — v2 design-first workflow
- [x] `reference/scaffold.md` — Progressive structure
- [x] `reference/generation.md` — Multi-target generation
- [x] `reference/codegen.md` — Updated paths and examples
- [x] `reference/mocking.md` — Updated for v2
- [x] `reference/mock-variants.md` — Generic examples
- [x] `reference/scenarios.md` — Multi-target paths
- [x] `reference/spec-schema.md` — Schema and API specs
- [x] `reference/testing.md` — Multi-target testing
- [x] `reference/stories-agent-workflow.md` — Updated
- [x] `reference/specs-agent-workflow.md` — Updated
- [x] `reference/screens-agent-workflow.md` — Updated
- [x] `reference/navigation-agent-workflow.md` — Updated
- [x] `reference/api-agent-workflow.md` — Updated
- [x] `reference/scenarios-agent-workflow.md` — Updated

## v2 Agent Rules Complete

- [x] `agent-rules/project.md` — Post-discovery project rules
- [x] `agent-rules/bootstrap.md` — Discovery phase guidance
- [x] `agent-rules/root.md` — Updated for v2
- [x] `agent-rules/design-root.md` — Updated for v2
- [x] `agent-rules/stories.md` — Multi-target paths
- [x] `agent-rules/specs.md` — Updated with v2 paths
- [x] `agent-rules/consolidations.md` — Updated
- [x] `agent-rules/scenarios.md` — Updated
- [x] `agent-rules/api.md` — Updated
- [x] `agent-rules/schema.md` — New: shared schema rules
- [x] `agent-rules/src.md` — Unified app source rules (links to framework references)

## v2 Framework References Complete

- [x] `reference/frameworks/react-native.md` — RN structure, navigation, patterns
- [x] `reference/frameworks/sveltekit.md` — SvelteKit routes, load functions, patterns

## v2 Templates Complete

- [x] `templates/specs/project.md` — Decision document template
- [x] `templates/specs/schema/index.md` — Schema index template
- [x] `templates/specs/schema/entity-template.md` — Entity template
- [x] `templates/specs/screens/index.md` — Updated
- [x] `templates/specs/global/toolchain.md` — Generic

## v2 User Guides Complete

- [x] `user-guides/stories.md` — Updated for v2
- [x] `user-guides/specs.md` — Updated for v2
- [x] `user-guides/scenarios.md` — Updated for v2
- [x] `user-guides/navigation.md` — Updated for v2

## v1 Flaws Fixed

- [x] `scripts/android-screenshot.sh` — Removed hardcoded `org.sereus.chat` default
- [x] `reference/codegen.md` — Generic examples
- [x] `reference/mock-variants.md` — Generic `myapp://` scheme
- [x] `reference/spec-schema.md` — Generic examples
- [x] `agent-rules/specs.md` — Generic examples

## v2 Phase 1: Core Infrastructure (TODO)

Bootstrap and multi-target foundation (scripts):

- [ ] `init-project.sh` — Create project folder with bootstrap AGENTS.md and project.md template
- [ ] Non-destructive setup: detect existing content, add only what's missing
- [ ] Idempotent linking: re-running init refreshes symlinks without overwriting
- [ ] Report output: print what was added vs skipped
- [ ] gitignore template: add appeus symlinks to .gitignore

## v2 Phase 2: Add-App Framework (TODO)

Framework adapter system (scripts):

- [ ] `add-app.sh` — Generic app scaffold command with `--name` and `--framework`
- [ ] React Native adapter (extract from v1's `rn-init.sh` + `setup-appeus.sh`)
- [ ] Single-to-multi migration: `add-app.sh` auto-reorganizes when adding second app
- [ ] Path detection in scripts: detect single-app vs multi-app mode

## v2 Phase 4: Web Adapter (TODO)

SvelteKit support (scripts):

- [ ] SvelteKit scaffold initialization in `add-app.sh`

## Backlog / Future Enhancements

- [ ] `detach-appeus.sh` — Remove appeus symlinks from finished project
- [ ] NativeScript Vue adapter
- [ ] NativeScript Svelte adapter
- [ ] Scenario generation for web (Playwright-based)
- [ ] Shared component library across targets
- [ ] ScenarioRunner overlay for mobile
- [ ] Feedback capture flow
- [ ] Test scaffolding and CI recipes
- [ ] Engine adapter integration

## Known Issues

- None yet for v2

## Notes

- v1 remains available on the `v1` branch for existing projects (chat, health)
- v2 development happens on `master` branch
- First v2 project: bonum (mobile + web)
- Documentation and agent-rules are complete; scripts need implementation
