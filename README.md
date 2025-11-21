# Appeus

Appeus is a design-to-app workflow that turns user stories into a running React Native app as you design it. Instead of generating static screens or diagrams, Appeus renders live screens with navigation, deep linking, and mock data so that what you review in the simulator is the actual app you ship.

Focus
- Stories → consolidations/specs → codegen RN → run → iterate
- Deep links into the app from scenario pages
- Narrative scenarios (human-friendly) with clickable, phone-sized screenshots
- Preview and publish flows for scenarios (local markserv preview; static HTML publish)
- Optional in-app overlay for guided reviews
- Simple mock data with variants via deep-link query

Toolkit layout
- agent-rules/: guidance for AI agents (linked via AGENTS.md in project folders)
- scripts/: rn-init, setup-appeus, check-stale, regenerate, update-dep-hashes, android-screenshot, build-images, preview-scenarios, publish-scenarios
- templates/: starter files for specs (screens/navigation/global/api), consolidations (screens/api), scenarios
- reference/: workflows and codegen guidance (including API workflow)
- user-guides/: quick guides for humans

Start here
- Read QUICKSTART to initialize a project
- See `reference/scenarios.md` for scenario workflow (images, preview, publish)


