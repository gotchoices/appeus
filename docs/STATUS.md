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
- [x] `agent-rules/root.md` — Updated for v2, user command mapping
- [x] `agent-rules/design-root.md` — Updated for v2, user command mapping
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

## v2 Phase 1: Core Infrastructure (COMPLETE)

- [x] `init-project.sh` — Create project folder with bootstrap AGENTS.md and project.md template
- [x] Non-destructive setup: detect existing content, add only what's missing
- [x] Idempotent linking: re-running init refreshes symlinks without overwriting
- [x] Report output: print what was added vs skipped
- [x] gitignore template: add appeus symlinks to .gitignore

## v2 Phase 2: Add-App Framework (COMPLETE)

- [x] `add-app.sh` — Generic app scaffold command with `--name` and `--framework`
- [x] Dispatcher pattern: add-app.sh calls `frameworks/<name>.sh`
- [x] React Native adapter: `scripts/frameworks/react-native.sh`
- [x] Single-to-multi migration: `add-app.sh` auto-reorganizes when adding second app
- [x] Path detection: detect single-app vs multi-app mode

## v2 Phase 4: Web Adapter (COMPLETE)

- [x] SvelteKit scaffold: `scripts/frameworks/sveltekit.sh`

## v2 Phase 5: Existing Scripts Updated

- [x] `check-stale.sh` — Multi-app support (`--target`), single-app detection
- [x] `regenerate.sh` — Multi-app support, updated paths
- [x] `generate-next.sh` — Multi-app support
- [x] `generate-all.sh` — Deleted (redundant with generate-next.sh)
- [x] `update-dep-hashes.sh` — Multi-app support, relative path handling
- [x] `build-images.sh` — Multi-app support (`--target`)
- [x] `preview-scenarios.sh` — Multi-app support (`--target`)
- [x] `publish-scenarios.sh` — Multi-app support (`--target`)
- [x] `android-screenshot.sh` — Documentation fix (APP_ID unused)

## v2 Templates Updated

- [x] `templates/generated/images-index.md` — Updated deps path comment
- [x] `templates/specs/global/dependencies.md` — Framework-agnostic examples
- [x] `templates/specs/global/ui.md` — Framework-agnostic notes
- [x] `templates/specs/navigation.md` — Generic route examples

## Framework Adapters Implemented

- [x] `scripts/frameworks/react-native.sh` — React Native (Expo or bare)
- [x] `scripts/frameworks/sveltekit.sh` — SvelteKit web apps
- [x] `scripts/frameworks/nativescript-svelte.sh` — NativeScript with Svelte

## Framework Stubs (Not Yet Implemented)

- [ ] `scripts/frameworks/nativescript-vue.sh` — NativeScript with Vue (stub exists)
- [ ] `scripts/frameworks/nuxt.sh` — Nuxt (Vue web framework)
- [ ] `scripts/frameworks/nextjs.sh` — Next.js (React web framework)
- [ ] `scripts/frameworks/tauri.sh` — Tauri (desktop apps)
- [ ] `scripts/frameworks/capacitor.sh` — Capacitor (hybrid mobile)

## Cleanup (When Stable)

- [ ] Delete `scripts/rn-init.sh` — Obsolete, replaced by `frameworks/react-native.sh`
- [ ] Delete `scripts/setup-appeus.sh` — Obsolete, replaced by `init-project.sh` + `add-app.sh`

## Backlog / Future Enhancements

- [ ] `detach-appeus.sh` — Remove appeus symlinks from finished project
- [ ] NativeScript Vue adapter
- [ ] Scenario generation for web (Playwright-based)
- [ ] Shared component library across targets
- [ ] ScenarioRunner overlay for mobile
- [ ] Feedback capture flow
- [ ] Test scaffolding and CI recipes
- [ ] Engine adapter integration

## Known Issues

### FIXED (done): Scripts computed wrong `PROJECT_DIR` when `appeus/` is a symlink (resolved via `scripts/lib/project-root.sh` + updates across staleness/generation scripts)

## Notes

- v1 remains available on the `v1` branch for existing projects (chat, health)
- v2 development happens on `master` branch
- First v2 project: bonum (mobile + web)
- v2 core infrastructure complete: init-project, add-app, framework adapters (RN, SvelteKit)
- All scripts updated for multi-app support
- Ready for testing with bonum
