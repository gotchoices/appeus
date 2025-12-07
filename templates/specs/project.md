# Project Spec

This document captures key decisions for the project. Complete this during the discovery phase before adding app scaffolds.

## Purpose

**What problem does this project solve?**

<describe the core problem and value proposition>

**Who are the target users?**

<describe primary user personas>

## Platforms

**What platforms will this project target?**

- [ ] Mobile (iOS/Android)
- [ ] Web (desktop browsers)
- [ ] Desktop (Electron, Tauri)

**Are experiences different per platform?**

<describe if mobile and web have different UX, or if they're responsive versions of the same>

## Apps

List the apps to be built:

| App Name | Platform | Framework | Status |
|----------|----------|-----------|--------|
| mobile | iOS/Android | react-native | planned |
| web | browser | sveltekit | planned |

## Toolchain

### Mobile (if applicable)

- Framework: react-native | nativescript-vue | nativescript-svelte
- Runtime: bare | expo
- Language: typescript | javascript
- Package manager: yarn | npm | pnpm

### Web (if applicable)

- Framework: sveltekit | nuxt | nextjs
- Language: typescript | javascript
- Package manager: npm | yarn | pnpm

## Data Strategy

**How will data be managed?**

- [ ] Local-first with sync
- [ ] Cloud-only (backend API)
- [ ] Offline support required
- [ ] Real-time updates needed

**Backend:**

<describe backend technology if applicable>

## Shared Resources

**What will be shared across targets?**

- [ ] Schema (data model) — `design/specs/schema/`
- [ ] API specs — `design/specs/api/`
- [ ] TypeScript types — `packages/shared/`
- [ ] Mock data — `mock/data/`

## Notes

<additional context, constraints, decisions>

---

*After completing this document, run `add-app.sh` for each target to scaffold the apps.*

