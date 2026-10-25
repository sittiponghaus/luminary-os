# Design — application-scaffold

## Topology

```
Client
  │
  ▼
Caddy :12340
  ├─ /api/v1/wss*  ──► server :3000  (websocket / Effect RPC later)
  ├─ /api/v1*      ──► server :3000  (HTTP)
  └─ /*            ──► app    :5173  (Foldkit Vite / preview)
```

## Components

| Piece | Role |
| --- | --- |
| `deploy/Caddyfile` | Path-based reverse proxy; no TLS (operator/tunnel later) |
| `compose.yaml` | Optional: `caddy` + host-network or published ports for local review |
| `@luminary/server` | Effect + `@effect/platform-bun` HTTP listener |
| `shared/config` | Declarative ports/hosts (`as const` + `ValueOf`) |
| `shared/schema` | `HttpResponse` envelope |
| `app/adapter` | Client-side API/WSS adapter stubs pointing at `/api/v1` |

## Example — Caddy handles

```caddy
:12340 {
  handle /api/v1/wss* {
    reverse_proxy {$LUMINARY_SERVER_UPSTREAM:127.0.0.1:3000}
  }
  handle /api/v1* {
    reverse_proxy {$LUMINARY_SERVER_UPSTREAM:127.0.0.1:3000}
  }
  handle {
    reverse_proxy {$LUMINARY_APP_UPSTREAM:127.0.0.1:5173}
  }
}
```

## Example — server health

```ts
// server/controller/http/http.controller.ts → usecase → JSON envelope
HttpServerResponse.json({ ok: true, data: { status: "ok" } })
```

Layering: `controller/http` → `usecase` → (later) `repository` → `adapter`. Health usecase has no repository.
