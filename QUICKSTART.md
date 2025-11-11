# Quickstart

This quickstart helps you spin up the agent-guided scaffold so your stories become a running React Native app as you design it. Keep details light here—the agent will drive specifics and choices (runtime renderer vs codegen, mocks, navigation).

## Prerequisites
- Node.js LTS and Yarn (or npm)
- Expo tooling (CLI or Dev Client) and an iOS/Android simulator (or device)
- A Git repo for your app (recommended)

## 1) Start with your first story
Create a short user story (e.g., “As a user, I can create a todo”). Keep it concrete; list a couple of scenarios and variants (happy/empty/error).

## 2) Invoke the AI agent to scaffold
In your editor/agent:
- Ask it to “Initialize Appeus scaffold for React Native with live navigation, deep linking, and mock data.”
- Provide your first story and scenarios. The agent will:
  - Set up a minimal RN app (Expo) with navigation and deep link config
  - Create a ScenarioRunner overlay to guide flows and toggle variants
  - Configure a mock API source (local or hosted) with variant selection
  - Choose a path: runtime schema-rendered UI or codegen RN screens

## 3) Open the app and iterate
- Run the app in a simulator or on device
- From a scenario page or overlay, deep-link into a screen with a variant
- Tweak the story/specs; have the agent apply changes back into source

## 4) Evolve toward production
- Replace mocks with real endpoints as they’re ready
- Tighten types, tests, and any generated artifacts

If you want more detail on tool choices or workflows, see STATUS.


