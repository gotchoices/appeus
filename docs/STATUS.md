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

## v2.1 Checklist (current minor update)

- [ ] **Evaluate and remove legacy bootstrap scripts**: `scripts/rn-init.sh`, `scripts/setup-appeus.sh` (confirm no remaining references in docs/agent-rules/scripts).
- [ ] **Deprecate `scripts/regenerate.sh`**: ensure any useful guidance it prints is represented in `agent-rules/` and `reference/`, then add a clear deprecation notice (and/or replace with a pointer to the relevant reference doc).
- [ ] **Deprecate `scripts/generate-next.sh`**: remove doc reliance; agents should select the next slice using stories/spec priority and staleness output (not a script selector).
- [ ] **Delete deprecated scripts before release**: remove `scripts/generate-next.sh` and `scripts/regenerate.sh` once docs/agent-rules/reference no longer rely on them.
- [ ] **Verify `scripts/update-dep-hashes.sh` behavior**:
  - [ ] Does running it after regenerating one slice update only that slice (`--route`) vs all routes (`--all`)?
  - [ ] Make sure that absence of any switches does not imply --all.
  - [ ] Confirm it does not accidentally “freshen” unrelated stale slices.
- [ ] **Handle placeholder/malformed meta registry** (`design/generated/<target>/meta/outputs.json`):
  - [ ] If `outputs.json` is missing or template-like, the script should create it, if necessary, and add in structures for the outputs being updated.
  - [ ] Can/should the script also trim json structures for outputs that no longer exist in the filesystem?

### v2.1: `docs/GENERATION.md` review todos

- [ ] Update “Shared (Cross-Target)” paths to reflect v2.1 shared domain contract (`design/specs/domain/*`) rather than separate `schema/` + `api/`.
- [ ] Decide whether low-level per-target JSON “status registry” naming belongs in `docs/GENERATION.md` (vs `docs/ARCHITECTURE.md`); if not, remove/relocate.
- [ ] Add a clearer “phases” description aligned with `docs/DESIGN.md` (bootstrap/discovery → domain contract → per-target planning → slice loop → scenarios → final wiring), focused on generation responsibilities.
- [ ] Clarify in `docs/GENERATION.md` how `update-dep-hashes.sh` behaves (`--route` vs `--all`, and what happens when the registry is empty/template-like).

### v2.1: discovery handoff + target phase awareness

- [ ] Ensure `agent-rules/bootstrap.md` explicitly guides the agent to (a) complete `design/specs/project.md` and (b) add the first app target via `scripts/add-app.sh`.
- [ ] Verify `scripts/add-app.sh` seeds a per-target checklist file (e.g. `design/specs/<target>/STATUS.md` or equivalent) and that the corresponding template exists and matches the authoritative phases in `docs/DESIGN.md`.
- [ ] Ensure `agent-rules/project.md` tells the agent to determine the active target and to consult the target checklist (and cross-check prerequisites) before generating the next slice.

### v2.1 File-by-file compliance review

Each item below is a “review for v2.1 compliance” task (canonical scaffold, docs alignment, deprecated/removed commands, and current workflow guidance).

#### agent-rules/

- [ ] Review `agent-rules/api.md`
- [ ] Review `agent-rules/bootstrap.md`
- [ ] Review `agent-rules/consolidations.md`
- [ ] Review `agent-rules/design-root.md`
- [ ] Review `agent-rules/project.md`
- [ ] Review `agent-rules/root.md`
- [ ] Review `agent-rules/scenarios.md`
- [ ] Review `agent-rules/schema.md`
- [ ] Review `agent-rules/specs.md`
- [ ] Review `agent-rules/src.md`
- [ ] Review `agent-rules/stories.md`

#### reference/

- [ ] Review `reference/api-agent-workflow.md`
- [ ] Review `reference/codegen.md`
- [ ] Review `reference/generation.md`
- [ ] Review `reference/mock-variants.md`
- [ ] Review `reference/mocking.md`
- [ ] Review `reference/navigation-agent-workflow.md`
- [ ] Review `reference/scaffold.md`
- [ ] Review `reference/scenarios-agent-workflow.md`
- [ ] Review `reference/scenarios.md`
- [ ] Review `reference/screens-agent-workflow.md`
- [ ] Review `reference/spec-schema.md`
- [ ] Review `reference/specs-agent-workflow.md`
- [ ] Review `reference/stories-agent-workflow.md`
- [ ] Review `reference/testing.md`
- [ ] Review `reference/workflow.md`
- [ ] Review `reference/frameworks/nativescript-svelte.md`
- [ ] Review `reference/frameworks/react-native.md`
- [ ] Review `reference/frameworks/sveltekit.md`

#### scripts/

- [ ] Review `scripts/init-project.sh`
- [ ] Review `scripts/add-app.sh`
- [ ] Review `scripts/check-stale.sh`
- [ ] Review `scripts/update-dep-hashes.sh`
- [ ] Review `scripts/generate-next.sh`
- [ ] Review `scripts/regenerate.sh` (deprecate and/or replace)
- [ ] Review `scripts/build-images.sh`
- [ ] Review `scripts/android-screenshot.sh`
- [ ] Review `scripts/preview-scenarios.sh`
- [ ] Review `scripts/publish-scenarios.sh`
- [ ] Review `scripts/rn-init.sh` (evaluate/remove)
- [ ] Review `scripts/setup-appeus.sh` (evaluate/remove)
- [ ] Review `scripts/lib/project-root.sh`
- [ ] Review `scripts/frameworks/react-native.sh`
- [ ] Review `scripts/frameworks/sveltekit.sh`
- [ ] Review `scripts/frameworks/nativescript-svelte.sh`
- [ ] Review `scripts/frameworks/nativescript-vue.sh`
- [ ] Review `scripts/frameworks/nuxt.sh`
- [ ] Review `scripts/frameworks/nextjs.sh`
- [ ] Review `scripts/frameworks/tauri.sh`
- [ ] Review `scripts/frameworks/capacitor.sh`

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
