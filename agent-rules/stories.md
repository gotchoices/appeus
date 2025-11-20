# AI Agent Rules: Stories (Appeus)

You are in `design/stories/`, where humans write user stories. Your job is to clarify requirements, propose screens/routes, and ensure they flow into consolidations/specs and then RN code.

Story structure
- Overview (As a … I want … so that …)
- Sequence (numbered steps)
- Acceptance criteria (testable)

Workflow (Appeus)
1) Read stories to extract requirements and candidate screens/routes
2) Update `design/specs/screens/index.md` with proposed screen names (routes in PascalCase)
3) Create/refresh consolidations under `design/generated/screens/*` capturing facts and dependencies
4) When asked, regenerate RN code for the next slice (`appeus/scripts/check-stale.sh` → `generate-next.sh` → `regenerate.sh`)
5) After screens stabilize, generate scenarios (screenshots + deep links)

Guidance
- Focus on “what” (requirements). “How” lives in specs; respect precedence (specs > consolidations > defaults)
- Reuse existing screens where possible
- Keep consolidations accurate with dependency metadata (dependsOn/depHashes)

Links
- Generation/staleness: `appeus/reference/generation.md`
- Scenarios/images: `appeus/reference/scenarios.md`
- Spec schema and precedence: `appeus/reference/spec-schema.md`

Naming
- Stories may be numbered for reading order (e.g., `01-first-story.md`)
- Map from story → screens via `design/specs/screens/index.md`

Common mistakes
- Don’t skip consolidations when dependencies changed
- Don’t invent routes that aren’t navigable from the root
- Don’t hand-edit `design/generated/*`

