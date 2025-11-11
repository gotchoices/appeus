# AI Agent Rules: API (Appeus)

Purpose
- Infer and document the engine-facing API (procedures, data shapes) required by screens and stories.

Locations
- Human API specs: design/specs/api/*.md (or design/specs/api.md)
- Generated API consolidations: design/generated/api/*.md

Principles
- Derive capabilities from stories and screen specs
- Keep shapes stable; prefer versioned changes
- Human specs override generated consolidations

When asked to regenerate
- Ensure mock data keys/shapes match the API docs
- Update client adapters in src/data/* as needed


