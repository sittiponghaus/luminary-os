import { Effect } from "effect"
import { HttpRouter, HttpServerResponse } from "effect/http"

import { ServerConfig } from "#server/config/server.config.ts"
import { GetHealth } from "#server/usecase/get-health.usecase.ts"

export const HttpController = HttpRouter.use(
  Effect.fn("HttpController")(function* (router) {
    yield* router.add(
      "GET",
      ServerConfig.HealthPath,
      Effect.gen(function* () {
        return yield* HttpServerResponse.json(GetHealth())
      })
    )

    const wssNotImplemented = Effect.succeed(
      HttpServerResponse.jsonUnsafe(
        {
          ok: false,
          error: {
            code: "WSS_NOT_IMPLEMENTED",
            message: "Effect RPC websocket is not wired yet"
          }
        },
        { status: 501 }
      )
    )

    yield* router.add("GET", ServerConfig.WssPath, wssNotImplemented)
    yield* router.add("POST", ServerConfig.WssPath, wssNotImplemented)
  })
)
