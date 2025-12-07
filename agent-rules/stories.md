# Agent Rules: Stories

You are in `design/stories/`. User stories define requirements.

## Paths

- Single-app: `stories/*.md`
- Multi-app: `stories/<target>/*.md`

## Story Structure

```markdown
# Story Title

## Goal
As a <user>, I want <action> so that <benefit>.

## Sequence
1. User does X
2. System responds with Y

## Acceptance
- Criterion 1
- Criterion 2

## Variants
- happy, empty, error
```

## Workflow

1. Read story for requirements
2. Identify screens, update `specs/screens/index.md`
3. Create consolidations in `generated/screens/`
4. On request, generate code

## Naming

Stories: numbered for order (`01-browsing.md`)

## Reference

- [Stories Workflow](appeus/reference/stories-agent-workflow.md)
