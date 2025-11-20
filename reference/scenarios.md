# Scenarios and Screenshots (Appeus)

Goal
- Produce reviewable scenario documents with clickable screenshots that deep-link into the live app.

Source of truth
- Markdown scenarios under `design/generated/scenarios/*.md`
- HTML is a publish artifact (optional).

Images
- Location: `design/generated/images/<Route>[-<variant>[-<locale>]].png`
- Built by deep-linking the running app and capturing a PNG.
  - Android helper: `appeus/scripts/android-screenshot.sh`
- Staleness: image is stale if missing or older than its screen code, relevant mocks, or navigation/global specs.

Deep links
- Pattern: `app://<route>?variant=<name>&locale=<tag>&scenario=<id>`
- Keep parameters stable and documented per screen.

Workflow
1) Ensure RN app is up-to-date (generate code workflow)
2) Build images for stale/missing targets (per screen/variant/locale)
3) Write Markdown narrative:
   - Explain persona, context, and intent
   - Embed the PNG for each step
   - Wrap each image (or a caption link) with the deep link so reviewers can click through
4) (Optional) Generate HTML for preview/publish

Future scripts
- `compute-image-stale.sh`: list stale targets as JSON
- `build-images.sh`: capture missing/stale images using screenshot helper
- `generate-scenarios.sh`: write scenario Markdown linking images and deep links, preserving human edits around generated blocks
- `preview-scenarios.sh` / `publish-scenarios.sh`: local server / static export


