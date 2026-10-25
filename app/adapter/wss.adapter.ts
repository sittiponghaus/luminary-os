/** Browser → Caddy → server websocket (Effect RPC later). */
export const WssAdapterConfig = {
  Path: "/api/v1/wss"
} as const

export type WssAdapterConfigKey = keyof typeof WssAdapterConfig
export type WssAdapterConfigValue = ValueOf<typeof WssAdapterConfig>

export const MakeWssUrl = (protocol: "ws" | "wss", host: string): string =>
  `${protocol}://${host}${WssAdapterConfig.Path}`
