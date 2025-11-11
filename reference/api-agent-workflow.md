# API Agent Workflow (Appeus)

Goal
- Define engine-facing procedures and data shapes needed by screens/stories.

Sources
- design/specs/screens/*.md (human)
- design/specs/navigation.md (human)
- design/generated/screens/*.md (AI consolidation)

Outputs
- design/specs/api/*.md (human-authored procedures)
- design/generated/api/*.md (AI consolidations)
- mock/data/* files matching shapes and variants

Rules
- Human API specs override generated consolidations
- Keep mock data and client adapters aligned with API docs


