# Effect source pin

- Package: `effect@4.0.0` (matches root `package.json` / `node_modules/effect`)
- Upstream tag: `effect@4.0.0` (`67ba4e46a11ccda0b6761578bfd22c04ae00167d`)
- Sparse paths: `packages/effect`

Runtime installs stay in `node_modules/effect`. This tree is for agent/source reference only.

Re-pin after upgrading `effect`:

```bash
rm -rf repos/effect
git clone --depth 1 --filter=blob:none --sparse --branch "effect@$(node -p "require('./node_modules/effect/package.json').version")" \
  https://github.com/Effect-TS/effect.git repos/effect
git -C repos/effect sparse-checkout set packages/effect
rm -rf repos/effect/.git
```
