import { ListenConfig } from "#shared/config/listen.config.ts"

export const ServerConfig = {
  Host: ListenConfig.ServerBindHost,
  Port: ListenConfig.ServerPort,
  ApiPrefix: "/api/v1",
  HealthPath: "/api/v1/health",
  WssPath: "/api/v1/wss"
} as const

export type ServerConfigKey = keyof typeof ServerConfig
export type ServerConfigValue = ValueOf<typeof ServerConfig>
