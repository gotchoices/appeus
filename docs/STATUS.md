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

## v2 Phase 1: Core Infrastructure

Bootstrap and multi-target foundation:

- [ ] `init-project.sh` — Create project folder with bootstrap AGENTS.md and project.md template
- [ ] `templates/specs/project.md` — Decision document template (purpose, platforms, toolchain)
- [ ] `agent-rules/bootstrap.md` — Guide agent through discovery phase
- [ ] `agent-rules/project.md` — Post-discovery project-level rules
- [ ] Update folder structure: `apps/`, `packages/`, per-target design paths
- [ ] Rename/refactor `setup-appeus.sh` → called by `add-app.sh` for RN targets
- [ ] Non-destructive setup: detect existing content, add only what's missing, never overwrite user files
- [ ] Idempotent linking: re-running init refreshes symlinks and adds new templates without overwriting
- [ ] Report output: print what was added vs skipped (e.g., "Added: design/specs/schema/, Skipped: design/stories/ (exists)")
- [ ] gitignore template: add appeus symlinks to project's .gitignore with setup instructions comment

## v2 Phase 2: Add-App Framework

Framework adapter system:

- [ ] `add-app.sh` — Generic app scaffold command with `--name` and `--framework`
- [ ] React Native adapter (extract from v1's `rn-init.sh` + `setup-appeus.sh`)
- [ ] `agent-rules/rn-src.md` — RN-specific source rules (rename from `src.md`)
- [ ] Progressive structure: single-app uses flat paths; multi-app uses `<target>/` subdirectories
- [ ] Single-to-multi migration: `add-app.sh` auto-reorganizes when adding second app
- [ ] Path detection in scripts: detect single-app vs multi-app mode and adjust paths

## v2 Phase 3: Shared Schema

Cross-target data model:

- [ ] `design/specs/schema/` folder convention
- [ ] `agent-rules/schema.md` — Rules for deriving shared schema from multi-target stories
- [ ] Schema-first workflow: agent reads all target stories before proposing data model
- [ ] `packages/shared/` optional TypeScript package for types

## v2 Phase 4: Web Adapter

SvelteKit support:

- [ ] SvelteKit scaffold initialization
- [ ] `agent-rules/sveltekit-src.md` — SvelteKit source rules
- [ ] Routing/navigation spec template for web
- [ ] Codegen for SvelteKit routes
- [ ] (Deferred) Scenario generation for web

## v2 Phase 5: Documentation & Polish

- [ ] Update QUICKSTART.md for v2 bootstrap flow
- [ ] Update README.md for v2 overview
- [ ] Audit and update all agent-rules for v2 context
- [ ] Audit and update all reference docs for multi-target
- [ ] Sample end-to-end: project → discovery → add apps → stories → schema → generate

## Backlog / Future Enhancements

Carried from v1 plus new ideas:

- [ ] `detach-appeus.sh` — Remove appeus symlinks from a finished project (leaves all user content)
- [ ] NativeScript Vue adapter
- [ ] NativeScript Svelte adapter
- [ ] Scenario generation for web (Playwright-based screenshots)
- [ ] Shared component library across targets
- [ ] ScenarioRunner overlay for mobile
- [ ] Feedback capture flow syncing back to stories/specs
- [ ] Test scaffolding and CI recipes
- [ ] Engine adapter integration (production data sources)

## v1 Flaws to Fix

Issues inherited from v1 that need cleanup:

- [ ] `scripts/android-screenshot.sh` — Hardcoded default `APP_ID="org.sereus.chat"`; should require explicit `--app-id` or use generic default like `com.example.app`
- [ ] `reference/codegen.md` — Uses `chat-interface` as example; change to generic example like `user-profile`
- [ ] `reference/generation.md` — Uses `chat-interface` as example; change to generic example
- [ ] `reference/mock-variants.md` — Uses `chat://` deep link scheme; change to generic `myapp://`
- [ ] `reference/spec-schema.md` — Uses `chat-interface` as example; change to generic example
- [ ] `agent-rules/specs.md` — Uses `chat-interface` as example; change to generic example

## Known Issues

- None yet for v2

## Notes

- v1 remains available on the `v1` branch for existing projects (chat, health)
- v2 development happens on `master` branch
- First v2 project: bonum (mobile + web)
