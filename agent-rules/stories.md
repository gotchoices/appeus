# Agent Rules: Stories

You are in `design/stories/`. User stories define requirements.

## Paths

- Single-app: `design/stories/*.md`
- Multi-app: `design/stories/<target>/*.md`

## Story Structure

```markdown
# Story Title

## Goal
As a <user>, I want <action> so that <benefit>.

## Sequence
1. User does X
2. System responds with Y
3. User sees Z

## Acceptance
- Criterion 1
- Criterion 2

## Variants
- happy: Normal flow
- empty: Empty state
- error: Error condition
```

## Workflow

1. Read story for requirements
2. Identify screens and navigation
3. Update `design/specs/screens/index.md` with proposed screens
4. Create/refresh consolidations in `design/generated/screens/`
5. On request, generate code via `check-stale.sh` → `generate-next.sh`

Reference: [stories-agent-workflow.md](../reference/stories-agent-workflow.md)

## Do

- Focus on "what" (requirements)
- Reuse existing screens where possible
- Keep consolidations accurate with metadata

## Don't

- Don't skip consolidations when dependencies change
- Don't invent unreachable routes
- Don't hand-edit `design/generated/*`

## Naming

- Stories: numbered for order (`01-browsing.md`)
- Map story → screens via `design/specs/screens/index.md`

## Multi-App

For projects with multiple targets:
- Stories in `design/stories/<target>/`
- Schema derived from ALL target stories
- Shared data model in `design/specs/schema/`

## References

- [Story Template](../templates/stories/story-template.md)
- [Generation](../reference/generation.md)
- [Spec Schema](../reference/spec-schema.md)
