# Mocking Strategy

How Appeus handles mock data for development and testing.

## Overview

Mock data enables:
- Development without a backend
- Testing edge cases (empty states, errors)
- Scenario screenshots with controlled data
- Stakeholder demos

## Approach

### Local JSON Files

Mock data lives in `mock/data/`:

```
mock/data/
├── items.happy.json        # Normal data
├── items.empty.json        # Empty state
├── items.error.json        # Error response
├── items.meta.json         # Metadata (dependencies, variants)
└── ...
```

### Variant Selection

Variants are selected via:
- Deep link query: `myapp://screen/ItemList?variant=empty`
- HTTP header: `X-Mock-Variant: empty`
- Context/state in the app

### Standard Variants

| Variant | Purpose |
|---------|---------|
| `happy` | Normal state with typical data |
| `empty` | No data, empty state UI |
| `error` | Error response, error UI |
| `loading` | (Optional) Simulated slow response |

## Mock Server (Optional)

For dynamic mocking, a tiny Express server can serve JSON:

```javascript
// mock/server/index.js
const express = require('express');
const app = express();

app.get('/api/:namespace', (req, res) => {
  const variant = req.query.variant || req.headers['x-mock-variant'] || 'happy';
  const file = `./data/${req.params.namespace}.${variant}.json`;
  res.sendFile(file, { root: __dirname + '/..' });
});

app.listen(3001);
```

## Client Integration

Data adapters in `apps/<target>/src/data/` read mock data:

```typescript
// src/data/items.ts
import { mockMode, getVariant } from '../mock';

export async function fetchItems() {
  if (mockMode) {
    const variant = getVariant();
    const data = await import(`../../mock/data/items.${variant}.json`);
    return data.default;
  }
  // Production: call real API
  return fetch('/api/items').then(r => r.json());
}
```

## Mock Metadata

Each namespace has a `.meta.json` tracking dependencies:

```json
{
  "namespace": "items",
  "dependsOn": ["design/specs/domain/api.md"],
  "depHashes": {
    "design/specs/domain/api.md": "sha256:..."
  },
  "variants": ["happy", "empty", "error"]
}
```

## Access Patterns

| Scenario | How to Access |
|----------|---------------|
| Local development | Device/simulator hits laptop via LAN |
| Team/staging | Cloudflare Tunnel, ngrok, or ssh tunnel |
| CI/testing | Static JSON bundled with app |

## Data Shape Alignment

Mock data must match the API portion of the domain contract in `design/specs/domain/`:

1. Agent reads API spec for endpoint shape
2. Generates mock data matching that shape
3. Updates meta.json with dependency

When API spec changes, mock data is stale and should be regenerated.

## See Also

- [Mock Variants](mock-variants.md)
- [Domain contract](../agent-rules/domain.md)
- [Generation Workflow](generation.md)
