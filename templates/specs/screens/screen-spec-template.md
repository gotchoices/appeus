# Screen Spec: <screen-id>

---
id: <screen-id>
route: <RouteName>
title: <Title>
variants: [happy, empty, error]
dataRequirements:
  - <key>: <type>
actions:
  - <actionName>(<params>)
layoutHints:
  - header:large
acceptance:
  - "User can <do X> and see <Y>"
overrides:
  slots: []  # e.g., [imports, component, styles]
---

## Notes
- Add clarifications, wire references, and behaviors here.
- Keep the project’s delivery posture in mind (see `design/specs/project.md`): if this screen can grow large or must stay fast, call that out as user-observable expectations.

```ts slot=imports
// Optional: custom imports
```

```tsx slot=component
// Optional: custom component body
```

```ts slot=styles
// Optional: styles
```


