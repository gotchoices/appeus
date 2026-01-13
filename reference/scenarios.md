# Scenarios and Screenshots

Appeus methodology for creating reviewable scenario documents with clickable screenshots.

Scenarios are a storyboard layer for review and testing: screenshots are embedded in markdown and link to deep links that open the app in a specific UI state (typically via mock variants; see [Mock Variants](mock-variants.md)).

## Paths

| Content | Canonical Path |
|---------|------------------------|
| Images config | `design/generated/<target>/images/index.md` |
| Screenshots | `design/generated/<target>/images/*.png` |
| Scenario docs | `design/generated/<target>/scenarios/*.md` |
| Published HTML | `design/generated/<target>/site/` |

## Images Configuration

### Frontmatter Schema

In `images/index.md`:

```yaml
---
appId: com.example.myapp        # Android/iOS bundle ID
scheme: myapp                   # Deep link scheme

screenshots:
  - route: ItemList             # Screen route name
    variant: happy              # Mock data variant (optional)
    locale: en                  # Locale (optional, default: en)
    params:                     # Additional URL params (optional)
      category: books
    file: item-list-happy.png   # Output filename
    deps:                       # Files that trigger recapture (optional)
      - apps/mobile/src/screens/ItemList.tsx

  - route: ItemList
    variant: empty
    file: item-list-empty.png

  - route: UserProfile
    variant: happy
    params:
      id: "123"
    file: user-profile-happy.png
---
```

### Deep Link Construction

The capture script builds links as:
```
{scheme}://screen/{route}?variant={variant}&locale={locale}&{params}
```

Example: `myapp://screen/ItemList?variant=happy&category=books`

Variant semantics are described in [Mock Variants](mock-variants.md); deep link structure is described in `reference/codegen.md` under “Deep Links”.

## Capture Scripts

### Batch Capture

```bash
appeus/scripts/build-images.sh [--reuse] [--window] [--force] [--target <target>]
```

Options:
- `--reuse` — Use existing emulator if running
- `--window` — Show emulator window (not headless)
- `--force` — Recapture even if fresh
- `--target` — Target name (defaults when only one target exists)

### Android Helper

```bash
appeus/scripts/android-screenshot.sh \
  --deeplink "myapp://screen/ItemList?variant=happy" \
  --output "./design/generated/<target>/images/item-list-happy.png" \
  --app-id "com.example.myapp"
```

Environment defaults:
- `APPEUS_ANDROID_AVD` — AVD name (default: Medium_Phone_API_34)
- `APPEUS_SCREEN_DELAY` — Seconds to wait before capture (default: 3)
- `APPEUS_APP_ID` — App bundle ID (required or via --app-id)

### iOS (Manual)

```bash
xcrun simctl openurl booted "myapp://screen/ItemList?variant=happy"
xcrun simctl io booted screenshot "item-list-happy.png"
```

## Staleness

An image is stale if:
- Missing from disk
- Older than any file in its `deps` array
- Older than the screen's source file

## Scenario Documents

### Location

`design/generated/<target>/scenarios/<story-id>.md`

### Structure

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

User opens the app and sees a list of items.

[![Item list](../images/item-list-happy.png)](myapp://screen/ItemList?variant=happy)

### Step 2: Empty State

When no items exist, user sees empty state.

[![Empty list](../images/item-list-empty.png)](myapp://screen/ItemList?variant=empty)

### Step 3: Select Item

User taps an item to view details.

[![Item detail](../images/item-detail-happy.png)](myapp://screen/ItemDetail?variant=happy&id=123)

## Alternates

### Error State

When loading fails, user sees error message.

[![Error](../images/item-list-error.png)](myapp://screen/ItemList?variant=error)
```

### Image Embed Format

```markdown
[![alt text](../images/filename.png)](scheme://screen/Route?variant=name)
```

The image is clickable, linking to the app deep link.

## Scenario Index

Location: `design/generated/<target>/scenarios/index.md`

Purpose: Linear path for stakeholders to review the app end-to-end.

```markdown
# Scenarios

1. [Browsing Items](01-browsing.md)
2. [Managing Profile](02-profile.md)
3. [Error Handling](03-errors.md)
```

## Preview and Publish

### Local Preview

```bash
appeus/scripts/preview-scenarios.sh --port 8080
```

Opens scenarios rendered via markserv; images appear inline.

### Publish to Web

```bash
appeus/scripts/publish-scenarios.sh --dest user@host:/var/www/myapp/scenarios
```

Generates static HTML in `design/generated/<target>/site/` and syncs to destination.
