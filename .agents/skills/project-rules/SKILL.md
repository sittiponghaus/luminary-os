---
name: project-rules
description: Maintains RULES.md, the repository's implementation-detail authority — the architecture choices, solution design, workflow/pipeline and controller → usecase relations, each with its reason and a link to the owning spec under plan/. Use before planning any solution (read the rules that constrain it), after implementing or archiving a plan (record the crucial decisions), when the user asks to add, update, audit or check project rules, or when setting up RULES.md in a repository.
---

# Project Rules

`RULES.md` (repository root) records **why the system is shaped the way it is**. Each rule states a decision, the authority that owns it (files, layers, packages, tests), and links to the spec that defines the full contract. It is read before every plan and updated after every crucial implementation.

| Document | Holds | Never holds |
| --- | --- | --- |
| `README.md` | Commands, setup, current project facts | Design rationale |
| `AGENTS.md` | How agents must behave | Implementation detail |
| `RULES.md` | Decisions, authority, invariants, reason, spec link | Requirements/scenarios copied from specs, task lists |
| `plan/spec/<spec>/spec.md` | Full contract: requirements, schemas, acceptance | Cross-feature rationale |

## Scripts

Both ship in `script/` next to this `SKILL.md`. Run them from anywhere inside the target repository. They resolve the file from the git top level (override with `RULES_FILE=/path/to/RULES.md`). Always invoke them through `bash`, because skill installers do not reliably preserve the executable bit.

| Script | Does |
| --- | --- |
| `init-rules.sh [--dry-run]` | Creates `RULES.md` from `template/RULES.md` if it is missing. **Never overwrites.** Prints the `AGENTS.md` lines that make agents use it (it does not edit `AGENTS.md`). |
| `check-rules.sh [--strict]` | Audits `RULES.md`. **Errors:** missing file, missing `# ` title, a relative link to a file that does not exist. **Warnings** (errors with `--strict`): a `## ` section with no link into `plan/`, a leftover `{{placeholder}}`. |

```bash
# project install example
bash .agents/skills/project-rules/script/check-rules.sh
```

## 1. Read before planning

Before you write a proposal (see the `create-plan` skill) or design a fix:

1. Read all of `RULES.md`. If it is long, read every `## ` heading, then each section that touches the area you will change.
2. Treat each rule as a constraint on the plan. If the plan has to break a rule, say so in `proposal.md` and record a superseding decision in `decision.md`. Do not break it silently.
3. Follow the linked spec when you need the full contract. The rule is only the summary.
4. If the user asks for something a rule forbids, quote the rule and its spec link, then ask whether to supersede it.

## 2. Record after implementing

Update `RULES.md` in the same change as the implementation, normally right after `archive-plan` has synced the specs into `plan/spec/`.

**Record** a decision when a future agent could reasonably get it wrong without being told:

- Architecture and layering: what calls what (`Controller → Usecase → Repository (+ Mapper) → Adapter`), which layer owns which concern, the only allowed side-effect seam.
- Authority: the single package, module or component that owns a concern, and what is forbidden instead (local re-implementations, direct imports, style overrides).
- Workflow and pipeline behavior: release, deploy, migration custody, queue or retry semantics.
- Contracts that cross repositories, and what must change together (paired MRs, mirrored test tables).
- Non-obvious invariants and their reason: boundary dates, idempotency keys, lease/ordering rules, a library quirk that bit you.
- The test or lint rule that enforces the decision.

**Skip:** commands and setup (README), full requirements (spec), step-by-step tasks (task.md), trivial or self-evident code facts.

### Writing a rule

- Put it under a `## ` heading named after the concern or authority (`## Release versioning`, `## Notification runtime`), not after a ticket. Add to an existing section when the concern already has one.
- Write one dense paragraph or a few bullets. State the rule first, then the owner, then the reason.
- Use normative words: `MUST`, `never`, `only`, `do not`. Name concrete symbols in backticks: files, types, layers, flags, config keys.
- Name the enforcement: `Enforced by test/boundary/<name>.test.ts`.
- Pin versions when the rule depends on one: `With @scope/pkg 0.15, …`.
- End with the spec link: `See [<spec name> spec](./plan/spec/<spec>/spec.md).` Link `plan/archived/<YYYYMMDD>-<proposal>/` only when the decision has no canonical spec.
- Never paste requirements or scenarios from the spec. Link them.

```markdown
## Release versioning

Changesets are the only version source. Every MR into `main` adds `.changeset/*.md`; nobody bumps
`package.json` by hand (a `preversion` hook blocks it). Tags must equal `package.json` and are checked
by `tag_contract`. See [changeset release automation spec](./plan/spec/changeset-release-automation/spec.md).
```

### Superseding a rule

Edit the rule in place so `RULES.md` always describes the current system. Link the new spec and name the old one: `See [native default spec](…), superseding [square theme radius](…).` Never leave two contradictory rules in the file. The history stays in `plan/archived/` and git.

## 3. Audit

Run `check-rules.sh` after every edit and fix all errors. Fix warnings too unless the section really has no spec yet. In that case, write the spec, or link the archived proposal that made the decision.

## Agent Checklist

```
- [ ] Read RULES.md before planning; plan respects or explicitly supersedes each relevant rule
- [ ] After implementing: crucial decisions recorded under the right ## section
- [ ] Each rule names its owner/enforcement and ends with a plan/spec link
- [ ] Superseded rules edited in place (no contradictions left)
- [ ] check-rules.sh passes
```

## Additional Resources

- Template: `template/RULES.md`
- Plans and specs: `create-plan` and `archive-plan` skills
- Repository agent guidelines (if present): `AGENTS.md`
