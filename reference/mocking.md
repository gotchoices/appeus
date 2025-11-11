# Mocking Strategy (Appeus)

Chosen approach
- Tiny Express server serving local JSON files (read/write)
- Variants via `?variant=happy|empty|error` or `X-Mock-Variant` header

Access
- Local design: device/simulator hits laptop via LAN
- Team/staging: expose via Cloudflare Tunnel/ngrok/ssh -R or host static JSON

Client
- `src/data/` attaches variant header/param from scenario/variant state
- Keep shapes aligned with API specs (design/specs/api/*)

Alternatives (optional)
- json-server with middleware, Postman Mock Server


