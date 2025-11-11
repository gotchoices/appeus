# AI Agent Rules: App Source (src) (Appeus)

You are in the RN app source tree. Do not modify files unless the human has requested regeneration. All edits should be derived from `design/specs/*` (human) and `design/generated/*` (AI), with human precedence.

When regenerating
- Screens: write/update `src/screens/*` components
- Navigation: write/update `src/navigation/*` routes and options
- Ensure deep linking is configured and route params include `scenario` and `variant` when present
- Keep imports organized; prefer TypeScript when project language is TS

Out of scope
- Runtime schema rendering; Appeus uses code generation to produce RN code


