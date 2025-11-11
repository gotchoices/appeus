# STATUS

This document tracks the vision, options, and plan for Appeus—a design-to-app workflow that converts user stories into a running React Native app with live navigation and mockable data. It consolidates our current answers and outlines multiple viable paths, tools, and next steps.

## Vision
Design and execution happen on the same surface. Stories expand into scenarios which immediately render as live React Native screens (device or simulator). Deep links from web scenario pages open the app into the exact screen and variant under review. An optional in-app overlay guides walkthroughs and captures feedback. When design is done, the app is materially done.

## Feasibility
Feasible using today’s tools. Chosen approach: codegen of React Native screens and navigation from stories/scenarios/specs (idiomatic source, full flexibility). Deep links, in-app overlay, and mock data variants are supported.

## Relationship to existing appgen/chat
- `appgen/` provides content-first design flow: stories → scenarios → screens/specs with transforms and scripts.
- `chat/app/design/` is a concrete instance: authored stories/scenarios, XML screens, specs, and generated HTML/SVG previews.
- Appeus extends this by making the “rendered” asset a live RN app, not static images/pages.
- As we build out appeus, use appgen as a reference.  It is working well in many respects (going from stories to renderings).  The main differences are:
  - We want to go direct to react-native
  - We want a way to review scenarios somehow integrated with the running prototype app
- Don't re-invent the wheel.  If something is working right in appgen, adopt it.  If it needs to be adapted for our new approach, adapt it.  Ask the user if you're not sure.

## Current Decisions
- Mock layer: Use a tiny Express server that serves local JSON files. Variant selection via `?variant=` query param or `X-Mock-Variant` header. For example there might be multiple sets of mock files for a single screen (to test different conditions).
- Minimal/no validation during design.
- For team access, we will consider:
  - Pushing json files to a public server
  - Establishing an ssh tunnel to a public IP that will server local files
- Rendering strategy: Code generation of RN screens + navigation from stories scenarios, specs.
- Generation priority (appgen-style): Human specs > AI consolidation > inferred assumptions.
- Generation governance (simplified): AI may generate app code; generation runs only when requested/triggered/authorized by the human; Appeus supplies scripts that detect stale outputs by comparing spec modification times to generated artifacts and prompt regeneration.
- Encourage regular git commit discipline for reversibility, recovery
- Humans provide input via Markdown specs
- Toolkit: Appeus-only (no further appgen dependency). Port/replicate any needed scripts, rules, and resources under `appeus/`.

## Rendering Strategy
### Code generation of RN screens (design-to-source)
- Stories → scenarios → generated `.tsx` screens + navigation registry; scenario variants pre-wired into data providers.
- Pros: idiomatic source, maximal flexibility and performance; easier to hand-tune per screen.
- Cons: need robust idempotent generators; merge strategy for manual edits.
Note: A runtime schema-rendered approach exists conceptually but is out of scope for Appeus.

## Core Workflow
1) Author stories with scenarios and named variants (happy/empty/error).
2) Build artifacts:
   - Generate scenario pages (web) with “Open in App” deep links carrying `screen`, `scenario`, and `variant`.
   - Generate consolidations (how one would build screens, navigation, components) based on stories.
   - Consider any human-generated specs (prioritize over consolidations)
   - Generate `.tsx` screens and navigation entries.
3) Run the app:
   - Linking config parses deep links and navigates to the target screen.
   - A global ScenarioRunner applies the scenario/variant, selecting mock data and toggling UI state.
   - Optional overlay guides steps and records notes.
4) Iterate:
   - Edit stories/specs → regenerate code → hot reload.
   - Feedback from overlay feeds back into stories/specs.
5) Transition to production:
   - Swap mocks for real endpoints/model; keep shapes consistent to minimize churn.
   - Tighten types, tests, and remove unused variants.

## Deep Linking and Overlay
- Use app links/universal links or `myapp://` custom scheme via Expo Linking.
- Scenario pages include buttons that trigger deep links with variant parameters.
- In-app overlay (coachmarks or modal) provides: step-by-step guidance, variant switcher, and a quick feedback capture.

## Mock Data Strategy and Variants
- Chosen approach: tiny Express server serving local JSON files (read/write). Keep it simple; validation deferred until real backend.
- Variant mechanics: select via `?variant=happy|empty|error` or `X-Mock-Variant` header; keys/namespaces include `project/scenario/variant` to avoid collisions.
- Access modes:
  - Local-only during design; RN simulator/device hits your laptop via LAN or a tunnel (Cloudflare Tunnel/ngrok/ssh -R).
  - Optional hosted variant later (same API) for team-wide stable access.
- Alternative options (if needs grow): `json-server` with middleware, Postman Mock Server, or OpenAPI-led Prism. These remain optional and are not required for Appeus’ baseline.
- Pass the variant from the deep link/overlay into engine state so the API client attaches the variant param/header on requests.

## Screen Generation Model (appgen-style)
Inputs for each screen are combined in a strict priority:
1) Human-generated screen spec (authoritative overrides)
2) AI-generated consolidation (facts derived from stories/scenarios/specs)
3) Inferred assumptions (fallback defaults)

