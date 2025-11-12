# Code Generation Guide (Appeus)

Inputs
- Human specs: design/specs/screens/*.md, design/specs/navigation.md, design/specs/global/*
- AI consolidations: design/generated/screens/*.md, design/generated/navigation.md

Outputs
- RN screens: src/screens/*
- Navigation: src/navigation/*

Rules
- Human specs override consolidations
- Idempotent writes; only change files when inputs change
- Don’t write unless user requests regeneration
 - Embed AppeusMeta header with dependsOn/depHashes in generated files
 - Follow vertical slicing when possible (see scripts/generate-next.sh)

Mapping (example)
- screen-id: chat-interface -> screen file: ChatInterface.tsx, route: ChatInterface
- slots: imports/component/styles in spec override defaults

Deep links
- myapp://screen/<RouteName>?scenario=<id>&variant=<name>


