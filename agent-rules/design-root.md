# AI Agent Rules: Design Root (Appeus)

You are in the project’s design root. This is the human-facing surface where stories, specs, and AI-generated consolidations live. Your job is to guide users from stories to a running React Native app via code generation, not SVG wireframes.

Core flow
1) Human writes stories in `design/stories/`
2) You derive consolidations in `design/generated/` (screens, navigation, api, scenarios) where helpful, with explicit dependency metadata (dependsOn/depHashes/provides/needs)
3) Human writes/edits specs in `design/specs/` (screens, navigation.md, global/*)
4) When asked, generate/update RN code in `src/screens/*` and `src/navigation/*`
5) Run the app and validate via scenarios (deep links), iterate

Vertical mode (preferred)
- Use `appeus/scripts/check-stale.sh` → `generate-next.sh` to pick the next screen (reachable from root) and produce a step-by-step plan.
- For each slice: consolidate → api → mocks → engine stubs → RN code → scenarios. Update status (staleness) afterward.

Precedence
- Human specs override AI consolidations; consolidations override defaults.

Where things live
- Stories: `design/stories/`
- Specs (human): `design/specs/` (screens/*, navigation.md, global/*)
- Generated (AI-only): `design/generated/` (screens/*, navigation.md, scenarios/*)
- App code (outputs): `src/screens/*`, `src/navigation/*`

Commands
- `appeus/scripts/check-stale` to list per-screen staleness (JSON + summary)
- `appeus/scripts/generate-next.sh` to pick next vertical slice and print a plan
- `appeus/scripts/regenerate --screen <Route>` to print the per-slice steps (agent performs them)

Mock variants
- For mock/demo-only data selection via deep links (e.g., `?variant=empty`), follow the guidance in `appeus/reference/mock-variants.md`.

Do
- Read stories and existing specs before proposing changes
- Consolidate requirements for multi-story screens in `design/generated/screens/*`
- Keep generated artifacts under `design/generated/*` fully regenerable
- Propose RN code updates only when the user asks to regenerate

Don’t
- Don’t edit `src/*` without an explicit regenerate request
- Don’t prioritize consolidations over human specs


