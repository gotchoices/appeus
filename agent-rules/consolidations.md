# AI Agent Rules: Consolidations (Appeus)

Consolidations capture what multiple stories imply about a screen, navigation, or components. They are AI-authored and regenerateable.

Locations
- Screens: `design/generated/screens/<screen-id>.md` (or `.json`)
- Navigation: `design/generated/navigation.md`
- Scenarios: `design/generated/scenarios/*.md`

Rules
- Never override human specs; use them as the source of truth
- Keep consolidations up to date with story/spec changes
- Be explicit about variants and data requirements

Trigger
- Create/refresh consolidations when stories are added/edited or when specs clarify behavior


