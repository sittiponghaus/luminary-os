import type { HealthResponse } from "#shared/schema/http-response.schema.ts"

export const GetHealth = (): HealthResponse => ({
  ok: true,
  data: { status: "ok" }
})
