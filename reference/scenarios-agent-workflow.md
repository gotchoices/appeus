# Scenarios Agent Workflow (Appeus)

## When to Generate
- After screen/navigation are stable for the feature
- After mock data variants are defined
- When preparing for stakeholder review

## Prerequisites
- Screens generated and working
- Deep linking configured in app
- Mock data variants in place
- Android emulator running (or iOS simulator)

## Workflow

### 1. Configure Screenshots

Edit `design/generated/images/index.md` frontmatter with project appId, scheme, and screenshot entries:

```yaml
---
appId: org.example.myapp
scheme: myapp

screenshots:
  - route: Home
    variant: happy
    file: home-happy.png
    deps:
      - src/screens/Home.tsx
  - route: Settings
    params:
      tab: privacy
    file: settings-privacy.png
---
```

### 2. Capture Screenshots

Run the capture script:

```bash
appeus/scripts/build-images.sh --reuse --window
```

The script:
- Reads config from `images/index.md`
- Builds deep links from route/variant/params
- Captures PNGs via `android-screenshot.sh`
- Skips fresh images (use `--force` to recapture all)

### 3. Write Scenario Docs

For each story, create `design/generated/scenarios/<story-id>.md`:

- Link source story at top
- Define persona and preconditions
- Write 4-8 steps: narrative + embedded screenshot
- Add alternates/errors if applicable

Example step:
```markdown
Bob opens the app and sees his recent log entries.

[![log-history](../images/log-history-happy.png)](myapp://screen/LogHistory?variant=happy)
```

### 4. Update Scenario Index

Maintain `design/generated/scenarios/index.md`:
- Logical review order
- Links to each scenario doc

## Output Artifacts

- `design/generated/images/*.png`
- `design/generated/images/index.md`
- `design/generated/scenarios/*.md`
- `design/generated/scenarios/index.md`
