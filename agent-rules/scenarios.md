# AI Agent Rules: Scenarios (Appeus)

Scenarios are narrative walkthroughs that deep-link into the running app (device/simulator). They live under `design/generated/scenarios/` and are fully regenerable. They should read like a user story with concrete personas and step-by-step visuals.

Image workflow
- Source of truth is Markdown scenarios; HTML is a publish artifact.
- Use screenshot builders (Android: `appeus/scripts/android-screenshot.sh`) to capture PNGs for each screen/variant/locale. See `appeus/reference/scenarios.md`.

Guidelines
- Create a scenarios index: maintain `design/generated/scenarios/index.md` in reviewer order (onboarding → core flows → alternates/errors).
- Use concrete personas and contexts; tie back to source stories (`design/stories/*`) at the top of each scenario doc.
- For each step:
  - Provide a short narrative
  - Include an “Open in App” deep link (`app://<route>?variant=<name>&locale=<tag>&scenario=<id>`)
  - Embed a screenshot PNG: `design/generated/images/<route>[-<variant>[-<locale>]].png`
- Cover at least: happy, empty, and error paths
- Keep in sync with current screens, navigation and i18n strings

Mock variants
- Prefer `?variant=` query in deep links for demo data selection. See `appeus/reference/mock-variants.md`.

When to regenerate
- After screens, navigation, i18n, or specs change
- After mock variants change (links or visuals)

Do not
- Don’t reference non-existent screens or routes
- Don’t hand-edit generated scenarios; update stories/specs then regenerate

Deep-link patterns
- Prefer `app://<route>?variant=<name>&locale=<tag>&scenario=<id>`; keep parameters stable and documented per screen in the scenario doc.

Quality checklist
- References source stories at top
- Persona and preconditions are clear
- Each step: narrative + deep-link + screenshot embed
- Includes alternates/errors when applicable
- Index updated to include new docs and order makes sense to a reviewer


