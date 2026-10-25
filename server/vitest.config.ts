import { fileURLToPath } from "node:url"

import { defineConfig } from "vitest/config"

export default defineConfig({
  root: fileURLToPath(new URL(".", import.meta.url)),
  cacheDir: fileURLToPath(new URL("../node_modules/.vite/server-vitest", import.meta.url)),
  test: {
    include: ["**/*.{test,spec}.ts"],
    environment: "node"
  }
})

