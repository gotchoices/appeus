# Scenarios and Screenshots (Appeus)

## Goal
Produce reviewable scenario documents with clickable screenshots that deep-link into the running app.

## Source of Truth
- Screenshot config: `design/generated/images/index.md` (YAML frontmatter)
- Scenario docs: `design/generated/scenarios/*.md`
- HTML is a publish artifact (optional)

## Images Configuration

### Frontmatter Schema

```yaml
---
appId: org.example.myapp      # Android/iOS bundle ID
scheme: myapp                  # Deep link scheme

screenshots:
  - route: Home                # Screen route name
    variant: happy             # Mock data variant (optional)
    locale: en                 # Locale (optional, default: en)
    params:                    # Additional URL params (optional)
      tab: settings
    file: home-happy.png       # Output filename
    deps:                      # Files that trigger recapture (optional)
      - src/screens/Home.tsx
---
```

### Deep Link Construction

The capture script builds links as:
```
{scheme}://screen/{route}?variant={variant}&locale={locale}&{params}
```

## Capture Script

`appeus/scripts/build-images.sh [--reuse] [--window] [--force]`

- Reads config from `images/index.md`
- Requires `yq` for YAML parsing
- Uses `android-screenshot.sh` helper for each screenshot
- Skips fresh images unless `--force`

### Android Helper

`appeus/scripts/android-screenshot.sh --deeplink URL --output PATH --app-id ID [--reuse] [--window]`

Env defaults:
- `APPEUS_ANDROID_AVD` (default: Medium_Phone_API_34)
- `APPEUS_SCREEN_DELAY` (default: 3s)

### iOS (Manual)
```bash
xcrun simctl openurl booted "<deeplink>"
xcrun simctl io booted screenshot "<output.png>"
```

## Staleness

An image is stale if:
- Missing
- Older than any file in its `deps` array
- Older than `src/screens/{Route}.tsx`

## Scenario Docs

Location: `design/generated/scenarios/<story-id>.md`

Structure:
- Header with source story link
- Persona and preconditions
- Steps (4-8 typical): narrative + clickable screenshot
- Alternates/errors (if applicable)

Image embed format:
```markdown
[![alt](../images/file.png)](scheme://screen/Route?variant=name)
```

## Index

Location: `design/generated/scenarios/index.md`

Purpose: Linear path for stakeholders to review app end-to-end.

## Preview/Publish

- Preview: `appeus/scripts/preview-scenarios.sh --port 8080`
- Publish: `appeus/scripts/publish-scenarios.sh --dest user@host:/path`
