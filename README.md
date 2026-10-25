# Luminary OS

Opinionated platform for Thai-styled wedding operations.

## Docs

| Doc | Holds |
| --- | --- |
| [ADHD.md](./ADHD.md) | Business north star |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | Stack, folders, coding & testing rules |
| [AGENTS.md](./AGENTS.md) | How agents must behave |
| [RULES.md](./RULES.md) | Crucial implementation decisions (with `plan/spec/` links) |
| [plan/PROPOSAL.md](./plan/PROPOSAL.md) | Proposal-first workflow |

## Setup

```bash
bun install   # single root node_modules only — no app/ or server/ installs
```

Effect agents: read `node_modules/effect/AGENTS.md`, then source under `node_modules/effect/src` or the pinned tree `repos/effect/packages/effect` (`repos/effect/PIN.md`).

## Local stack (Caddy ingress)

Upstream processes (you own long-running terminals):

```bash
bun run dev:server          # Effect HTTP :3000
bun run dev:app             # Foldkit Vite :5173
```

Ingress:

```bash
bun run proxy:validate
bun run proxy               # Caddy on :12340 (host network)
```

| Path | Upstream |
| --- | --- |
| `/` | app `:5173` |
| `/api/v1/*` | server `:3000` |
| `/api/v1/wss` | server `:3000` (501 until Effect RPC) |

Review URL: `http://<host>:12340/`

## Scripts

```bash
bun run build
bun run test
bun run typecheck
bun run fmt
bun run lint
```

## Layout

```
package.json   # sole package manifest + dependency lock
node_modules/  # sole install tree
repos/effect/  # vendored Effect@4.0.0 source pin (agent reference)
app/           # Foldkit + crease/ui (+ adapter/, config/, …)
server/        # Effect Bun API
shared/        # config + schemas
type/          # ambient types (ValueOf)
deploy/        # Caddyfile
plan/          # proposals / specs
```

Crease preset: `c4zqDt03xwdrsOpnkMhURm4` under `app/config/crease-preset/`. Imports: `#app/`, `#server/`, `#shared/`, `#type/`, and `@/` → `app/src/`.
