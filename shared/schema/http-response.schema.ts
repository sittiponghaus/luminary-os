import { Schema } from "effect"

export const HttpResponseError = Schema.Struct({
  code: Schema.String,
  message: Schema.optionalKey(Schema.String)
})
export type HttpResponseError = typeof HttpResponseError.Type

export const HttpResponse = <A extends Schema.Top>(data: A) =>
  Schema.Struct({
    ok: Schema.Boolean,
    data: Schema.optionalKey(data),
    error: Schema.optionalKey(HttpResponseError)
  })

export const HealthStatus = {
  Ok: "ok"
} as const

export const HealthData = Schema.Struct({
  status: Schema.Enum(HealthStatus)
})
export type HealthData = typeof HealthData.Type

export const HealthResponse = HttpResponse(HealthData)
export type HealthResponse = typeof HealthResponse.Type
