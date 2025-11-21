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
   - Persona (name/role) & Preconditions (short)
   - Steps (repeat for each screen; 4–8 typical):
     - 1–3 sentences narrative (persona intent + observation)
     - Clickable image linking to the deep link for that step:
       - `[![alt](../images/<file>.png)](app://<route>?variant=<name>&locale=<tag>&scenario=<id>)`
   - Alternates and Error paths (if relevant)
   - Keep narrative human-friendly; avoid technical jargon
5) Preview/publish (appgen-style)
   - Preview: `appeus/scripts/preview-scenarios.sh --port 8080`
     - Uses markserv to render Markdown directly from `design/generated/scenarios/`
     - Open `http://localhost:8080/index.md` (which links to other docs)
   - Publish: `appeus/scripts/publish-scenarios.sh --dest user@host:/var/www/scenarios`
     - Copies `design/generated/scenarios/*.md` + `images/*.png` to `design/generated/site/` and rsyncs
     - Remote can serve Markdown (e.g., with markserv) or a static site generator

Future scripts
- `compute-image-stale.sh`: list stale targets as JSON
- `build-images.sh`: capture missing/stale images using screenshot helper
- `generate-scenarios.sh`: assist in writing scenario Markdown by expanding a template with human-editable narrative sections
- `preview-scenarios.sh` / `publish-scenarios.sh`: local server / static export

Index
- Purpose: provide a simple, linear path for stakeholders to review the app end-to-end
- Location: `design/generated/scenarios/index.md`
- Contents: scenario titles with links to docs and their deep links; group by flow when useful (onboarding, invite/accept, chat, search, profile)


