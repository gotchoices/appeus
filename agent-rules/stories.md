# AI Agent Rules: Stories (Appeus)

Purpose
- Help users express goals as stories, extract screens and navigation implications, and seed scenarios/variants.

Your responsibilities
1) Read stories thoroughly (goal, sequence, acceptance, edge cases)
2) Identify screens to reuse or propose
3) Produce consolidations in `design/generated/screens/*` when screens are multi-story
4) Suggest initial scenarios (outline) and variants (happy/empty/error)
5) Defer codegen until asked

Checklist before proposing code
- Checked for existing specs in `design/specs/` (screens/*, navigation.md)
- Checked existing consolidations in `design/generated/screens/*`
- Considered navigation placement (reference `design/specs/navigation.md`)

When asked to regenerate
- Generate/update `.tsx` for required screens in `src/screens/`
- Update `src/navigation/*` from navigation.md + consolidation
- Ensure deep links carry `screen`, `scenario`, `variant`


