# Staleness and Dependencies

How Appeus decides what is stale (per target + per route), and how dependency metadata is stored and repaired.

This is a tactical reference. For the overall per-slice loop, see [Workflow](workflow.md). For code output details, see [Codegen](codegen.md).

## Canonical Paths

- Consolidations: `design/generated/<target>/screens/<Route>.md`
- Dependency registry: `design/generated/<target>/meta/outputs.json`

## Dependency Metadata (frontmatter)

Consolidations should declare what they depended on while being written:

```yaml
---
provides: ["screen:ItemList"]
dependsOn:
  - design/stories/<target>/01-browsing.md
  - design/specs/<target>/screens/item-list.md
  - design/specs/<target>/navigation.md
  - design/specs/domain/schema.md
depHashes:
  design/specs/<target>/screens/item-list.md: "abc123..."   # bare sha256 hex
  design/specs/domain/schema.md: "def456..."
---
```

The agent is expected to keep `dependsOn` “accurate enough” for deterministic staleness. Scripts can seed conservative defaults, but they can’t infer intent.

## Dependency Registry (`outputs.json`)

Per target, `design/generated/<target>/meta/outputs.json` tracks outputs and their declared inputs:

```json
{
  "outputs": [
    {
      "route": "ItemList",
      "output": "apps/mobile/src/screens/ItemList.tsx",
      "dependsOn": [
        "design/generated/<target>/screens/ItemList.md",
        "design/specs/<target>/screens/item-list.md",
        "design/specs/<target>/navigation.md"
      ],
      "depHashes": {
        "design/specs/<target>/screens/item-list.md": "e3b0c44298fc1c14..."
      }
    }
  ]
}
```

## Staleness Detection

A route with no generated output is always stale (`missing output`). Otherwise `check-stale.sh`
picks one of two methods per route and reports which one it used in the `how` column.

### Hash-based (preferred, used whenever `depHashes` exists)

1. Compute sha256 for each file in `dependsOn`
2. Compare to the saved `depHashes` entry (a bare hex digest; a `sha256:` prefix is also accepted)
3. Any mismatch ⇒ stale (`changed: <file>`)
4. A `dependsOn` file that has a recorded hash but no longer exists ⇒ stale (`dependency removed: <file>`)
5. A `dependsOn` file with no recorded hash ⇒ stale (`no recorded hash: <file>`) — record with `update-dep-hashes.sh`

Requires `jq` plus `shasum` or `sha256sum`.

### Fallback (mtime-based)

Used only when no `depHashes` are recorded for the route (or the tools above are missing):
- Inputs: stories, specs, navigation, domain contract (as needed)
- Outputs: consolidations, app code
- Stale if any input mtime **>=** any output mtime (equality counts as stale: `stat` has one-second
  resolution, so an edit in the same second as generation is otherwise invisible)

mtimes are unreliable — git rewrites them on clone, checkout, and stash — so after any of those
operations mtime results are noise. Run `update-dep-hashes.sh --all` once per generated slice so
routes use the hash path instead.

## Slice Selection (best practice)

### Navigation graph

Build from `design/specs/<target>/navigation.md` plus `design/specs/<target>/screens/index.md`.

### Selection order

1. First stale screen reachable from the app’s entry/root
2. Stale neighbors (navigable from fresh screens)
3. Remaining stale screens

## Scripts

Use `appeus/scripts/check-stale.sh` to summarize which routes are stale for a target (and why), and `appeus/scripts/update-dep-hashes.sh` to recompute `depHashes` for a target/route using the declared `dependsOn`.


