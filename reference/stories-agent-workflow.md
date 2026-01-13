# Stories Agent Workflow

How to process user stories and derive screens/navigation.

This doc is intentionally focused on story processing only. For the overall per-slice loop, see [Workflow](workflow.md).

## Paths

| Content | Canonical Path (v2.1) |
|---------|------------------------|
| Stories | `design/stories/<target>/*.md` |
| Screen specs | `design/specs/<target>/screens/*.md` |
| Consolidations | `design/generated/<target>/screens/*.md` |

## Workflow

### 1. Read Story

Parse the story for:
- Goal (As a user, I want...)
- Sequence (numbered steps)
- Acceptance criteria
- Edge cases and variants

### 2. Check Existing Specs

Look for related specs and consolidations:
- Screen specs in `design/specs/<target>/screens/`
- Navigation spec
- Domain contract (for data requirements), when needed

### 3. Identify Implications

Determine what the story implies:
- New screens needed
- Navigation changes
- Data requirements (domain contract), when needed

### 4. Update Consolidations

If story affects multiple screens or adds to existing screens:
- Create/refresh consolidations in `design/generated/<target>/screens/`
- Include dependency metadata (dependsOn, depHashes)

### 5. Suggest Scenarios

Propose scenarios and variants for testing:
- happy: Normal flow
- empty: Empty states
- error: Error conditions

### 6. Generate Code (On Request)

When user requests code generation:
- Refresh consolidations if stale
- Generate screen code
- Update navigation
- Create mock data

## Cross-Target Considerations

When multiple targets exist:
- Check `design/specs/project.md` for target/platform expectations
- A story in one target may imply shared domain contract updates in `design/specs/domain/`

## See Also

- [Story Template](../templates/stories/story-template.md)
- [Generation Workflow](generation.md)
- [Spec Schema](spec-schema.md)
