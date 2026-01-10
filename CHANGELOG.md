# Changelog

This changelog is intentionally practical: it focuses on changes that affect **project scaffolds**, **available commands**, and **how to recover** when a project looks like it was created by an older Appeus version (or has drifted).

## v2.1 (current, post-`v2` tag)

### Scaffold compatibility and repair
- **More robust project-root detection**: scripts no longer break when the `appeus/` link is a symlink (project root is discovered from the working directory rather than the physical path of the toolkit).
- **More resilient “next work” flow**: the “generate next” workflow will rebuild its per-target staleness/registry outputs when they are missing or malformed, instead of trusting placeholder files.
- **Help output works anywhere**: `--help` for key scripts is now available even when you run it outside of an Appeus-initialized project folder.

### Commands and flags you may have missed
- **`init-project.sh`**
  - `--no-git` (and `APPEUS_GIT=0`) to skip initializing a git repo.
- **`add-app.sh`**
  - `--refresh` for idempotent updates when re-running app setup.
  - Prevent nested git repos under `apps/<target>/` by default (framework scaffolds that create `.git/` are cleaned unless explicitly enabled).
- **Removed**: `generate-all.sh` (redundant; use “generate next” instead).

### Documentation updates relevant to agents fixing legacy scaffolds
- `docs/DESIGN.md` was tightened to be more “Goals-oriented,” and now explicitly calls out that agents should be able to **recognize legacy/malformed scaffolds** and guide reorganization to the expected layout.
- Tactical details (framework adapters, version control, migration notes) are documented in `docs/ARCHITECTURE.md` rather than `docs/DESIGN.md`.

## v2 (tagged)

### What “v2” means (vs. v1)
- **Design-first bootstrap**: projects start from `design/` + decision docs, then add one or more app scaffolds.
- **Multi-target projects**: one repo can contain multiple apps (mobile/web/desktop) with shared schema/API and per-target UI stories/specs.
- **Progressive structure**: projects can start in a single-app layout and automatically migrate to a multi-app layout when adding a second app.

### Core scripts (human entry points)
- `scripts/init-project.sh`: link Appeus into a project and create the design scaffold (non-destructive, idempotent).
- `scripts/add-app.sh`: add a new app target via a framework adapter.

### Framework adapters (implemented in v2)
- React Native
- SvelteKit
- NativeScript Svelte

### Common legacy-scaffold symptoms (what to look for)
- **v1-style placement**: a React Native app repo that contains `design/` inside the app itself rather than a project root that contains `apps/<target>/` + `design/`.
- **Mixed single/multi layout**: flat stories/specs alongside per-target folders (often after manual rearranging).

When in doubt, compare the current project tree to `docs/ARCHITECTURE.md`, then reorganize toward the expected structure and re-run `init-project.sh` / `add-app.sh` (both are intended to be safe to re-run).


