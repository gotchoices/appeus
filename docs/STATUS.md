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

### Goals for the v2.1 runtime asset review

Each runtime asset should be reviewed **one at a time** for compliance with v2.1 (as defined in `docs/DESIGN.md`, `docs/ARCHITECTURE.md`, and `docs/GENERATION.md`):
- **Pause between files** so the human can review/approve; check off each item only after approval.
- If a runtime asset implements a behavior **not documented in `docs/*`**, stop and decide:
  - Was it intentionally removed/changed in v2.1?
  - Or is it useful and should be documented in `docs/*` (then resume the review)?
- `agent-rules/` should be **lean** and primarily an index into `reference/`, scoped to the folder and its children.
- Confirm `AGENTS.md` files are planted in the right places in the project tree and are non-redundant.
- `reference/` docs may need splitting; they should be consistent with v2.1.
- `user-guides/` should be helpful, brief, and human-readable.
- Scripts and templates should match the v2.1 workflow and layout (domain contract under `design/specs/domain/`).

### v2.1: docs alignment review (docs/*)

- [x] Update “Shared (Cross-Target)” paths to reflect v2.1 shared domain contract (`design/specs/domain/*`) rather than separate `schema/` + `api/`.
- [x] Remove/relocate low-level per-target JSON “status registry” naming from docs (keep docs focused on workflow; implementation details live elsewhere).
- [x] Align phase naming and generation loop language with `docs/DESIGN.md` (and track per-target phase progression via `STATUS.md`).
- [x] Clarify in `docs/GENERATION.md` how `update-dep-hashes.sh` behaves (`--route` vs `--all`, and what happens when the registry is empty/template-like).

### v2.1: key workflow + tooling changes to validate

- [x] **Evaluate and remove legacy bootstrap scripts**: `scripts/rn-init.sh`, `scripts/setup-appeus.sh` (confirm no remaining references in docs/agent-rules/reference/scripts).
- [x] **Deprecate `scripts/regenerate.sh`**: ensure any useful guidance it prints is represented in `agent-rules/` and `reference/`.
- [x] **Deprecate `scripts/generate-next.sh`**: remove doc reliance; agents should select the next slice using stories/spec priority and staleness output (not a script selector).
- [x] **Delete deprecated scripts before release**: remove `scripts/generate-next.sh` and `scripts/regenerate.sh` once docs/agent-rules/reference no longer rely on them.
- [x] **Verify `scripts/update-dep-hashes.sh` behavior**:
  - [x] Does running it after regenerating one slice update only that slice (`--route`) vs all routes (`--all`)?
  - [x] Make sure that absence of any switches does not imply --all.
  - [x] Confirm it does not accidentally “freshen” unrelated stale slices.
- [x] **Handle placeholder/malformed meta registry** (`design/generated/<target>/meta/outputs.json`):
  - [x] If `outputs.json` is missing, scripts create an empty registry file (`{"outputs":[]}`) for the active target.
  - [x] If `outputs.json` is template-like (empty), scripts seed it from the screens index (non-destructively).
  - [x] If a route/output is missing from the registry but is being updated, tooling adds a minimal entry (non-destructively).
  - [x] Decision: scripts do **not** auto-trim registry entries for outputs that no longer exist (manual cleanup only).
- [x] **Discovery handoff + target phase awareness**
  - [x] Ensure `agent-rules/bootstrap.md` guides the agent to complete `design/specs/project.md` and add the first app target via `scripts/add-app.sh`.
  - [x] Verify `scripts/add-app.sh` seeds a per-target checklist file (`design/specs/<target>/STATUS.md`) and that the corresponding template exists and matches the authoritative phases in `docs/DESIGN.md`.
  - [x] Ensure `agent-rules/project.md` tells the agent to determine the active target and consult the target checklist before generating the next slice.
- [x] **Remove schema/api domain templates (v2.1)**: eliminate non-universal “schema/api” templates under `templates/specs/` to avoid template noise; domain specs are authored as needed per `user-guides/domain.md`.
- [x] **Update scripts accordingly**: ensure scripts do not seed schema/api templates; domain is created as an empty folder with README symlink to `user-guides/domain.md`.

