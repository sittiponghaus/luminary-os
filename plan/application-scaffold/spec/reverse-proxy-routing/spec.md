# Spec — reverse-proxy-routing

## Purpose

Define local Caddy ingress path routing for Luminary OS.

## Contract

| Path | Upstream | Notes |
| --- | --- | --- |
| `/api/v1/wss`, `/api/v1/wss/*` | `LUMINARY_SERVER_UPSTREAM` (default `127.0.0.1:3000`) | Websocket upgrade; Effect RPC later |
| `/api/v1`, `/api/v1/*` | same server upstream | HTTP JSON API |
| all other paths | `LUMINARY_APP_UPSTREAM` (default `127.0.0.1:5173`) | Foldkit web |

## Invariants

- Listen address for local review: `:12340` (all interfaces via compose/`0.0.0.0` as needed).
- No TLS in this scaffold; plaintext HTTP behind operator/tunnel later.
- WSS handle MUST be declared before the generic `/api/v1*` handle.
- Paths are forwarded without stripping `/api/v1`.

## Acceptance

- Request `GET http://<host>:12340/api/v1/health` returns server JSON (not the SPA).
- Request `GET http://<host>:12340/` returns the Foldkit document (HTML).
- Caddy config is checked with `caddy validate` (or equivalent container run).
