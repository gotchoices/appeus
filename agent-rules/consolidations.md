# Agent Rules: Consolidations

You are in `design/generated/`. AI-generated content lives here.

## Purpose

Consolidations are the **translator layer**: gather facts from stories/specs into a programmer-facing digest (implementation mapping) with dependency metadata. They are **regenerable** — human specs take precedence.

## Canonical paths

- Screen consolidations: `design/generated/<target>/screens/<Route>.md`
- Dependency registry: `design/generated/<target>/meta/outputs.json`

## Precedence (inputs)

When writing/updating a consolidation, honor this order:

1. **Human specs** (authoritative): `design/specs/<target>/…` and, when needed, `design/specs/domain/*.md`
2. **Human stories** (authoritative intent): `design/stories/<target>/…`
3. **Existing consolidation** (regenerable state): keep good mapping, but re-derive anything that conflicts with updated specs/stories
4. **Defaults/inference**: only to fill gaps; align with `design/specs/project.md` posture

If sources disagree, do not “pick a winner” silently—record the conflict and ask the human (precedence: `appeus/reference/precedence.md`).

## Metadata

Consolidations must carry dependency metadata so staleness is deterministic (model: `appeus/reference/staleness.md`).

Include dependency tracking in each consolidation frontmatter:

```yaml
---
dependsOn:
  - design/stories/<target>/01-browsing.md
  - design/specs/project.md
  - design/specs/<target>/screens/item-list.md
  - design/specs/<target>/navigation.md
  - design/specs/domain/<file>.md
depHashes:
  design/stories/<target>/01-browsing.md: "sha256:..."
  design/specs/<target>/screens/item-list.md: "sha256:..."
---
```

Scripts can seed/repair `design/generated/<target>/meta/outputs.json`, but you should ensure the `dependsOn` list reflects what you actually used.

## What a consolidation must contain (digest)

Consolidations are where programmer-facing structure belongs, for example:

- **Route + screen/component inventory** needed for the slice
- **UI states** implied by stories/specs (happy/empty/error/loading), with notes on which states are driven by mock variants
- **Data interactions** expressed as domain needs (entities/ops/rules), plus adapter responsibilities
- **Navigation wiring** implications (what links to what, params, deep link expectations)
- **Implementation mapping** appropriate to the framework target (file placement, component breakdown, key events)

Keep this digest aligned with the project posture in `design/specs/project.md` (prototype vs production).

## Workflow (critical)

Before generating code, ensure the consolidation is fresh:

1. Identify the target + route slice.
2. Read authoritative inputs in precedence order (specs → stories → domain → existing consolidation).
3. Write/update `design/generated/<target>/screens/<Route>.md` with the digest + dependency metadata.
4. Generate code only after the consolidation reflects current intent (methodology: `appeus/reference/generation.md` and `appeus/reference/codegen.md`).

## Don’t

- Don’t overwrite or “upgrade” human specs/stories.
- Don’t embed source metadata in app code; use JSON registries and consolidation frontmatter instead.
- Don’t hand-edit generated artifacts—regenerate instead.

