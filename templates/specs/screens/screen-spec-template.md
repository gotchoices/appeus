# Screen Spec: <screen-id>

---
id: <screen-id>         # kebab-case, matches filename
route: <RouteName>      # PascalCase route name
variants: [happy, empty, error]
---

## Description

<What is this screen for?>

## Behavior (user-observable)

- <State / rule / constraint>
- <Empty/error expectations>

## Acceptance

- "<User can ...>"

## Notes (optional)

- If you need code-oriented overrides/slots, keep them minimal and prefer putting programmer mapping in consolidations under `design/generated/<target>/`.
