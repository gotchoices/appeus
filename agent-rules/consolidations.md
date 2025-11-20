# AI Agent Rules: Consolidations (Appeus)

Consolidations capture what multiple stories imply about a screen, navigation, or components. They are AI-authored and regenerateable.

Before codegen
- If a target screen is stale per `check-stale`, refresh its consolidation first, then proceed to RN code generation. This preserves precedence and traceability.

Locations
- Screens: `design/generated/screens/<screen-id>.md` (or `.json`)
- Navigation: `design/generated/navigation.md`
- Scenarios: `design/generated/scenarios/*.md`

Rules
- Never override human specs; use them as the source of truth
- Keep consolidations up to date with story/spec changes and record dependency metadata
- Be explicit about variants and data requirements

Trigger
- Create/refresh consolidations when stories are added/edited or when specs clarify behavior

Dependency metadata (required)
- Add frontmatter fields:
  - provides: e.g., ["screen:ChatInterface"] or ["api:Threads"]
  - needs / usedBy: list related namespaces/screens when relevant
  - dependsOn: exact file paths read (stories/specs/navigation/global/screens/index)
  - depHashes: sha256(content) per dependsOn file

Where used
- Scripts use these fields to compute staleness and dependency graphs. RN generated files should embed AppeusMeta with dependsOn/depHashes for end-to-end tracking.


