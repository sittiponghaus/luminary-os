# Rules

Crucial implementation decisions and the reasons behind them: architecture choices, solution design, workflow/pipeline, and how controllers and handlers relate to usecases. Read this before planning any solution. Each rule links the spec that owns its full contract under `plan/spec/`; requirements are never copied here.

## Reverse proxy ingress

Local and compose ingress MUST go through Caddy (`deploy/Caddyfile`, `compose.yaml` with `network_mode: host`). Public listen is `:12340`. Route `/api/v1/wss*` then `/api/v1*` to the Bun server (`127.0.0.1:3000`), and all other paths to the Foldkit app (`127.0.0.1:5173`). Do not strip `/api/v1`. See [reverse-proxy-routing spec](./plan/application-scaffold/spec/reverse-proxy-routing/spec.md).

## Server HTTP bootstrap

`@luminary/server` owns Effect Bun HTTP under `/api/v1`. Controllers call usecases first (`HttpController` → `GetHealth`). Health returns the shared `HttpResponse` envelope from `shared/schema/http-response.schema.ts`. WSS is reserved at `/api/v1/wss` and returns `501 WSS_NOT_IMPLEMENTED` until Effect RPC is wired. See [server-http-bootstrap spec](./plan/application-scaffold/spec/server-http-bootstrap/spec.md).
