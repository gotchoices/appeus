# Scenarios and Screenshots

Scenarios are storyboards for review: each step embeds a screenshot that links to the deep link that produced it. The screenshot is evidence; the link is the review. Locally the preview server makes those links open the running app; published pages keep them raw. Variant semantics: [Mock Variants](mock-variants.md).

## Paths

| Content | Canonical Path |
|---------|----------------|
| State registry | `design/generated/<target>/images/index.md` |
| Screenshots | `design/generated/<target>/images/*.png` |
| Scenario docs | `design/generated/<target>/scenarios/*.md` (+ `index.md`) |
| Published site | `design/generated/<target>/site/` |

## State Registry

`images/index.md` frontmatter is the one list of reviewable **states** — (route, params, variant) — for the target. Every script and page reads it through `scripts/lib/scenarios.js`, which also owns the deep-link formula.

```yaml
---
appId: com.example.myapp          # Android package / iOS bundle id
scheme: myapp                     # deep-link scheme
screenshots:
  - route: ItemList               # route; may carry path segments: ItemDetail/item%3A42
    variant: happy                # fixture variant (optional)
    locale: en                    # optional; omitted from the link when "en"
    params: { category: books }   # extra query params (optional)
    file: item-list-happy.png     # output image
    deps:                         # files whose change makes the image stale (optional)
      - apps/mobile/src/screens/ItemList.tsx
      - mock/data/items.happy.json
  - route: ItemDetail
    params: { id: "item:new" }
    capture: false                # a state worth opening, not worth a committed PNG
    note: a new item — zero history, explained
---
```

Link formula: `{scheme}://screen/{route}[?variant=…][&locale=…][&k=v…]`; values are percent-encoded unless already encoded. An entry's `id` defaults to the file's stem (or `route-variant-params` for `capture: false`).

Variants name fixtures (`mock/data/<namespace>.<variant>.json`). A scene reached through different params — another item, an empty account — is a registry entry, not a variant.

## Opening a State

```bash
appeus/scripts/open-deeplink.sh [--target <t>] --route ItemList --variant empty [--params k=v]...
appeus/scripts/open-deeplink.sh --id item-list-empty | --file item-list-empty.png | --link "myapp://screen/…"
appeus/scripts/open-deeplink.sh --list          # connected devices: kind, id, label
```

Launches via `adb` (Android) or `xcrun simctl openurl` (booted iOS simulator). With one device connected it is used; with several, name one with `--device <id>` or `APPEUS_DEVICE` (exit 3 otherwise). `--dry-run` prints the command. Use it after generating a slice to show it, and to verify a link before capturing.

## Capturing Screenshots

```bash
appeus/scripts/build-images.sh [--target <t>] [--reuse] [--window] [--force] [--dry-run]
```

Captures every registry entry (skipping `capture: false`) whose image is missing, older than a `deps` file, or older than the screen's source. `--dry-run` lists what would be captured and why. Android only; each capture goes through `android-screenshot.sh`, which starts an emulator when none is running (`APPEUS_ANDROID_AVD`), opens the link via `open-deeplink.sh`, waits `APPEUS_SCREEN_DELAY` seconds (default 8 — a cold React Native release build can take 10–20 s to first paint; warm the app first), and captures.

iOS: open the state with `open-deeplink.sh`, then `xcrun simctl io booted screenshot <file>`.

## Scenario Documents

`design/generated/<target>/scenarios/<story-id>.md`, one per story, citing its source:

```markdown
# Scenario: Browsing Items

Source: [01-browsing.md](../../stories/mobile/01-browsing.md)

## Step 1: View Item List
User opens the app and sees a list of items.

[![Item list](../images/item-list-happy.png)](myapp://screen/ItemList?variant=happy)

## Step 2: Empty State
![Empty list](../images/item-list-empty.png)

## Alternates
A new item: [open it](myapp://screen/ItemDetail?id=item%3Anew)
```

Two image forms are equivalent: the explicit `[![alt](../images/f.png)](deep link)`, and the bare `![alt](../images/f.png)`, which the renderer links to the registry entry owning `f.png`. Prefer the bare form — it cannot drift. When an explicit link disagrees with the registry, or names an image not in it, `publish-scenarios.sh` prints a note.

One link opens one state. A multi-step flow is several links; a scenario does not replay taps.

`scenarios/index.md` lists the docs in review order.

## Preview

```bash
appeus/scripts/preview-scenarios.sh [--target <t>] [--device <id>] [--port 8080] [--host 127.0.0.1] [--no-open] [--verbose]
```

Renders the docs live (registry re-read per request) and adds `/states` — every registry entry, thumbnail if captured. Clicking a `<scheme>://` link opens that state on the server's device; the server calls `open-deeplink.sh`. The device is fixed when the server starts — `--device`, else `APPEUS_DEVICE`, else the only connected one — and shown in the page header; the page only says which state. Run one server per project when several emulators are up, giving each its own `--port` (or `APPEUS_PORT`).

The server logs every link it opens — the link, the device, and whether the launch succeeded — so a click that does nothing can be diagnosed from its stdout rather than the toast. `--verbose` (or `APPEUS_VERBOSE=1`) adds every request and the exact `open-deeplink.sh` command. `--host 0.0.0.0` also serves the LAN: on a phone's browser the page does not intercept clicks, so a phone with the app installed resolves the link itself.

## Publish

```bash
appeus/scripts/publish-scenarios.sh [--target <t>] [--dest user@host:/path] [--dry-run]
```

Writes `site/` — `scenarios/*.html`, `states.html`, `images/`, `index.html` — rendered with the same template as the preview, then rsyncs it when `--dest` (or `APPEUS_PUBLISH_DEST`) is given. Deep links stay raw: inert on a desktop browser, live on a phone that has the app.

## Fixture Check

```bash
appeus/scripts/check-variants.sh [--target <t>] [--summary]
```

Reports every spec-declared variant with no fixture behind it (the screen would render the default fixture and look correct), every fixture-backed variant with no registry entry (not reviewable), and routes whose fixture namespaces are unknown. Namespaces come from the consolidation's `mocks:` frontmatter, else from `mock/data/*` paths in the entry's `deps`. `check-stale.sh` prints the summary line.
