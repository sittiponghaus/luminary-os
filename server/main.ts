import { BunHttpServer, BunRuntime } from "@effect/platform-bun"
import { Layer } from "effect"
import { HttpRouter } from "effect/http"

import { ServerConfig } from "#server/config/server.config.ts"
import { HttpController } from "#server/controller/http/http.controller.ts"

const HttpServerLive = HttpRouter.serve(HttpController).pipe(
  Layer.provide(
    BunHttpServer.layer({
      hostname: ServerConfig.Host,
      port: ServerConfig.Port
    })
  )
)

BunRuntime.runMain(Layer.launch(HttpServerLive))