### v2.1: runtime asset compliance review (pause after each file for approval)

#### Project scaffold + AGENTS.md placement

- [x] Verify canonical `AGENTS.md` placement and non-redundancy across: project root, `design/`, `design/specs/`, `design/stories/`, `design/generated/`, and `apps/<target>/` (and confirm symlink targets are correct).

#### templates/

- [x] Review `templates/specs/project.md`
- [x] (No domain templates by default in v2.1; verify domain guidance lives in `user-guides/domain.md`)
- [x] Review `templates/specs/screens/index.md` and `templates/specs/screens/screen-spec-template.md`
- [x] Review `templates/specs/components/index.md` and `templates/specs/components/component-spec-template.md`
- [x] Review `templates/specs/navigation.md`
- [x] Review `templates/specs/global/toolchain.md`, `templates/specs/global/ui.md`, `templates/specs/global/dependencies.md`
- [x] Review `templates/stories/story-template.md`
- [x] Review `templates/generated/…` (consolidations/scenarios templates)

#### scripts/

- [x] Review `scripts/init-project.sh`
- [x] Review `scripts/add-app.sh`
- [x] Review `scripts/check-stale.sh`
- [x] Review `scripts/update-dep-hashes.sh`
- [x] Review `scripts/build-images.sh`
- [x] Review `scripts/android-screenshot.sh`
- [x] Review `scripts/preview-scenarios.sh`
- [x] Review `scripts/publish-scenarios.sh`
- [x] Review `scripts/lib/project-root.sh`
- [x] Remove deprecated scripts: `scripts/generate-next.sh`, `scripts/regenerate.sh` (deleted in v2.1)
- [x] Remove all runtime-asset references to deleted scripts (`reference/`, `agent-rules/`, docs)
- [x] Legacy scripts removed: `scripts/rn-init.sh`, `scripts/setup-appeus.sh`

#### reference/

**Reference review goals (v2.1)**
- [x] Ensure every reference doc is reachable from an `agent-rules/*.md` hyperlink (directly, or via a small “index” link).
- [x] Ensure each reference doc covers a **single topic**; split or trim where one file mixes multiple topics (notably generation vs scenarios vs staleness).
- [x] De-duplicate repeated guidance across reference docs (keep global rules in `reference/phases.md` + `reference/precedence.md` + `reference/workflow.md`).
- [x] Normalize to v2.1 canonical paths and terms everywhere (`<target>`, `design/*/<target>/`, `design/specs/domain/`, no progressive structure).
- [x] Remove legacy/contradictory guidance (e.g., “generated code headers”, deleted scripts, `apps/<name>` placeholders).
- [x] Decide what to do with `reference/*-agent-workflow.md` docs: keep only those with unique lane-specific detail; merge or slim the rest.

