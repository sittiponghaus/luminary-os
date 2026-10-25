import { fileURLToPath } from "node:url"

import { foldkit } from "@foldkit/vite-plugin"
import tailwindcss from "@tailwindcss/vite"
import { defineConfig } from "vite"

const root = fileURLToPath(new URL(".", import.meta.url))

export default defineConfig({
  root,
  cacheDir: fileURLToPath(new URL("../node_modules/.vite/app", import.meta.url)),
  plugins: [tailwindcss(), foldkit()],
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
      "#shared": fileURLToPath(new URL("../shared", import.meta.url))
    }
  },
  optimizeDeps: {
    entries: ["src/entry.ts"]
  }
})


