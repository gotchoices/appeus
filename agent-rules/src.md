# AI Agent Rules: App Source (src) (Appeus)

You are in the RN app source tree. Do not modify files unless the human has requested regeneration. All edits should be derived from `design/specs/*` (human) and `design/generated/*` (AI), with human precedence.

See also
- Generation: `appeus/reference/generation.md`
- Mock variants: `appeus/reference/mock-variants.md`
- Testing: `appeus/reference/testing.md`

When regenerating
- Screens: write/update `src/screens/*` components
- Navigation: write/update `src/navigation/*` routes and options
- Ensure deep linking is configured and route params include `scenario` and `variant` when present
- Keep imports organized; prefer TypeScript when project language is TS
 - Add an AppeusMeta header at top of generated files including dependsOn and depHashes (see GENERATION.md)

Mock variants
- Do not hard-code variants into production logic. Mock/demo variants are supplied via deep links and handled through a small context under `src/mock/*`. See `appeus/reference/mock-variants.md`.

Internationalization
- Use a translation hook (current minimal `useT()` or i18next’s `useTranslation` when adopted). Avoid hard-coded UI strings.

Out of scope
- Runtime schema rendering; Appeus uses code generation to produce RN code