**Standards to apply during per-file review**
- Document fully explains the assigned topic in human-readable language
- Includes material description of appeus-approved methodology
- Does not review practices that are otherwise known from good practices (i.e. how to code)
- Document is consistent with appeus/docs/*.md (v2.1 standards)
- Document does not need to speak of "v2.1" explicitly (all documents present represent the current version inherently)
- Document does not contain fluff, decorative language, obvious language
- In-line, in-context hyperlinks preferred over bottom References (where such inline context already exists in the file)
- Prefer concise, descriptive checklists and examples over long prose.
- Links from agent-rules should feel “right-sized”: agent-rules stays brief (topical index); reference holds depth/content.

- [x] Review `reference/workflow.md`
- [x] Review `reference/scaffold.md`
- [x] Review `reference/generation.md`
- [x] Review `reference/codegen.md`
- [x] Replace remaining `specs/schema` + `specs/api` references with `specs/domain` across `reference/` (+ remove references to deleted scripts)
- [x] Review `reference/spec-schema.md`
- [x] Review `reference/mocking.md` + `reference/mock-variants.md`
- [x] Review `reference/scenarios.md`
- [x] Review `reference/testing.md`
- [x] Review agent workflow refs: `reference/*-agent-workflow.md`
- [x] Review framework refs: `reference/frameworks/react-native.md`, `reference/frameworks/sveltekit.md`, `reference/frameworks/nativescript-svelte.md`
- [x] Review `reference/phases.md`
- [x] Review `reference/precedence.md`
- [x] Review `reference/staleness.md`

#### agent-rules/
Standards for agent-rules files:
- Contains pointers to data relevant to the folder it is associated with
- Intended to guide agents, not-necessarily humans
- Primarily an index into deeper treatment of topics
- Hyperlinks into reference docs for more detailed treatment

- [x] Review `agent-rules/project.md`
- [x] Review `agent-rules/bootstrap.md`
- [x] Review `agent-rules/design-root.md`
- [x] Review `agent-rules/stories.md`
- [x] Review `agent-rules/specs.md`
- [x] Review `agent-rules/consolidations.md`
- [x] Review `agent-rules/scenarios.md`
- [x] Review `agent-rules/src.md`
- [x] Review `agent-rules/domain.md`
- [x] Replace remaining `specs/schema` + `specs/api` references with `specs/domain` across `agent-rules/`

#### user-guides/
Standards for user-guides:
- Human readable guides to help the user know what to do in the applicable folder
- Not meant for AI consumption
- Not unnecessarily wordy, but clear and fully descriptive
- Applicable to the folder they live in
- Include hyperlinks to deeper topics (can even link into appeus/docs if necessary/helpful)

- [x] Review `user-guides/domain.md`
- [x] Review `user-guides/target-spec.md` (renamed from `user-guides/navigation.md`)
- [ ] Review `user-guides/scenarios.md`
- [ ] Review `user-guides/specs.md`
- [ ] Review `user-guides/stories.md`

#### framework adapters and stubs

- [ ] Review implemented adapters: `scripts/frameworks/react-native.sh`, `scripts/frameworks/sveltekit.sh`, `scripts/frameworks/nativescript-svelte.sh`
- [ ] Review stubs for v2.1 consistency: `scripts/frameworks/nativescript-vue.sh`, `scripts/frameworks/nuxt.sh`, `scripts/frameworks/nextjs.sh`, `scripts/frameworks/tauri.sh`, `scripts/frameworks/capacitor.sh`

## v2 Reference Docs Complete (historical; some items are v2.0-only)

- [x] `reference/workflow.md` — v2 design-first workflow
- [x] `reference/scaffold.md` — Progressive structure (v2.0; removed from v2.1 canonical layout)
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

## v2 Templates Complete (historical; schema/api templates removed in v2.1)

- [x] `templates/specs/project.md` — Decision document template
- [x] `templates/specs/schema/*` — (v2.0) Schema templates (removed in v2.1)
- [x] `templates/specs/screens/index.md` — Updated
- [x] `templates/specs/global/toolchain.md` — Generic

## v2 User Guides Complete

- [x] `user-guides/stories.md` — Updated for v2
- [x] `user-guides/specs.md` — Updated for v2
- [x] `user-guides/scenarios.md` — Updated for v2
- [x] `user-guides/target-spec.md` — Renamed from `user-guides/navigation.md` and broadened to cover per-target specs

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

## v2 Phase 2: Add-App Framework (COMPLETE; some items are v2.0-only)

- [x] `add-app.sh` — Generic app scaffold command with `--name` and `--framework`
- [x] Dispatcher pattern: add-app.sh calls `frameworks/<name>.sh`
- [x] React Native adapter: `scripts/frameworks/react-native.sh`
- [x] Single-to-multi migration: `add-app.sh` auto-reorganizes when adding second app (v2.0; removed in v2.1 canonical layout)
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

- [x] Delete `scripts/rn-init.sh` — Obsolete, replaced by `frameworks/react-native.sh`
- [x] Delete `scripts/setup-appeus.sh` — Obsolete, replaced by `init-project.sh` + `add-app.sh`

## Backlog / Future Enhancements

- [x] `detach-appeus.sh` — Remove appeus symlinks from finished project
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
