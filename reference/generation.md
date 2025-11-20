# Generation Workflow (Appeus)

Purpose
- Define the agent-facing workflows for producing app code and scenarios from stories/specs, with precedence and staleness rules.

Two workflows
1) Generate code (stories/specs → RN code)
   - Inputs: `design/stories/*`, `design/specs/*`
   - Steps (vertical slice):
     1. Consolidate: refresh `design/generated/screens/<Route>.md` if any dependency is stale
     2. API consolidations (if needed)
     3. Mocks and engine adapters
     4. RN outputs: `src/screens/*`, `src/navigation/*`
     5. Update staleness graph
   - Precedence: human specs > AI consolidations > defaults
   - Scripts: `appeus/scripts/check-stale.sh`, `appeus/scripts/generate-next.sh`, `appeus/scripts/regenerate.sh`
   - Trigger phrases (examples): “generate”, “generate code”, “regenerate next slice”

Agent cadence
- Before any generation step, the agent should run `appeus/scripts/check-stale.sh` to refresh the staleness graph, then select the next slice with `appeus/scripts/generate-next.sh` (or target a specific route with `regenerate`).

2) Generate scenarios (screenshots → narrative Markdown)
   - Inputs: current RN app + deep links for target screens/variants/locales
   - Steps:
     1. Determine target images (missing or stale)
     2. Capture screenshots: `appeus/scripts/android-screenshot.sh`
     3. Author scenario Markdown in `design/generated/scenarios/*.md`
        - Embed PNGs stored under `design/generated/images/`
        - Wrap images with deep-link anchors so reviewers can click through
     4. (Optional) Publish HTML for viewing
   - Scripts (current and planned):
     - now: `appeus/scripts/android-screenshot.sh`
     - next: `compute-image-stale.sh`, `build-images.sh`, `generate-scenarios.sh`, `preview-scenarios.sh`
   - Trigger phrases (examples): “generate scenarios”, “refresh scenarios for <Route>”

Staleness and dependencies
- Consolidations include frontmatter: provides/needs/dependsOn/depHashes
- Dependency registry (preferred): for each output, write an entry to `design/generated/meta/outputs.json`:
  ```json
  {
    "outputs": [
      {
        "route": "ConnectionsList",
        "output": "src/screens/ConnectionsList.tsx",
        "dependsOn": [
          "design/generated/screens/ConnectionsList.md",
          "design/specs/screens/connections-list.md",
          "design/specs/navigation.md"
        ],
        "depHashes": { "design/specs/screens/connections-list.md": "sha256:..." }
      }
    ]
  }
  ```
- Inline headers (optional): you may also include an `AppeusMeta` comment in generated files for human readers, but the registry governs staleness.
- A screen or image is stale if missing or older than any of its dependencies (specs/stories/navigation/global or mocks)

Conventions
- Route names: PascalCase (e.g., `ChatInterface`)
- Screen spec filenames: kebab-case (e.g., `chat-interface.md`)
- Maintain mapping in `design/specs/screens/index.md`

Agent guidance
- Consolidate first if stale; then generate RN code
- For scenarios, prefer Markdown as source of truth; HTML is for publishing
- Use deep links to supply variants (`?variant=`) and locale (`?locale=`); keep links stable per screen


