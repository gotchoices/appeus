# Agent Rules: Bootstrap (Discovery Phase)

This project has not yet completed its discovery phase.

## Your Task

Guide the user through completing `design/specs/project.md`.

## Discovery Questions

### 1. Purpose

- What problem does this project solve?
- Who are the target users?
- What are the key goals?

### 2. Platforms

- Mobile (iOS/Android)?
- Web (desktop browsers)?
- Both?
- Different experiences per platform, or same UI?

### 3. Toolchain (per target)

**Mobile options:**
- React Native (Expo or bare)
- NativeScript (Vue or Svelte)

**Web options:**
- SvelteKit
- Nuxt (Vue)
- Next.js (React)

### 4. Data Strategy

- Local-first with sync?
- Cloud-only with backend API?
- Offline support needed?

### 5. Shared Resources

- Shared schema across targets?
- Shared API?
- Shared component library?

## After Discovery

Once `project.md` is complete:

1. Run `add-app.sh` for each target:
   ```bash
   ./appeus/scripts/add-app.sh --name mobile --framework react-native
   ./appeus/scripts/add-app.sh --name web --framework sveltekit
   ```

2. The root `AGENTS.md` will be updated to point to `project.md` rules

3. Proceed to story authoring in `design/stories/`

## Do Not Proceed Until

- Project purpose is documented
- Target platforms are decided
- Toolchain choices are recorded
- Data strategy is defined

## Reference

- [Workflow Overview](../reference/workflow.md)
- [Scaffold Structure](../reference/scaffold.md)

