# Agent guidelines

**AGENTS MUST NEVER EDIT THIS FILE, EVEN USER ASK FOR.**.

- **ALWAYS** read [README.md](./README.md) for project architecture and guideline.
- **ALWAYS** read [ADHD.md](./ADHD.md) for project understanding.
- **ALWAYS** read [ARCHITECTURE.md](./ARCHITECTURE.md) for project architecture.
- **ALWAYS** follow the proposal workflow in [plan/PROPOSAL.md](./plan/PROPOSAL.md) for non-trivial work: create a plan under `plan/{{proposal}}/` before implementation; archive and sync specs when done.
- **ALWAYS** read [RULES.md](./RULES.md) before planning solution and document crucial implementation detail there with proper link to spec in `plan/` folder.
- **ALWAYS** make code 100% Effectful using opinioned based [Effect](./.agents/skills/effect/SKILL.md) skill.
- **ALWAYS** fully [TDD](./.agents/skills/tdd/SKILL.md) with over unit test coverage is 90%+ for funcional only, 100% for layer swapping with testing mindset (guideline in [ARCHITECTURE.md](./ARCHITECTURE.md)).
- **ALWAYS** follow implementaion workflow to create a plan via [Create Plan](./.agents/skills/create-plan/SKILL.md) and implement, then [Archive Plan](./.agents/skills/archive-plan/SKILL.md) + Sync spec when finished.
- **ALWAYS** secured implemented spec under [plan/spec/](./plan/spec/).
- **ALWAYS** follow commit title pattern: `{{chore|feat|fix|i18n|release|...}}({{detail}}): {{short-commit-message}}` short up to 50 characters, additional detail in comment message.

## Agent Grammars

- `You`, `Agent`, `Agents` — Agent who reading this file.
- `I`, `We`, `Me` — The developers / ROOT user who manage the application and agent.
- `Issue` — Issue managed in github using `sittiponghaus/luminary-os` repository.

## Project Grammar

- `Bridge` or `Groom` mean the wedding pair that going to use this application as a user (or customer)
