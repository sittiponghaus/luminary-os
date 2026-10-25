# Spec — server-http-bootstrap

## Purpose

Minimal Effect Bun HTTP server behind `/api/v1` for ingress verification.

## Endpoints

### `GET /api/v1/health`

**Response** `200 application/json` envelope:

```json
{
  "ok": true,
  "data": { "status": "ok" }
}
```

Schema: `shared/schema/http-response.schema.ts` (`HttpResponse`).

### `GET|POST /api/v1/wss` (scaffold)

Accepts HTTP upgrade requests for websocket. Until Effect RPC is wired, a non-upgrade request MAY return `501` with envelope `{ "ok": false, "error": { "code": "WSS_NOT_IMPLEMENTED" } }`.

## Layering

`server/controller/http` → `server/usecase` → (no repository for health).

## Config

Declarative `ServerConfig` in `server/config` and shared listen ports in `shared/config` using `as const` + `ValueOf`.

## Acceptance

- Server starts with Bun and listens on port `3000` by default.
- Health usecase is unit-tested (≥1 happy path).
- Through Caddy, health is reachable at `/api/v1/health`.
