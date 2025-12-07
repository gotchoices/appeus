# Appeus

Appeus is a design-first workflow that turns user stories into running applications. Instead of scaffolding a framework and then bolting on design, Appeus starts with design decisions and stories, then instantiates the appropriate app scaffolds.

## What's New in v2

- **Design-first:** Project decisions are documented before any framework code is generated
- **Multi-target:** A single project can contain multiple apps (mobile, web, desktop)
- **Progressive structure:** Single-app projects use flat layouts; multi-app projects use per-target subdirectories
- **Shared schema:** Data model and API specs are shared across targets
- **Framework adapters:** Support for React Native, SvelteKit, and more

## Core Workflow

1. **Init project** — Create project folder with decision document template
2. **Discovery** — Agent guides you through toolchain and architecture decisions
3. **Add apps** — Scaffold one or more apps based on your decisions
4. **Write stories** — Define user stories per target
5. **Derive schema** — Agent extracts shared data model from all stories
6. **Generate code** — Vertical slicing: one screen/page at a time
7. **Review via scenarios** — Screenshots with deep links for stakeholder review

## Toolkit Layout

```
appeus/
├── docs/           # For developing appeus itself
├── agent-rules/    # Brief rules for AI agents (linked via AGENTS.md)
├── reference/      # Detailed workflow docs (linked from agent-rules)
├── user-guides/    # Human-facing guides (linked via README.md)
├── templates/      # Starter files copied into projects
├── scripts/        # Automation (init, add-app, check-stale, etc.)
├── QUICKSTART.md   # Getting started guide
└── README.md       # This file
```

## Getting Started

See `QUICKSTART.md` for step-by-step instructions.

## Key Concepts

- **Stories** — User-facing requirements ("As a user, I want...")
- **Specs** — Human-authored technical details (precedence over AI)
- **Consolidations** — AI-derived facts from stories (regenerable)
- **Scenarios** — Screenshots with deep links for review
- **Vertical slicing** — Generate one navigable screen at a time

## Documentation

- `docs/DESIGN.md` — Vision, principles, architecture
- `docs/GENERATION.md` — Staleness, dependencies, generation flow
- `docs/ARCHITECTURE.md` — Folder structure reference
- `docs/STATUS.md` — Development roadmap

## Version History

- **v2** (current) — Design-first, multi-target support
- **v1** — RN-first workflow (available on `v1` branch)
