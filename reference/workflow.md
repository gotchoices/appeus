# Appeus Workflow (RN-first)

Overview
- Stories → Consolidations → Specs → Codegen RN → Run → Iterate

Phases
1) Story authoring (design/stories)
2) Consolidations (design/generated) when multiple stories touch a screen/nav
3) Specs (design/specs) add precision and overrides
4) Regenerate RN code (src/screens, src/navigation) when requested
5) Validate via scenarios (design/generated/scenarios with deep links)

Precedence
- Specs > Consolidations > Defaults

Regeneration
- Human-triggered only. Use appeus/scripts/check-stale and appeus/scripts/regenerate.


