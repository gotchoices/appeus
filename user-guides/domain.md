# Domain contract (shared across all app targets)

This folder contains shared specifications about the app’s “domain” — the data and behavior the app depends on, regardless of whether the app is “client/server” or not.

Keep these files **human-readable** and focused on **user-observable behavior** where possible. Detailed programmer structure belongs in consolidations (`design/generated/…`), not in specs.

Common domain contract topics (create only what your project needs):
- **Schema**: entities/structures and relationships
- **Operations**: procedures/operations the UI relies on (queries, commands, calculations)
- **Rules / invariants**: validation, semantics, permissions, constraints
- **Interfaces**: external systems, storage backends, sync model, import/export

Typical file names (optional; use what fits your project):
- `schema.md`
- `api.md` (or `operations.md`)
- `rules.md`
- `interfaces.md`

Notes:
- The domain contract is **shared** across targets (mobile/web/desktop) and should remain compatible as new targets are added.
- When generation is blocked by missing domain details, update these specs first, then regenerate the affected slices.


