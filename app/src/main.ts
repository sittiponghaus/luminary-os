import { Schema } from "effect"
import { Runtime, type Update } from "foldkit"
import { Document, HtmlBuilder } from "foldkit/html"
import { defineMessageUnion } from "foldkit/message"
import { modifyFields } from "foldkit/struct"

import * as Button from "@/ui/button"

// MODEL

export const Model = Schema.Struct({ count: Schema.Number })
export type Model = typeof Model.Type

// MESSAGE

export const Message = defineMessageUnion({
  ClickedDecrement: {},
  ClickedIncrement: {},
  ClickedReset: {}
})
export type Message = typeof Message.Type

// UPDATE

export const update = (model: Model, message: Message) =>
  Message.match<Update.Return<Model, Message>>(message, {
    ClickedDecrement: () => ({
      model: modifyFields(model, { count: (count) => count - 1 })
    }),
    ClickedIncrement: () => ({
      model: modifyFields(model, { count: (count) => count + 1 })
    }),
    ClickedReset: () => ({ model: modifyFields(model, { count: () => 0 }) })
  })

// INIT

export const init: Runtime.ApplicationInit<Model, Message> = () => ({
  model: { count: 0 }
})

// VIEW

export const view = (model: Model, h: HtmlBuilder<Message>): Document => ({
  title: `Counter: ${model.count}`,
  body: h.div(
    [
      h.Class(
        "min-h-screen bg-background text-foreground flex flex-col items-center justify-center gap-6 p-6"
      )
    ],
    [
      h.p([h.Class("text-6xl font-bold tracking-tight")], [model.count.toString()]),
      h.div(
        [h.Class("flex flex-wrap justify-center gap-3")],
        [
          Button.button(
            {
              children: ["-"],
              onClick: Message.ClickedDecrement(),
              variant: "outline",
              size: "lg"
            },
            h
          ),
          Button.button(
            {
              children: ["Reset"],
              onClick: Message.ClickedReset(),
              variant: "secondary",
              size: "lg"
            },
            h
          ),
          Button.button(
            {
              children: ["+"],
              onClick: Message.ClickedIncrement(),
              variant: "default",
              size: "lg"
            },
            h
          )
        ]
      )
    ]
  )
})
