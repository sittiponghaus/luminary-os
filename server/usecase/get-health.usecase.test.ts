import { describe, expect, test } from "vitest"

import { GetHealth } from "./get-health.usecase.ts"

describe("GetHealth", () => {
  test("returns ok envelope", () => {
    expect(GetHealth()).toEqual({
      ok: true,
      data: { status: "ok" }
    })
  })
})
