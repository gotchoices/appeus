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
  design/specs/<target>/screens/item-list.md: "sha256:abc123..."
  design/specs/domain/schema.md: "sha256:def456..."
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
        "design/specs/<target>/screens/item-list.md": "sha256:..."
      }
    }
  ]
}
```

## Staleness Detection

### Hash-based (preferred)

1. Compute sha256 for each file in `dependsOn`
2. Compare to saved `depHashes`
3. Any mismatch ⇒ stale

### Fallback (mtime-based)

When metadata is missing or clearly broken, compare file modification times:
- Inputs: stories, specs, navigation, domain contract (as needed)
- Outputs: consolidations, app code
- Stale if any input mtime > output mtime

## Slice Selection (best practice)

### Navigation graph

Build from `design/specs/<target>/navigation.md` plus `design/specs/<target>/screens/index.md`.

### Selection order

1. First stale screen reachable from the app’s entry/root
2. Stale neighbors (navigable from fresh screens)
3. Remaining stale screens

## Scripts

- `check-stale.sh` — Summarize which routes are stale for a target (and why)
- `update-dep-hashes.sh` — Recompute `depHashes` for a target/route using the declared `dependsOn`

## See Also

- [Workflow](workflow.md)
- [Generation](generation.md)
- [Codegen](codegen.md)


