# Agent Rules: Bootstrap

> This project uses [Appeus](appeus/README.md), a design-first workflow for building apps.

This project has not yet completed the bootstrap/discovery phase (phase model: [phases](appeus/reference/phases.md)).

## Your Task

Guide the user through completing `design/specs/project.md`, then help them add the first target app.

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

Adding the first app also repoints the root `AGENTS.md` from `appeus/agent-rules/bootstrap.md` to `appeus/agent-rules/project.md`.

For the regeneration loop after discovery, see [workflow](appeus/reference/workflow.md) and [scaffold](appeus/reference/scaffold.md).
