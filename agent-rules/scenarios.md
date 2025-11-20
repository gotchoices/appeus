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

How to capture screenshots (Android)
- Use the helper: `appeus/scripts/android-screenshot.sh`
- Example:
  - `appeus/scripts/android-screenshot.sh --deeplink "chat://connections?variant=happy&locale=en" --output "design/generated/images/connections-list-happy.png" --reuse`
- Defaults:
  - AVD: `APPEUS_ANDROID_AVD` (default Medium_Phone_API_34)
  - App ID: `APPEUS_APP_ID` (default org.sereus.chat)
  - Delay: `APPEUS_SCREEN_DELAY` (default 3s before capture)
- File naming: `design/generated/images/<route>[-<variant>[-<locale>]].png`

Agent actions (explicit)
- You generate the exact screenshot commands for each scenario step and execute them.
- You ensure the PNGs are written to `design/generated/images/` with the expected filenames.
- After images are captured, you update/verify the scenario docs and `index.md` links.

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