Notes (aligning with AppGen):
- Specs are free-form Markdown; frontmatter and code blocks are optional. The generator will parse what it can; if nothing is present, it relies on consolidation and sensible defaults.
- No spec is acceptable if the AI can build the screen entirely from story consolidation; add a spec later only when needed.
- For screens referenced by multiple stories, create/maintain a consolidation file first, mirroring AppGen’s multi-story consolidation guidance.

Typical file layout (optional, not strictly enforced):
- Human specs (per-screen): `design/specs/screens/<screen-id>.md` (Markdown; may include code blocks/slots)
- Navigation specs (human-authored): `design/specs/navigation.md`
- Global specs (project-wide): `design/specs/global/*` (toolchain, UI, dependencies, etc.)
- AI consolidation (screens): `design/generated/screens/<screen-id>.md` (or `.json`)
- AI consolidation (navigation): `design/generated/navigation.md`
- Generated RN screens: files under `src/screens/` (only updated on human-triggered generation)
- Navigation (generated): files under `src/navigation/`

Generation flow:
- The generator merges: human spec → AI consolidation → sensible defaults.
- On human request, it writes/updates screens in `src/screens/` and navigation in `src/navigation/`.
- Artifacts under `design/generated/*` are fully regenerable and not intended for hand edits.

Human spec (minimal structure suggestion):
- Frontmatter: `id`, `title`, `route`, `variants`, `dataRequirements`, `actions`, `layoutHints`, `validation`, `acceptance`
- Body: clarifications, wire references, notes; anything not in frontmatter is advisory for the generator.

## Generation Governance (simplified process)
- Human-triggered generation only: No automatic overwrites; the AI/CLI runs generation when explicitly requested.
- Full AI generation allowed: Any part of the app can be generated; human spec inputs drive the outcome.
- Git discipline: Commit frequently before generation; revert via git if an output is undesirable.
- Stale detection via scripts: Appeus provides scripts that compare spec/consolidation modification times against generated outputs and list what is stale.
- Reminders, not enforcement: Scripts and docs guide the process; humans decide when to regenerate.

## Global Project Specs
Purpose: capture app-wide choices (icon set, JS vs TS, dependencies, Expo usage, etc.). When absent, Appeus infers sensible defaults; humans can add/adjust specs later and regenerate.

Suggested files (free-form Markdown; frontmatter optional):
- `design/specs/global/toolchain.md`
  - language: `ts` | `js`
  - runtime: `expo` | `bare-rn`
  - packageManager: `yarn` | `npm` | `pnpm`
  - navigation: `react-navigation` | `expo-router`
  - state: `zustand` | `redux` | `recoil` | `jotai`
  - http: `fetch` | `axios`
- `design/specs/global/ui.md`
  - iconSet: `ionicons` | `material-community` | `feather` (via `@expo/vector-icons`)
  - uiKit: `none` | `react-native-paper` | `tamagui` | `native-base`
  - theme: `system` | `light` | `dark`
  - componentMapping: notes for semantic→RN component conventions
- `design/specs/global/dependencies.md`
  - Must-include deps/devDeps, versions if pinned, platform notes
- `design/specs/global/linting.md`
  - eslint/prettier config preferences, TS strictness
- `design/specs/global/testing.md`
  - unit: `vitest` | `jest`; e2e: `detox`; coverage, directories
- `design/specs/global/linking.md`
  - scheme, prefixes, universal links/app links setup targets
- `design/specs/global/mocking.md`
  - reaffirm Express JSON mock server ports, variant header/param, tunnel choice

Precedence and behavior:
- Global specs override defaults for scaffolding, dependency selection, and config.
- Per-screen specs govern layout/behavior for that screen only.
- If a global spec is missing, Appeus infers:
  - Defaults: Expo + TypeScript, React Navigation, `@expo/vector-icons` (ionicons), Zustand, Fetch, ESLint+Prettier, Vitest (or Jest), Detox optional.
  - These can be tightened later; run regenerate to apply.

## Folder Scaffold (RN-first, Appeus-only)
```
project-root/
├── appeus -> /some/path/to/appeus
├── design/                         # human-facing design surface
│   ├── AGENTS.md -> ../appeus/agent-rules/design-root.md
│   ├── stories/
│   │   └── AGENTS.md -> ../../appeus/agent-rules/stories.md
│   ├── generated/                  # AI-generated inferences derived solely from stories
│   │   ├── AGENTS.md -> ../../appeus/agent-rules/consolidations.md
│   │   ├── navigation.md
│   │   ├── scenarios/
│   │   ├── screens/
│   │   ├── components/
│   └── specs/
│       ├── AGENTS.md -> ../appeus/agent-rules/specs.md
│       ├── navigation.md           # human-authored sitemap and nav rules
│       ├── screens/                # human-authored screen specs
│       └── global/                 # toolchain.md, ui.md, dependencies.md, etc.
├── mock/
│   ├── data/                       # JSON by ns/screen/variant
│   └── server/                     # tiny Express GET/PUT
├── src/                            # RN source (generation target)
│   ├── AGENTS.md -> ../appeus/agent-rules/src.md
│   ├── navigation/                 # routes/stack
│   ├── screens/                    # screens
│   ├── components/                 # shared UI
│   ├── state/                      # scenario/variant state
│   ├── data/                       # HTTPJsonStore adapter for mock server
│   └── engine/                     # future local engine integration
├── package.json
├── app.json | app.config.ts        # Expo (if used)
└── tsconfig.json | jsconfig.json
```

