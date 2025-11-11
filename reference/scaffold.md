# Scaffold (Appeus)

Canonical project structure for RN-first Appeus projects.

```
project-root/
├── appeus -> /some/path/to/appeus
├── design/
│   ├── AGENTS.md -> ../appeus/agent-rules/design-root.md
│   ├── stories/
│   │   └── AGENTS.md -> ../../appeus/agent-rules/stories.md
│   ├── generated/
│   │   ├── AGENTS.md -> ../../appeus/agent-rules/consolidations.md
│   │   ├── navigation.md
│   │   ├── scenarios/
│   │   ├── screens/
│   │   ├── api/
│   │   └── components/
│   └── specs/
│       ├── AGENTS.md -> ../appeus/agent-rules/specs.md
│       ├── navigation.md
│       ├── screens/
│       ├── api/
│       └── global/
├── mock/
│   ├── data/
│   └── server/
├── src/
│   ├── AGENTS.md -> ../appeus/agent-rules/src.md
│   ├── navigation/
│   ├── screens/
│   ├── components/
│   ├── state/
│   ├── data/
│   └── engine/
└── package.json, app.json|app.config.ts, tsconfig.json|jsconfig.json
```

Notes
- Docs are under `appeus/reference/`; agent rules link from `design/*` and `src/` into the right references.
- `design/generated/*` is fully regenerable and should not be hand-edited.
- Code generation targets `src/navigation/*` and `src/screens/*` on human request.


