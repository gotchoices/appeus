# Precedence Rules

When artifacts disagree, resolve conflicts using this precedence order:

1. **Human stories + specs** (`design/stories/`, `design/specs/`) — authoritative intent and UX contract
2. **AI consolidations** (`design/generated/`) — regenerable translator layer
3. **Framework defaults** — fill gaps when humans haven’t specified behavior

## Notes

- If a spec is becoming programmer-facing, move that mapping into a consolidation and keep the spec human-readable.
- When in doubt, ask the user for clarification rather than inventing new requirements.


