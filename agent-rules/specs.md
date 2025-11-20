# AI Agent Rules: Specs (Appeus)

Specs clarify “how” for complex screens and navigation. They are free-form Markdown and can include code blocks (slots) that override generator defaults.

See also
- Spec schema: `appeus/reference/spec-schema.md`
- Generation precedence & staleness: `appeus/reference/generation.md`

Precedence
1) Specs (human) → authoritative
2) Consolidations (AI) → facts gathered from stories
3) Defaults and conventions

Locations
- Screen specs: `design/specs/screens/<screen-id>.md`
- Navigation spec: `design/specs/navigation.md`
- Global specs: `design/specs/global/*`

Workflow
1) When a spec is added/changed, update or create consolidations to match
2) On request, regenerate RN screens and navigation
3) Keep `design/generated/*` regenerable and avoid hand edits there

Regeneration
- Only on human request. Use `appeus/scripts/check-stale` to list what’s out-of-date and `appeus/scripts/regenerate` to perform updates.

Consolidate before codegen
- If the screen’s dependencies (stories/specs/navigation/global/index) are newer, refresh the corresponding consolidation first. Generators should prefer: specs > consolidations > defaults.

Naming
- Screen spec filenames use kebab-case (e.g., `chat-interface.md`). Code routes/components use PascalCase (e.g., `ChatInterface`). Maintain the mapping in `design/specs/screens/index.md`.


