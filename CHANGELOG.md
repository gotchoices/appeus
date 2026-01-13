# Changelog

This changelog is intentionally practical: it focuses on changes that affect **project scaffolds**, **available commands**, and **how to recover** when a project looks like it was created by an older Appeus version (or has drifted).

## v2.1 (current, post-`v2` tag)

### Migration to v2.1 (from v1 or v2 projects)

v2.1 standardizes on a **single canonical per-target layout**:
- Apps always live under `apps/<target>/`
- Target design artifacts always live under `design/stories/<target>/`, `design/specs/<target>/`, and `design/generated/<target>/`
- Shared “domain contract” docs (as needed) live under `design/specs/domain/` (plus `design/specs/project.md`)

If you are helping a user migrate an older project, aim for **structure correctness first**, then re-establish symlinks/metadata via the scripts.

#### 1) Confirm toolkit + relink

- Ensure the project’s `appeus/` symlink points at a v2.1 toolkit.
- Re-run `appeus/scripts/init-project.sh` (safe/idempotent; it refreshes symlinks and adds missing folders).

#### 2) Make sure targets exist (and are named)

- Ensure there is at least one target folder: `apps/<target>/`.
- If the project has a single app but no obvious target name, choose a name like `mobile` or `web`, then rename the existing app folder to `apps/<target>/`.

#### 3) Migrate “flat” design folders into per-target folders (legacy)

If you see any of these legacy “flat” paths:
- `design/stories/*.md`
- `design/specs/screens/` or `design/specs/components/`
- `design/specs/navigation.md`
- `design/specs/global/`
- `design/generated/screens/`, `design/generated/scenarios/`, `design/generated/images/`, `design/generated/meta/`

Move them under the chosen target:
- `design/stories/<target>/`
- `design/specs/<target>/screens/`, `design/specs/<target>/components/`, `design/specs/<target>/navigation.md`, `design/specs/<target>/global/`
- `design/generated/<target>/screens/`, `design/generated/<target>/scenarios/`, `design/generated/<target>/images/`, `design/generated/<target>/meta/`

Then ensure required per-target “index”/checklist files exist:
- `design/specs/<target>/STATUS.md`
- `design/specs/<target>/screens/index.md`

Re-run `appeus/scripts/add-app.sh --name <target> --framework <framework> --refresh` to seed missing templates/symlinks **without** overwriting user content.

#### 4) Migrate shared contract folders (v2.0 → v2.1)

If the project has v2.0-era shared folders:
- `design/specs/schema/`
- `design/specs/api/`

Consolidate them under:
- `design/specs/domain/` (create only what you need; keep these docs human-readable)

Note: v2.1 does not ship domain templates by default; `design/specs/domain/README.md` links to `appeus/user-guides/domain.md` for guidance.

#### 5) Regenerate/repair metadata (staleness tracking)

v2.1 relies on per-target registry files:
- `design/generated/<target>/meta/outputs.json`

If missing or template-like, scripts should recreate/seed them. Run:
- `appeus/scripts/check-stale.sh --target <target>`
- `appeus/scripts/update-dep-hashes.sh --target <target> --all` (or `--route <Route>`)

#### 6) Script expectations (v2.1)

- There is no “pick next slice” script in v2.1. Use `check-stale.sh`, then the agent/user selects the next slice deliberately.
- Deprecated scripts removed in v2.1 include `generate-next.sh` and `regenerate.sh` (and earlier `generate-all.sh`).

#### 7) If the project needs to remove the toolkit

Use `appeus/scripts/detach-appeus.sh` to remove only Appeus symlinks (non-destructive). The user can later re-run `init-project.sh` to relink.

### Scaffold compatibility and repair
- **More robust project-root detection**: scripts no longer break when the `appeus/` link is a symlink (project root is discovered from the working directory rather than the physical path of the toolkit).
- **More resilient staleness flow**: staleness tooling will rebuild per-target outputs/registry files when missing or malformed, instead of trusting placeholder files.
- **Help output works anywhere**: `--help` for key scripts is now available even when you run it outside of an Appeus-initialized project folder.

### Commands and flags you may have missed
- **`init-project.sh`**
  - `--no-git` (and `APPEUS_GIT=0`) to skip initializing a git repo.
- **`add-app.sh`**
  - `--refresh` for idempotent updates when re-running app setup.
  - Prevent nested git repos under `apps/<target>/` by default (framework scaffolds that create `.git/` are cleaned unless explicitly enabled).
- **Removed**: `generate-all.sh` (redundant in a world where agents select slices deliberately).

### Documentation updates relevant to agents fixing legacy scaffolds
- `docs/DESIGN.md` was tightened to be more “Goals-oriented,” and now explicitly calls out that agents should be able to **recognize legacy/malformed scaffolds** and guide reorganization to the expected layout.
- Tactical details (framework adapters, version control, migration notes) are documented in `docs/ARCHITECTURE.md` rather than `docs/DESIGN.md`.

## v2 (tagged)

### What “v2” means (vs. v1)
- **Design-first bootstrap**: projects start from `design/` + decision docs, then add one or more app scaffolds.
- **Multi-target projects**: one repo can contain multiple apps (mobile/web/desktop) with shared schema/API and per-target UI stories/specs.
- **Progressive structure (v2.0; removed in v2.1)**: v2.0 projects could start in a single-app layout and migrate to a multi-app layout when adding a second app.

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


