# User Guide: Stories

Stories define user requirements. The agent derives screens and specs from your stories.

## Location

`design/stories/<target>/*.md`

## Structure

```markdown
# User Story: <Title>

## Story Overview
As a <user type>
I want to <goal>
So that <benefit>

## Sequence
1. User does X
2. System responds with Y
3. User sees Z

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Variants
- happy: Normal flow
- empty: Empty state
- error: Error handling
```

## Tips

- Focus on **what**, not UI specifics
- Number stories for reading order (01-browsing.md)
- Include edge cases and error scenarios

## After Writing

1. Ask agent to derive consolidations
2. Review proposed screens in `design/specs/screens/index.md`
3. Refine specs as needed
4. Request code generation when ready

## Multiple Targets

For projects with multiple targets:
- Write separate stories per target
- Agent reads ALL stories when deriving the shared domain contract (as needed)
- Shared domain contract goes in `design/specs/domain/`
