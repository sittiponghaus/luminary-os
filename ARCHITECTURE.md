# Architecture Guideline

**AGENTS MUST NEVER EDIT THIS FILE, EVEN USER ASK FOR.**.

## Stack

- Effect v4
- Foldkit
- Bun as Package Manager and Runtime
- Drizzle as ORM
- Effect Cluster + Workflow
- Email sending using Cloudflare Email
- Effect MQ (If needed)
- PostgresQL
- RustFS (S3 Compatible)

## Runtime

- Bun
- K3S
- Serve Proxy via Cloudflare Tunnel

## Folder Architecture

- app/ # Front End
  - adapter/
    - api.adapter.ts
    - wss.adapter.ts
  - controller/
    - _authenticated/
      - studio/
        - index.controller.ts
    - _public/
      - index.controller.ts
  - config/
    - app.config.ts
    - some-config.config.ts
  - repository/
    - get-user.repository.ts
  - usecase/
    - verify-user-session.usecase.ts
- shared/
  - config/
  - schema/
    - http-response.schema.ts
- server/
  - adapter/
  - config/
  - controller/
    - http/
      - http.controller.ts
    - workflow/
      - workflow.controller.ts
    - message-queue/
      - message-queue.controller.ts
  - entity/
    - user.entity.ts
  - repository/
  - usecase/
- type/
  - generic.d.ts

## Rules

## Coding Style Rules

- **ALWAYS** use declarative config like `const AppConfig = { BASE_URL: "base-url" } as const`.
- **ALWAYS** define constant and type via `ValueOf<typeof ...>`.
- **ALWAYS** use Effect's Schema for validation.
- **ALWAYS** use `Schema.Enum` instead of Schema.Literal, make sure to have declarative config and use it like `Schema.Enum(AppConfig)`.
- **ALWAYS** use PascalCase for exported variable (export const) like `MakeRegistration`, `NativeLayer`, `CreatedAt`. Local variables stay camelCase.
- **ALWAYS** use Clean Architecture (Onion Architect) with concept `Usecase`, `Repository`, `Entity`, `Adapter`, `Mapper`; No `Port` concept, use `interface` instead. Every handler, controller, service bindings request must hit `usecase` layer first (business logic held here). Repository held the boundary to datastore, external services with no business logic. Adapter layer use to abstract each external interface for reusable in repository layer. `Mapper` use to map the payload with the shared contract (DTO) layer and decode into the usecase desired shape (repository responsibility). E.g., Usecacse -> Repository (with Mapper) -> Adapter; Cli -> Usecase; Http Controller -> Usecase; Workflow Controller -> Usecase.
- **ALWAYS** restricted maximum traverse directory paths import is 1 (`../some-file.ts`), more than that must use absolute import.

### Naming Rules

- **ALWAYS** use singular except variable name can used plural if needed.
- **NEVER** cast type.

### Time Zone Rules

- **ALWAYS** respect local timezone, use single local timezone query to rules all.
- **ALWAYS** store UTC timezone in database.

### Agent Implementation Rules

- **ALWAYS** keep in mind that other Agents might editing the same file too.
- **ALWAYS** use Bun.WebView instead of playwright.
- **ALWAYS** collect **Eval artifacts** under **`.eval/`** (gitignored via `.*`). Never store eval corpora, evidence JSONL, judgments, pools, or metric dumps under tracked `.eval/` or anywhere else in the tree. Scripts default to `.eval/…`.
- **ALWAYS** relentlessly implement plan, never stop until fully finished when user ask for implementation or approved the plan. If decision needed, just ask right away before start implement..
- **ALWAYS** verify by run it first before handoff to user. If it failed, fix.
- **NEVER** ask to switch for plan mode.
- **NEVER** run dev server, user owned it. If it not run, just tell user to do.
- **NEVER** handoff anything back to user without verify it work.

### Architecture Design Rules

- **ALWAYS** show the **full picture scoped by authority** when the user asks for an **diagram** or **model** — never a flat list that looks like one; Group entities by authority per topology.
- **ALWAYS** design in Clean Architecture with concept: Controller (Handler), Usecase, Repository, Adapter, Mapper instead of

### Commit & PR Rules

- **ALWAYS** have proper `patch` or `minor` via `bun changeset add` when changes.
- **ALWAYS** upload eval results in MR comment including images if applicable.
- **ALWAYS** eval paragraph-like, tldr-like, long, medium, short type of text in UI to simulate broken UI before ship.

## Testing Rules

- **ALWAYS** follow the tdd skill for the general testing workflow.
- **ALWAYS** protect meaningful user behavior UI tests such as: interactions, state transitions, validation behavior, navigation, accessibility state, permissions, loading/error behavior
- **ALWAYS** testing business behavior at the Effect/service layer when possible.
- **NEVER** write UI test to use PlayWright verification, strictly vitest is enough.
- **NEVER** apply exhaustive TDD to presentation details.
- **NEVER** add tests solely for: Tailwind classes, StyleX output or class composition, conditional styling, exact DOM structure, snapshots, ordinary translation rendering, copy changes with no behavioral significance

### Testing Example

- Prefer `expect(button).toBeDisabled()` instead of `expect(button).toHaveClass("opacity-50")`
- Prefer testing the Effect rule that determines whether an action is allowed instead of exhaustively testing every styling permutation.
- Translation catalogs, interpolation, fallback behavior, and missing keys may be tested centrally rather than in every component.

### Testing Rule of thumb

Before adding a UI test, ask: `What meaningful user behavior would regress?`. If the answer is only styling, classes, markup, or ordinary translated copy, do not add the test.
