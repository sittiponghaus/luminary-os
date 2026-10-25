import { ListenConfig } from "#shared/config/listen.config.ts"

/** Browser → Caddy → server HTTP. Paths stay under `/api/v1`. */
export const ApiAdapterConfig = {
  BasePath: "/api/v1",
  HealthPath: "/api/v1/health",
  /** Absolute origin when calling outside same-origin (tests). */
  Origin: `http://${ListenConfig.AppUpstreamHost}:${ListenConfig.CaddyPort}`
} as const

export type ApiAdapterConfigKey = keyof typeof ApiAdapterConfig
export type ApiAdapterConfigValue = ValueOf<typeof ApiAdapterConfig>

export const FetchHealth = async (
  fetchImpl: typeof fetch = fetch
): Promise<Response> => fetchImpl(ApiAdapterConfig.HealthPath, { method: "GET" })
