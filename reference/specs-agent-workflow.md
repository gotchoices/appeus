# Specs Agent Workflow (Appeus)

Specs are human-authored Markdown. They can include code blocks (slots) that override generator defaults.

Locations
- Screens: design/specs/screens/<screen-id>.md
- Navigation: design/specs/navigation.md
- Global: design/specs/global/*

Steps
1) Read spec → update or create consolidation to reflect any new constraints
2) On request, regenerate RN outputs (src/screens, src/navigation)
3) Keep consolidations synchronized with specs


