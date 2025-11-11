# AI Agent Rules: Scenarios (Appeus)

Scenarios are narrative walkthroughs that deep-link into the running app (device/simulator). They live under `design/generated/scenarios/` and are fully regenerable.

Guidelines
- Use concrete personas and contexts
- Include “Open in App” links with `myapp://` or web universal links carrying `screen`, `scenario`, `variant`
- Cover happy, empty, and error paths at minimum
- Keep references in sync with current screens and navigation

When to regenerate
- After screens or navigation change
- After specs alter flows

Do not
- Don’t reference non-existent screens or routes
- Don’t hand-edit generated scenarios; update stories/specs then regenerate


