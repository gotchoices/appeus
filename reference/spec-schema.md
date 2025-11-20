# Spec Schema (Appeus)

Purpose
- Define minimal, consistent frontmatter and structure for human-authored specs under `design/specs/*`.

Frontmatter (minimum)
```yaml
id: ChatInterface            # human-friendly identifier (kebab or Pascal ok)
route: ChatInterface         # RN route/component name (PascalCase)
variants: [happy, empty]     # optional; demo/mock variants considered
```

Optional fields
- description: short purpose text
- provides: ["screen:ChatInterface"] (helps cross-referencing)
- needs: ["api:Strands"] (hints dependencies)
- tags: [search, messaging]

Body
- Free-form Markdown describing layout, behaviors, and edge cases.
- May include code blocks with “generation slots” the generator should honor.

Conventions
- Screen spec filenames: kebab-case (e.g., `chat-interface.md`)
- Maintain mapping from filenames → route in `design/specs/screens/index.md`

Precedence and updates
- Specs override consolidations; consolidations override defaults.
- After spec changes, refresh corresponding consolidations before RN codegen.


