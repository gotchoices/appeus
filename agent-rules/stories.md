# Agent Rules: Stories

You are in `design/stories/`. Stories are the human-authored narrative of **what happens**.

## Canonical paths

- Stories live per target: `design/stories/<target>/*.md`

## What belongs in stories

- User narrative and acceptance criteria (user-observable outcomes)
- Edge cases and alternates that affect UX

Avoid UI implementation detail and programmer mapping; that belongs in specs and consolidations (artifact lanes: `appeus/reference/generation.md`).

## What to do next (index)

- If the target is unclear, ask which `--target <target>` is being worked on.
- If the story implies a new screen/route, ensure `design/specs/<target>/screens/index.md` and `design/specs/<target>/navigation.md` are updated (format: `appeus/reference/spec-schema.md`).
- If the story implies shared domain behavior, capture it in `design/specs/domain/*.md` (workflow: `appeus/reference/domain-agent-workflow.md`).
- For the full story-to-generation lane method, see `appeus/reference/stories-agent-workflow.md`.

## Naming

Stories: numbered for order (`01-browsing.md`)
