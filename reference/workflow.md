# Appeus Workflow (RN-first)

Overview
- Stories → Consolidations → Specs → Codegen RN → Run → Iterate

Phases
1) Story authoring (design/stories)
2) Consolidations (design/generated) with dependency metadata (dependsOn/depHashes/provides/needs)
3) Specs (design/specs) add precision and overrides (human precedence)
4) Vertical slice generation (screens/navigation/API/mocks/engine stubs) on request
5) Validate via scenarios (design/generated/scenarios with deep links), update status

Precedence
- Specs > Consolidations > Defaults

Regeneration
- Human-triggered only. Use:
  - appeus/scripts/check-stale (per-screen summary + JSON)
  - appeus/scripts/generate-next.sh (pick next stale screen and print plan)
  - appeus/scripts/regenerate --screen <Route> (print per-slice steps)


