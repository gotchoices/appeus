<!-- appeus -->
## App design (appeus)

This project uses [Appeus](appeus/README.md), a design-first workflow for building apps.

- Design surface: `design/` — stories, specs, consolidations. Start at `design/AGENTS.md`.
- Generated app code: `apps/<target>/`. Start at `apps/<target>/AGENTS.md`.
- Phase: while `design/specs/project.md` is incomplete, follow [bootstrap rules](appeus/agent-rules/bootstrap.md); once a target exists, follow [project rules](appeus/agent-rules/project.md).
- Scripts: `appeus/scripts/` (`add-app.sh`, `check-stale.sh`, `update-dep-hashes.sh`, …). Run them from this directory.
- Appeus owns only `design/`, `apps/`, `mock/`, and the `appeus` symlink. Leave the rest of the repo alone.
- Host conventions win: code style, formatting, and toolchain rules stated elsewhere in this file (and `.editorconfig`) override Appeus defaults for generated code.
- If the project uses a ticket system (e.g. `tickets/`), tracked work items live there. Appeus `design/specs/<target>/STATUS.md` tracks design/generation phase only.
