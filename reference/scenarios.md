# Scenarios and Screenshots (Appeus)

Goal
- Produce reviewable scenario documents with clickable screenshots that deep-link into the live app.

Source of truth
- Markdown scenarios under `design/generated/scenarios/*.md`
- HTML is a publish artifact (optional).

Images
- Location: `design/generated/images/<Route>[-<variant>[-<locale>]].png`
- Built by deep-linking the running app and capturing a PNG.
  - Android helper: `appeus/scripts/android-screenshot.sh` (the agent generates and runs these commands)
    - Example:  
      `appeus/scripts/android-screenshot.sh --deeplink "chat://connections?variant=happy&locale=en" --output "design/generated/images/connections-list-happy.png" --reuse`
    - Defaults via env: `APPEUS_ANDROID_AVD` (emulator AVD), `APPEUS_APP_ID` (bundle id), `APPEUS_SCREEN_DELAY` (seconds)
  - iOS (manual): `xcrun simctl openurl booted "<deeplink>"; xcrun simctl io booted screenshot "<output.png>"`
- Staleness: image is stale if missing or older than its screen code, relevant mocks, or navigation/global specs.

Deep links
- Pattern: `app://<route>?variant=<name>&locale=<tag>&scenario=<id>`
- Keep parameters stable and documented per screen.

Workflow
1) Ensure RN app is up-to-date (generate code workflow)
2) Build or refresh images for stale/missing targets (per screen/variant/locale)
3) Create/maintain `design/generated/scenarios/index.md` with a logical review order
4) For each scenario doc (use the template in `appeus/templates/generated/scenario-template.md`):
   - Header: Title; “Based on” link(s) to `design/stories/*`
   - Persona & Preconditions
   - Steps (repeat for each screen):
     - Short narrative of intent and observation
     - Deep link: `app://<route>?variant=<name>&locale=<tag>&scenario=<id>`
     - Screenshot embed (PNG path under `design/generated/images/…`)
   - Alternates and Error paths
   - Notes on data/API if relevant
5) (Optional) Generate HTML for preview/publish

Future scripts
- `compute-image-stale.sh`: list stale targets as JSON
- `build-images.sh`: capture missing/stale images using screenshot helper
- `generate-scenarios.sh`: assist in writing scenario Markdown by expanding a template with human-editable narrative sections
- `preview-scenarios.sh` / `publish-scenarios.sh`: local server / static export

Index
- Purpose: provide a simple, linear path for stakeholders to review the app end-to-end
- Location: `design/generated/scenarios/index.md`
- Contents: scenario titles with links to docs and their deep links; group by flow when useful (onboarding, invite/accept, chat, search, profile)


