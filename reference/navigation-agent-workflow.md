# Navigation Agent Workflow (Appeus)

Inputs
- Human navigation spec: design/specs/navigation.md
- AI navigation consolidation: design/generated/navigation.md

Outputs
- RN navigation: src/navigation/*

Rules
- Human spec precedence
- Keep deep link routing consistent with app config

Steps
1) Merge navigation.md with generated navigation (if present)
2) Update src/navigation/* and verify route names match screen outputs
3) Ensure deep links include scenario/variant where relevant


