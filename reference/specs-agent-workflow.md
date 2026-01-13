# Specs Agent Workflow

How to process human-authored specs and keep consolidations synchronized.

This doc is intentionally focused on spec handling only. For the overall per-slice loop, see [Workflow](workflow.md) and [Precedence](precedence.md).

## Paths

| Type | Canonical Path (v2.1) |
|------|------------------------|
| Screen specs | `design/specs/<target>/screens/*.md` |
| Navigation | `design/specs/<target>/navigation.md` |
| Domain contract (as needed) | `design/specs/domain/*.md` |
| Global | `design/specs/<target>/global/*` |

## Principles

- Specs are human-authored Markdown
- Specs override consolidations and defaults
- Specs should remain human-readable; keep programmer mapping in consolidations

## Workflow

### 1. Read Spec

Parse the spec for:
- Frontmatter (id, route, variants, etc.)
- Layout and behavior descriptions
- Dependencies (needs, provides)

### 2. Update Consolidations

Refresh the corresponding consolidation to reflect spec constraints:
- Update `design/generated/<target>/screens/<Route>.md`
- Include spec in dependsOn
- Ensure the per-target registry exists and reflects the slice’s `dependsOn`: `design/generated/<target>/meta/outputs.json`

### 3. Generate Code (On Request)

When user requests regeneration:
- Read spec and consolidation
- Treat specs as human-readable constraints; put programmer mapping into consolidations
- Write to `apps/<target>/src/` (framework-specific)
- Update navigation

### 4. Keep Synchronized

After any spec change:
- Consolidation becomes stale
- Regenerate consolidation before codegen
- Run `check-stale.sh --target <target>` to verify

## No Code in Specs (v2.1)

Don’t embed code in specs. If the user needs a “how we’ll implement this” note, put it in the consolidation under `design/generated/<target>/`.

## See Also

- [Spec Schema](spec-schema.md)
- [Generation Workflow](generation.md)
- [Codegen Guide](codegen.md)
