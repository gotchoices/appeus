# Target Spec Human User Guide

This guide is for the **per-target specs folder**: `design/specs/<target>/`.

Your goal here is to describe what the app should do in **human-readable**, **user-observable** terms so the agent can generate good consolidations and code.

## What belongs in `design/specs/<target>/`

This folder holds specs that are specific to a single app target (mobile, web, desktop, etc.). Typical contents:

- `STATUS.md`: the phase checklist for this target
- `navigation.md`: the app’s navigation tree + deep links
- `screens/`: a screen plan + per-screen specs
- `components/`: reusable UI components (shared within this target)
- `global/`: target-wide UX/tooling decisions that affect generation

If the UI depends on shared domain behavior (data model + operations + rules + interfaces), that belongs in `design/specs/domain/` (shared across targets).

## How the agent uses these specs

- Specs are **authoritative**. They override previous consolidations and any generator defaults.
- Specs should stay readable. If you start writing “how to implement”, put that mapping in a consolidation under `design/generated/<target>/`.
- When you change specs, the agent should regenerate consolidations for affected slices before regenerating app code.

## `STATUS.md` (target phase checklist)

Use this file to track what’s complete and what is still missing for the target. It helps you and the agent:
- see what phase you’re in
- decide what to do next
- avoid generating code when key decisions are still missing

## `screens/` (screen plan + screen specs)

### `screens/index.md` (screen plan)

This is the “registry” of screens/routes for the target. It should be consistent with `navigation.md`.

Example:

```markdown
# Screens

| Screen Name | Route | Spec File | Status |
|-------------|-------|-----------|--------|
| Item List | ItemList | item-list.md | draft |
| Item Detail | ItemDetail | item-detail.md | draft |
| Profile | UserProfile | user-profile.md | draft |
```

### `screens/<screen>.md` (per-screen spec)

Write specs in terms of user-observable behavior:

Example:

```markdown
# Item List

## Purpose
Show the user a list of items they can browse.

## States
- Loading: show skeleton list
- Empty: show “No items yet” and a call to action
- Error: show a retry button and a clear message

## Actions
- Tap an item opens ItemDetail
- Pull to refresh reloads the list

## Acceptance
- User can open ItemDetail from the list
- Empty state appears when there are no items
```

## `components/` (reusable UI building blocks)

Use this folder for components shared across multiple screens in the same target.

Example component spec:

```markdown
# Component: ItemCard

## Purpose
Compact representation of an item in lists.

## States
- Normal
- Disabled (not tappable)

## Behavior
- Tapping triggers “open item detail”

## Acceptance
- Title and price are always visible
```

## `navigation.md` (sitemap + deep links)

Navigation is where you define the user-visible structure of the target:
- what screens exist and how they connect
- what the root of the app is (tabs/drawer/home)
- required route parameters (e.g. `id`)
- which routes should be deep-linkable (for scenarios/testing)

Example:

```markdown
# Navigation

## Sitemap

- **Main Tabs**
  - Home (tab root)
  - Search (tab root)
  - Profile (tab root)

- **Home**
  - ItemList (root)
  - ItemDetail (push from ItemList)
  - Cart (modal)

## Route Parameters

- ItemDetail:
  - id (required)
  - variant (optional, mock-only, for scenarios)

## Deep Links

Scheme: myapp://

- myapp://screen/ItemList?variant=happy
- myapp://screen/ItemList?variant=empty
- myapp://screen/ItemDetail?id=123&variant=happy
```

## `global/` (target-wide decisions that affect generation)

This is for decisions that apply across screens for the target. Examples:
- UI patterns (loading/empty/error conventions)
- accessibility expectations
- styling rules (spacing, typography approach)
- dependency decisions that matter to generation

Example:

```markdown
# UI conventions (target)

- Lists use pull-to-refresh when possible
- Empty states include a next action (“Create item”, “Import”, etc.)
- Errors use a retry-first pattern; show a support link only after multiple failures
```

## Helpful links

- `appeus/docs/DESIGN.md` (principles + phases)
- `appeus/docs/GENERATION.md` (how specs influence staleness and generation)

