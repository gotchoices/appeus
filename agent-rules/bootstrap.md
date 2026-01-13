# Agent Rules: Bootstrap

> This project uses [Appeus](appeus/README.md), a design-first workflow for building apps.

This project has not yet completed discovery phase. See [phases](appeus/reference/phases.md).

## Your Task

Guide the user through completing `design/specs/project.md`.

## Discovery Questions

1. **Purpose** — What problem? Who are users? What’s the **delivery posture** (prototype/MVP/production)?
2. **Platforms** — Mobile? Web? Both?
3. **Toolchain** — Which frameworks per target?
4. **Data Strategy** — Local-first? Cloud API? Distributed? Offline?
5. **Quality / performance posture** — Optimize for speed or industrial-strength? Any “must stay fast” interactions?

## Supported Frameworks

| Type | Supported | Planned |
|------|-----------|---------|
| Mobile | react-native, nativescript-svelte | nativescript-vue, capacitor |
| Web | sveltekit | nuxt, nextjs |
| Desktop | — | tauri |

## After Discovery

```bash
./appeus/scripts/add-app.sh --name mobile --framework react-native
./appeus/scripts/add-app.sh --name web --framework sveltekit
```

Then proceed to story authoring in `design/stories/<target>/`.

After adding the first app target, phase tracking for that target should use `design/specs/<target>/STATUS.md`.

## Reference

- [Workflow](appeus/reference/workflow.md)
- [Phases](appeus/reference/phases.md)
