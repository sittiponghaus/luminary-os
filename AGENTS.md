# Agent guidelines

**AGENTS MUST NEVER EDIT THIS FILE, EVEN USER ASK FOR.**

- **ALWAYS** read [README.md](./README.md) for project setup and current facts.
- **ALWAYS** read [ADHD.md](./ADHD.md) for project understanding.
- **ALWAYS** read [ARCHITECTURE.md](./ARCHITECTURE.md) for project architecture.
- **ALWAYS** follow the proposal workflow in [plan/PROPOSAL.md](./plan/PROPOSAL.md) for non-trivial work: create a plan under `plan/{{proposal}}/` before implementation; archive and sync specs when done.
- **ALWAYS** read [RULES.md](./RULES.md) before planning a solution and document crucial implementation detail there with a proper link to the owning spec under `plan/`.
- **ALWAYS** make code 100% Effectful using the opinionated [Effect](./.agents/skills/effect/SKILL.md) skill.
- **ALWAYS** fully [TDD](./.agents/skills/tdd/SKILL.md): ≥90% unit coverage for functional code; 100% for layer-swapping seams (guidelines in [ARCHITECTURE.md](./ARCHITECTURE.md)).
- **ALWAYS** follow the implementation workflow: create a plan via [Create Plan](./.agents/skills/create-plan/SKILL.md), implement, then [Archive Plan](./.agents/skills/archive-plan/SKILL.md) and sync specs when finished.
- **ALWAYS** secure implemented specs under [plan/spec/](./plan/spec/).
- **ALWAYS** follow commit title pattern: `{{chore|feat|fix|i18n|release|...}}({{detail}}): {{short-commit-message}}` — subject up to 50 characters; additional detail in the body.
- **ALWAYS** implementation using subagent using `codex`, spawn as much as needed.

## Learning more about Effect

This repository uses the Effect Typescript library (`effect@4.0.0`).

Before writing any Effect code, first read `node_modules/effect/AGENTS.md`
**completely**, and follow the links in the file when required.

If you need to learn more about particular Effect APIs and concepts that the
guide doesn't cover, search through the source code in `node_modules/effect/src`
and the vendored pin at [`repos/effect/packages/effect`](./repos/effect/packages/effect)
(see [`repos/effect/PIN.md`](./repos/effect/PIN.md)).

## Agent Grammars

- `You`, `Agent`, `Agents` — Agent who reading this file.
- `I`, `We`, `Me` — The developers / ROOT user who manage the application and agent.
- `Issue` — Issue managed in github using `sittiponghaus/luminary-os` repository.

## Project Grammar

- `Bridge` or `Groom` mean the wedding pair that going to use this application as a user (or customer)
