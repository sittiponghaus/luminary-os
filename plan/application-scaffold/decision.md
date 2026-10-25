# Decisions — application-scaffold

### DEC-001: Caddy is the local ingress, not Cloudflare Tunnel yet

**GIVEN** ARCHITECTURE lists Cloudflare Tunnel for production proxy
**WHEN** scaffolding local reverse proxy
**THEN** use Caddy on `:12340` with path rules matching ARCHITECTURE; Tunnel remains a later deploy concern

### DEC-002: Public review port stays 12340

**GIVEN** the Foldkit preview was already reviewed on `10.0.217.112:12340`
**WHEN** introducing Caddy
**THEN** Caddy listens on `:12340` and upstreams move to app `:5173` and server `:3000`

### DEC-003: Server owns `/api/v1` prefix (no strip)

**GIVEN** clients call `/api/v1/...` through the proxy
**WHEN** forwarding to the Bun server
**THEN** Caddy does not rewrite the path; the server mounts routes under `/api/v1`

### DEC-004: WSS path is reserved before generic API handle

**GIVEN** both HTTP API and websocket share `/api/v1`
**WHEN** writing Caddy handles
**THEN** match `/api/v1/wss*` before `/api/v1*` so upgrades are not mishandled
