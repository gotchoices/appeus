# Agent Rules: Design Root

You are in the design surface. Stories, specs, and consolidations live here.

## Structure

| Folder | Purpose | Editable? |
|--------|---------|-----------|
| `stories/` | User stories | Human |
| `specs/` | Authoritative specs | Human |
| `generated/` | AI consolidations, scenarios | AI only |

## Paths

**Single-app:**
- Stories: `design/stories/*.md`
- Specs: `design/specs/screens/*.md`, `design/specs/navigation.md`
- Consolidations: `design/generated/screens/*.md`

**Multi-app:**
- Stories: `design/stories/<target>/*.md`
- Specs: `design/specs/<target>/screens/*.md`
- Shared: `design/specs/schema/*.md`, `design/specs/api/*.md`

## Workflows

### Code Generation

1. Human writes stories in `stories/`
2. You derive consolidations in `generated/` (with dependency metadata)
3. Human writes/edits specs in `specs/`
4. On request, generate app code in `apps/<name>/src/`
5. Validate via scenarios, iterate

### Vertical Slicing

Use scripts to process one screen at a time:

```bash
appeus/scripts/check-stale.sh      # What's stale?
appeus/scripts/generate-next.sh    # Pick next slice
```

For each slice: consolidate → api → mocks → code → scenarios.

Reference: [generation.md](../reference/generation.md)

## Precedence

Human specs > AI consolidations > defaults

**Important:** Consolidate first. If dependencies are stale, refresh consolidation before generating code.

## User Commands

When the user says... do this:

| User Says | Action |
|-----------|--------|
| "generate" / "generate code" / "next slice" | Run `generate-next.sh`, then generate that screen's code |
| "generate [ScreenName]" | Run `regenerate.sh --screen <Route>`, then generate code |
| "generate scenarios" | Write scenario docs in `generated/scenarios/`, configure and run `build-images.sh` |
| "generate images" / "capture screenshots" | Run `build-images.sh` (configure `images/index.md` first) |
| "what's next" / "what do I need to do" | Run `check-stale.sh`, summarize status, suggest next action |
| "check staleness" / "what's stale" | Run `check-stale.sh`, report results |
| "preview scenarios" | Run `preview-scenarios.sh`, tell user the URL |
| "publish scenarios" | Run `publish-scenarios.sh` |

For multi-app projects, add `--target <name>` to all scripts.

## Scripts

| Script | Purpose |
|--------|---------|
| `check-stale.sh` | Per-screen staleness report |
| `generate-next.sh` | Pick next vertical slice |
| `regenerate.sh --screen <Route>` | Target specific screen |
| `update-dep-hashes.sh --route <Route>` | Refresh dependency hashes |
| `build-images.sh` | Capture screenshots from running app |
| `preview-scenarios.sh` | Local scenario preview server |
| `publish-scenarios.sh` | Package and publish HTML |

## Naming

- Spec filenames: kebab-case (`item-list.md`)
- Routes/components: PascalCase (`ItemList`)
- Mapping in `design/specs/screens/index.md`

## Do

- Read stories and specs before proposing changes
- Keep consolidations in `generated/` with full metadata
- Propose code updates only when user asks

## Don't

- Don't edit app code without regenerate request
- Don't prioritize consolidations over human specs
- Don't hand-edit `generated/*`

## References

- [Workflow](../reference/workflow.md)
- [Generation](../reference/generation.md)
- [Spec Schema](../reference/spec-schema.md)
- [Mock Variants](../reference/mock-variants.md)
- [Testing](../reference/testing.md)
