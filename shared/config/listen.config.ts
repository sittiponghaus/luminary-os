export const ListenConfig = {
  CaddyPort: 12340,
  AppPort: 5173,
  ServerPort: 3000,
  /** Bind address for local upstreams (loopback; Caddy uses host networking). */
  AppUpstreamHost: "127.0.0.1",
  ServerUpstreamHost: "127.0.0.1",
  ServerBindHost: "127.0.0.1"
} as const

export type ListenConfigKey = keyof typeof ListenConfig
export type ListenConfigValue = ValueOf<typeof ListenConfig>
