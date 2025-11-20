# AI Agent Rules: Project Root (Appeus)

This is an Appeus‑guided RN project. Use the rules in `design/` and `src/` to do the actual work; this file is only an orientation.

Start here
- Design surface: `design/AGENTS.md` (stories, specs, consolidations, scenarios)
- App source: `src/AGENTS.md` (screens, navigation, data adapters)

Workflows
- Generate code (stories/specs → RN code): see `design/AGENTS.md` and scripts under `appeus/scripts/` (`check-stale.sh`, `generate-next.sh`, `regenerate.sh`).
- Generate scenarios (screenshots → docs with deep links): see `appeus/scripts/android-screenshot.sh` and planned `build-images.sh`/`generate-scenarios.sh`.

References
- See `appeus/docs/` and `appeus/reference/` for complete guidance (generation precedence, staleness, testing, mock variants).

Conventions
- Precedence: human specs > AI consolidations > defaults.
- `design/generated/*` is regenerable; don’t hand‑edit.
- Use deep links for mock variants (`?variant=`) and optional `?locale=`.


