# @luminary/app

Foldkit SPA with [crease/ui](https://creaseui.com) (`crease-core` + Lucide icons) and create preset `c4zqDt03xwdrsOpnkMhURm4` (nova / neutral / Inter).

## Commands

```bash
# from repo root
bun run dev
bun run build
bun run typecheck
bun run test

# or from this package
bun run dev
```

## Crease

- `components.json` — shadcn CLI config (`tsx: true` for TypeScript; no JSX)
- `src/ui/*`, `src/lib/*` — installed Crease source (owned by this app)
- `src/crease-preset.json` — runtime copy of preset knobs (shadcn `@/crease-preset.json`)
- `src/styles/crease-preset.css` — runtime tokens (also inlined at end of `src/styles.css`)
- `config/crease-preset/` — owned preset source (`registry-item.json`, css, json)

Add more components:

```bash
bunx --bun shadcn@latest add Potti1234/creaseui/<component> --yes
```