Notes:
- Keep all design artifacts under `design/`. Agents generate code into `src/` only when requested.
- Navigation behaves like other specs: human writes `design/specs/navigation.md`; the agent may also produce/refresh a consolidated navigation view under `design/generated/navigation.md` derived from stories. Codegen merges both (human takes precedence) to emit `src/navigation/*`.
- `AGENTS.md` symlinks point to `appeus/agent-rules/*` to keep guidance centralized.

## Tooling Choices
- React Native via Expo (Dev Client, EAS Updates) and React Navigation or Expo Router.
- Deep linking and universal links via Expo Linking.
- State management for scenario/variant state (Zustand/Recoil).

- For codegen: `ts-morph`, `plop`/`hygen` for idempotent generation of screens and navigation.
- Mocking: tiny Express server for local JSON (default). Optional: `json-server` for quick datasets. Tunnels via Cloudflare Tunnel or ngrok for device/team access.
- Scenario browsing: Markdown scenarios with deep-link buttons into the running app (device/simulator).
- Appeus scripts: `check-stale` (mtime-based), `regenerate` (human-invoked codegen).

## Trade-offs
- Runtime renderer: fastest loop; bounded by schema; great for broad coverage.
- Codegen: most flexible and “final” code; requires careful generators and markers to avoid clobbering manual edits.
- Tunnels are convenient but ephemeral; prefer lightweight hosting for stable reviews.

## Suggested Initial Path
Phase 1 (Foundations):
- Expo app with navigation and deep linking.
- ScenarioRunner overlay and variant plumbing.
- Tiny Express JSON mock server (GET/PUT), variant via `?variant=` or `X-Mock-Variant`.
- Scenario web pages that deep-link into the app.
 - Adopt human-triggered generation and commit discipline; add `check-stale` and `regenerate` scripts.
 - Port/replicate required assets from AppGen into Appeus (rules, templates, scripts).
 - Add AGENTS.md symlinks under `design/*` pointing to `appeus/agent-rules/*`.
 - Place global specs under `design/specs/global/` and navigation spec under `design/specs/navigation.md`.
 - Add initial global specs (toolchain/ui/dependencies) or accept defaults and proceed.

Phase 2 (Rendering strategy):
- Implement codegen pipeline:
  - Parse human screen specs and AI consolidation, merge by priority
  - Generate screens under `src/screens/` and navigation under `src/navigation/`
- Ensure round-trip from story edits/specs → regenerated code → app behavior reliably.

Phase 3 (Hardening):
- Type-safe API client, tests for scenarios/variants, CI preview flow, and docs.

## Roadmap Checklist
- [ ] Initialize Expo RN app with React Navigation/Expo Router
- [ ] Configure deep linking (iOS/Android/Web) and test on device/simulator
- [ ] Implement ScenarioRunner overlay (guide, variant switcher, feedback)
- [ ] Establish global scenario/variant state and plumb into API client
- [ ] Stand up tiny Express JSON mock server (read/write, file-backed)
- [ ] Support variant selection via `?variant=` param or `X-Mock-Variant` header
- [ ] Add tunnel/hosting setup for device-accessible mocks
- [ ] Generate scenario pages under `design/generated/scenarios/` with “Open in App” deep links
- [ ] Implement codegen pipeline and idempotent generators (screens/navigation)
- [ ] Define spec schema (frontmatter fields) and consolidation format
- [ ] Add `appeus/scripts/check-stale` to compare spec/consolidation mtimes vs generated outputs
- [ ] Add `appeus/scripts/regenerate` to run codegen on-demand
- [ ] Document the human-triggered generation flow and commit discipline
- [ ] Add global specs: `design/specs/global/toolchain.md`, `ui.md`, `dependencies.md` (optional at start)
- [ ] Wire codegen to consult global + navigation specs and fall back to defaults
- [ ] Add sample story → scenario → screen flow end-to-end
- [ ] Implement feedback capture that syncs back to stories/specs
- [ ] Add basic test scaffolding per screen/scenario (render + navigation + data)
- [ ] Document contribution workflow and branching strategy

## References (indicative)
- Expo (React Native tooling): see Expo documentation
- React Navigation / Expo Router: navigation and deep linking
- Express / `json-server`: lightweight JSON APIs and local mocks
- Cloudflare Tunnel / ngrok: secure tunnels for local servers
- ts-morph / plop / hygen: TypeScript AST and code generation utilities

This STATUS will evolve as we choose a path and begin implementation.


