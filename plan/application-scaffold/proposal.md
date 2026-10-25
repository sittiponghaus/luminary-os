# Application scaffold with Caddy reverse proxy

**Proposal:** `application-scaffold`
**Status:** active
**Phase:** bootstrap

## Problem

Luminary OS has folder placeholders and a Foldkit+crease app, but no ingress matching [ARCHITECTURE.md](../../ARCHITECTURE.md) reverse-proxy rules (`/` web, `/api/v1` HTTP, `/api/v1/wss` Effect RPC), and no runnable server package behind that edge.

## Scope

### In scope

- Caddy reverse proxy config + compose/scripts for local ingress on `:12340`
- `@luminary/server` package scaffold: Effect Bun HTTP with health under `/api/v1`, websocket upgrade path stub for `/api/v1/wss`
- Shared config/schema stubs (`http-response`) and declarative port/host config
- App adapter stubs (`api.adapter.ts`, `wss.adapter.ts`) and root workspace wiring
- Record decisions in `RULES.md` with links to specs

### Out of scope

- Full Effect RPC protocol implementation
- Postgres, Drizzle, RustFS, Cloudflare Tunnel, K3S
- Auth, studio controllers, or production TLS (operator proxy owns TLS later)

## Success Criteria

- [ ] `GET /` through Caddy reaches the Foldkit app (or its built assets)
- [ ] `GET /api/v1/health` through Caddy reaches the server and returns a typed JSON envelope
- [ ] `Caddyfile` routes `/api/v1/wss` to the server with websocket upgrade support
- [ ] Specs under this proposal describe the routing and bootstrap contracts

## Specs

| Spec | Path | Summary |
| --- | --- | --- |
| reverse-proxy-routing | `spec/reverse-proxy-routing/spec.md` | Path → upstream map for web, API, WSS |
| server-http-bootstrap | `spec/server-http-bootstrap/spec.md` | Minimal Effect Bun HTTP surface behind `/api/v1` |

## References

- [ARCHITECTURE.md](../../ARCHITECTURE.md) — Reverse Proxy + Folder Architecture
- [asyncs Caddyfile](/root/dev/asyncs/Caddyfile) — prior ingress style (trusted proxies, path handles)
