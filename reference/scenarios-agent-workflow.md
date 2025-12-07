# Scenarios Agent Workflow

How to generate scenario documents with screenshots.

## When to Generate

- After screen/navigation are stable for the feature
- After mock data variants are defined
- When preparing for stakeholder review

## Paths

| Content | Single-App | Multi-App |
|---------|------------|-----------|
| Images config | `design/generated/images/index.md` | `design/generated/<target>/images/index.md` |
| Screenshots | `design/generated/images/*.png` | `design/generated/<target>/images/*.png` |
| Scenario docs | `design/generated/scenarios/*.md` | `design/generated/<target>/scenarios/*.md` |
| Screen code | `apps/<name>/src/screens/*.tsx` | `apps/<name>/src/screens/*.tsx` |

## Prerequisites

- Screens generated and working
- Deep linking configured in app
- Mock data variants in place
- Android emulator running (or iOS simulator)

## Workflow

### 1. Configure Screenshots

Edit `design/generated/images/index.md` frontmatter:

```yaml
---
appId: com.example.myapp
scheme: myapp

screenshots:
  - route: ItemList
    variant: happy
    file: item-list-happy.png
    deps:
      - apps/mobile/src/screens/ItemList.tsx

  - route: ItemList
    variant: empty
    file: item-list-empty.png

  - route: ItemDetail
    variant: happy
    params:
      id: "123"
    file: item-detail-happy.png
---
```

### 2. Capture Screenshots

Run the capture script:

```bash
appeus/scripts/build-images.sh --reuse --window [--target mobile]
```

Options:
- `--reuse` — Use running emulator
- `--window` — Show emulator (not headless)
- `--force` — Recapture even if fresh
- `--target` — Target name for multi-app

The script:
- Reads config from `images/index.md`
- Builds deep links from route/variant/params
- Captures PNGs via `android-screenshot.sh`
- Skips fresh images unless `--force`

### 3. Write Scenario Docs

For each story, create scenario doc:

**Location:** `design/generated/scenarios/<story-id>.md`

**Structure:**

```markdown
# Scenario: Browsing Items

Source: [01-browsing.md](../../stories/01-browsing.md)

## Persona

Regular user with existing account.

## Preconditions

- User is logged in
- Items exist in the system

## Steps

### Step 1: View Item List

User opens the app and sees available items.

[![Item list](../images/item-list-happy.png)](myapp://screen/ItemList?variant=happy)

### Step 2: Empty State

When no items exist, user sees empty state message.

[![Empty list](../images/item-list-empty.png)](myapp://screen/ItemList?variant=empty)

### Step 3: View Details

User taps an item to see its details.

[![Item detail](../images/item-detail-happy.png)](myapp://screen/ItemDetail?variant=happy&id=123)

## Alternates

### Error Loading

When loading fails, user sees error message with retry option.

[![Error state](../images/item-list-error.png)](myapp://screen/ItemList?variant=error)
```

### 4. Update Scenario Index

Maintain `design/generated/scenarios/index.md`:

```markdown
# Scenarios

Review order for stakeholders:

1. [Browsing Items](01-browsing.md) — Core browsing flow
2. [Managing Cart](02-cart.md) — Add/remove items
3. [Checkout](03-checkout.md) — Purchase flow
4. [Error Handling](04-errors.md) — Error states
```

## Output Artifacts

| Artifact | Path |
|----------|------|
| Screenshots | `design/generated/images/*.png` |
| Image config | `design/generated/images/index.md` |
| Scenario docs | `design/generated/scenarios/*.md` |
| Scenario index | `design/generated/scenarios/index.md` |

## Preview and Publish

### Local Preview

```bash
appeus/scripts/preview-scenarios.sh --port 8080
```

### Publish to Web

```bash
appeus/scripts/publish-scenarios.sh --dest user@host:/var/www/scenarios
```

## See Also

- [Scenarios Reference](scenarios.md)
- [Mock Variants](mock-variants.md)
- [Deep Links](codegen.md#deep-links)
