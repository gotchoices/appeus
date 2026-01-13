# Spec Schema

Structure and conventions for human-authored specs.

## Overview

Specs live in `design/specs/` and provide authoritative details that override AI consolidations.

## Spec Writing Style (User-Observable)

Specs should remain **human-readable** and describe the **user-observable UX contract**:

- **What the user sees** (states, empty/error conditions)
- **What the user can do** (actions, constraints, confirmations)
- **What must be true** (invariants, validation, ordering rules)
- **Acceptance criteria** (testable outcomes)

Avoid turning specs into programmer-facing design docs (component APIs, internal state machines, reducer tables). That programmer mapping belongs in **consolidations** (`design/generated/…`).

If a spec is becoming hard for the human to read, move implementation-structure detail into the consolidation and keep the spec at the behavior level.

Also keep the project’s **delivery posture** in mind (from `design/specs/project.md`): prototype/MVP may accept simpler implementations, while production/industrial-strength should call out performance/robustness expectations explicitly (still at the user-observable level).

## Spec Types

| Type | Canonical Path |
|------|------------------------|
| Project | `design/specs/project.md` |
| Domain contract (as needed) | `design/specs/domain/*.md` |
| Screen | `design/specs/<target>/screens/*.md` |
| Component | `design/specs/<target>/components/*.md` |
| Navigation | `design/specs/<target>/navigation.md` |
| Global | `design/specs/<target>/global/*` |

## Domain Contract Specs (shared)

Domain contract specs live under `design/specs/domain/` and should remain human-readable. Use whatever files make sense for the project (for example, `schema.md`, `ops.md`, `rules.md`, `interfaces.md`).

When a screen or component “needs” domain behavior, express the need in terms of the domain contract (entities/operations/rules), not internal modules or an API/schema folder split.

## Screen Spec Format

### Frontmatter (Minimum)

```yaml
---
id: item-list                 # kebab-case identifier (matches filename)
route: ItemList               # PascalCase route/component name
variants: [happy, empty, error]  # Mock variants for testing/scenarios (see `reference/mock-variants.md`)
---
```

### Optional Frontmatter

```yaml
---
id: item-list
route: ItemList
description: Displays a list of items with search and filter
provides: ["screen:ItemList"]
tags: [browsing, list]
needs: ["domain:Op:Items.list", "domain:Entity:Item"] # domain contract primitives
---
```

### Body

Free-form Markdown describing:
- Layout and behavior
- Edge cases and error handling
- Accessibility considerations
- References to related screens

## Component Spec Format

Component specs are for reusable UI building blocks (e.g., `AccountAutocomplete`, `TransactionResultsTable`).
They should stay **user-observable** (behavior, states, constraints) and remain human-readable.

### Frontmatter (Minimum)

```yaml
---
id: account-autocomplete          # kebab-case identifier (matches filename)
name: AccountAutocomplete         # stable component name
---
```

### Body (Recommended Sections)

- Purpose (what the user is trying to accomplish with this element)
- Interaction behavior (keyboard, focus, selection rules)
- States (loading/empty/error/disabled)
- Inputs/Outputs (what the user provides, what the UI emits/changes)
- Acceptance criteria (testable outcomes)

Implementation mapping (props/events/types, file paths) belongs in consolidations.

### No Code in Specs

Don’t embed source code in specs. If you need to record implementation mapping (types, module boundaries, adapter strategy), put it in the consolidation under `design/generated/<target>/`.

## Navigation Spec Format

```markdown
# Navigation

## Sitemap

- **Main Tab** (root)
  - ItemList (tab root)
  - ItemDetail (push from ItemList)
  - Cart (modal)
- **Profile Tab**
  - UserProfile (tab root)
  - Settings (push)

## Deep Links

Scheme: `myapp://`

| Pattern | Screen | Params |
|---------|--------|--------|
| `/screen/ItemList` | ItemList | variant, category |
| `/screen/ItemDetail` | ItemDetail | id, variant |
| `/screen/UserProfile` | UserProfile | variant |

## Route Options

| Route | Title | Header |
|-------|-------|--------|
| ItemList | "Items" | large |
| ItemDetail | "{item.name}" | standard |
```

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Spec filenames | kebab-case | `item-list.md`, `user-profile.md` |
| Route names | PascalCase | `ItemList`, `UserProfile` |
| Schema IDs | kebab-case | `item`, `user-profile` |
| API namespaces | PascalCase | `Items`, `Users` |

## Mapping Index

Maintain in `design/specs/<target>/screens/index.md`:

```markdown
# Screens Index

| Screen Name | Route | Spec File | Status |
|-------------|-------|-----------|--------|
| Item List | ItemList | item-list.md | complete |
| Item Detail | ItemDetail | item-detail.md | draft |
| User Profile | UserProfile | user-profile.md | complete |
```

## Precedence

When artifacts disagree, apply the precedence rules in `reference/precedence.md`.

After spec changes, refresh corresponding consolidations before codegen.
