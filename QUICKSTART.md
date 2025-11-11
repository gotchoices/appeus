# Quickstart

This quickstart helps you spin up the agent-guided scaffold so your stories become a running React Native app as you design it.

Prerequisites
- Node.js LTS and Yarn (or npm)
- Expo tooling (CLI or Dev Client) and an iOS/Android simulator (or device)
- A Git repo for your app (recommended)

1) Initialize design surface
- From your project root: `./appeus/scripts/init-project.sh`
- This creates `design/` folders and AGENTS.md links; seeds `design/specs/navigation.md`, `design/specs/global/*`, and `design/specs/api/README.md`

2) Write your first story
- Add `design/stories/01-first-story.md` with goal, sequence, acceptance, variants

3) Derive consolidations and specs
- Ask the agent to create `design/generated/screens/<id>.md` and `design/specs/screens/<id>.md` as needed
- Update `design/specs/navigation.md` with sitemap and deep links
- Define API procedures in `design/specs/api/*.md` (agent can seed from the template)

4) Generate RN code (on request)
- Run `./appeus/scripts/check-stale` to see what’s out of date
- Run `./appeus/scripts/regenerate` and have the agent generate/update `src/screens/*` and `src/navigation/*`

5) Run and iterate
- Launch the app (Expo or bare RN)
- Use scenario pages (`design/generated/scenarios/*`) with “Open in App” links
- Edit stories/specs and regenerate as needed

See STATUS for workflows and roadmap.


