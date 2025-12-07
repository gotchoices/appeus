# Stories Agent Workflow

How to process user stories and derive screens/navigation.

## Paths

| Content | Single-App | Multi-App |
|---------|------------|-----------|
| Stories | `design/stories/*.md` | `design/stories/<target>/*.md` |
| Screen specs | `design/specs/screens/*.md` | `design/specs/<target>/screens/*.md` |
| Consolidations | `design/generated/screens/*.md` | `design/generated/<target>/screens/*.md` |

## Workflow

### 1. Read Story

Parse the story for:
- Goal (As a user, I want...)
- Sequence (numbered steps)
- Acceptance criteria
- Edge cases and variants

### 2. Check Existing Specs

Look for related specs and consolidations:
- Screen specs in `design/specs/screens/` or `design/specs/<target>/screens/`
- Navigation spec
- Schema specs (for data requirements)

### 3. Identify Implications

Determine what the story implies:
- New screens needed
- Navigation changes
- Data requirements (schema)
- API endpoints needed

### 4. Update Consolidations

If story affects multiple screens or adds to existing screens:
- Create/refresh consolidations in `design/generated/screens/`
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

## Multi-Target Considerations

For projects with multiple apps:
- Check `design/specs/project.md` for target information
- Stories in one target may imply schema changes affecting all targets
- Derive shared schema by reading stories from ALL targets

## See Also

- [Story Template](../templates/stories/story-template.md)
- [Generation Workflow](generation.md)
- [Spec Schema](spec-schema.md)
