# Stories Human User Guide

Stories are the human-authored narrative of **what happens**. They are the foundation the agent uses to propose screens, navigation, the domain contract (as needed), and slice-by-slice code generation.

## Location

`design/stories/<target>/*.md`

## How to write a good story

A good story is:
- **User-goal focused** (“what happens”), not UI implementation (“how it’s built”)
- **Specific and testable** (acceptance criteria)
- **Complete enough to infer navigation** (what screens exist and how the user moves)
- Explicit about **inputs/outputs** (what the user provides, what they receive)
- Clear about **edge cases** (empty/error paths that matter)

If you have multiple targets (mobile/web/etc.), write stories per target. Shared data behavior belongs in the domain contract under `design/specs/domain/`.

## Suggested structure (copy/paste)

```markdown
# User Story: <Title>

## Story Overview
As a <user type>
I want to <goal>
So that <benefit>

Context: <optional prerequisites, user state, important constraints>

## Sequence
Write numbered steps focusing on **WHAT happens** (user goals + outcomes), not UI HOW.

1. <User accomplishes first goal or takes first action>
2. <What happens as a result — from the user’s perspective>
3. <Next goal/decision point>
   - If <condition>, <alternate path>
4. <Goal achieved or story continues to next story>

## Acceptance Criteria
- [ ] <specific, testable criterion>
- [ ] <another criterion>
- [ ] <empty/error handling requirement (if applicable)>

## Variants
- happy: Normal flow
- empty: Empty state
- error: Error handling
```

This structure matches the story template at `appeus/templates/stories/story-template.md`.

## Tips (what vs how)

- Focus on **what**, not UI specifics
- Number stories for reading order (01-browsing.md)
- Include edge cases and error scenarios

## How to use the agent after writing stories

1. **Pick the target** you want to work on (`<target>`).
2. Ask the agent to **infer/refine navigation and screens** from stories:
   - `design/specs/<target>/navigation.md`
   - `design/specs/<target>/screens/index.md`
3. Review and refine the target specs in `design/specs/<target>/` (human lane).
4. Ask the agent to generate the next slice:
   - it should refresh the consolidation under `design/generated/<target>/screens/<Route>.md`
   - then generate/update app code under `apps/<target>/`
5. Iterate: update stories/specs, then regenerate the affected slice(s).

For how target specs are organized, see `appeus/user-guides/target-spec.md`. For the overall workflow and phases, see `appeus/docs/DESIGN.md`.

## Multiple Targets

For projects with multiple targets:
- Write separate stories per target
- The agent should consult relevant stories when deriving the shared domain contract (as needed)
- Shared domain contract goes in `design/specs/domain/`
