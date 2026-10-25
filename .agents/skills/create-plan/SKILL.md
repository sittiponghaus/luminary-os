---
name: create-plan
description: Scaffolds the plan/ workflow (plan/PROPOSAL.md, archived/, spec/) and creates structured implementation plans under plan/{{proposal}}/. Use when starting a feature, change request, or implementation task; when the user asks to plan work or set up planning in a repo; or before writing code for any non-trivial change in this repository.
---

# Create Plan

All non-trivial work starts as a proposal under `plan/`. `plan/PROPOSAL.md` is the repository's canonical workflow. Read it first; it overrides this skill where they differ. If it is missing, the scripts below create it.

## Scripts

Both scripts ship with this skill in `script/` (relative to this `SKILL.md`). Run them from anywhere inside the target repository; they resolve `plan/` from the git top level (override with `PLAN_DIR=/path/to/plan`). Always invoke them through `bash`, because skill installers do not reliably preserve the executable bit.

| Script | Does |
| --- | --- |
| `init-plan.sh [--dry-run]` | One-time repo setup: creates `plan/PROPOSAL.md` from `template/PROPOSAL.md`, plus `plan/archived/` and `plan/spec/` (with `.gitkeep`). Idempotent; **never overwrites** an existing `PROPOSAL.md`. |
| `create-plan.sh <slug> [--title "Title"] [--spec <spec>]... [--dry-run]` | Creates `plan/<slug>/` with `proposal.md`, `design.md`, `decision.md`, `task.md` and `spec/<spec>/spec.md` per `--spec`, filling the title and slugs. Runs `init-plan.sh` first if the structure is missing. Rejects non-kebab-case, reserved (`archived`, `spec`), duplicate or previously archived slugs. |

```bash
# project install example
bash .agents/skills/create-plan/script/create-plan.sh hardware-passport --spec passport-api
```

## When to Use

- New feature, refactor, or change request
- User says "plan", "proposal", "design doc", or "spec"
- Work spans multiple files or architectural decisions
- Bug fix that touches contracts, APIs, or data models

Skip for: typos, one-line fixes, dependency bumps with no behavior change.

## Directory Layout

```
plan/
├── PROPOSAL.md              # Workflow (scaffolded once, then repo-owned — never edit or duplicate)
├── {{proposal}}/            # Active work — kebab-case slug
│   ├── proposal.md          # Problem, scope, success criteria
│   ├── design.md            # Architecture + example code
│   ├── decision.md          # GIVEN | WHEN | THEN records
│   ├── task.md              # Implementation checklist ([ ] / [x])
│   └── spec/
│       └── {{spec}}/        # kebab-case spec slug
│           └── spec.md
├── archived/
│   └── {{YYYYMMDD}}-{{feature}}/   # Completed proposals (snapshot)
└── spec/
    └── {{spec}}/            # Canonical completed specs
        └── spec.md
```

**Naming:** `{{proposal}}` and `{{spec}}` are kebab-case (e.g. `hardware-passport`, `promptpay-escrow`).

## Workflow

```
1. CREATE  plan/{{proposal}}/  (all required files)
2. IMPLEMENT  — check off task.md as work completes
3. ARCHIVE  — copy proposal to plan/archived/{{YYYYMMDD}}-{{feature}}/
4. MIGRATE  — copy each spec/ to plan/spec/{{spec}}/spec.md
5. DELETE or leave stub  — remove active plan/{{proposal}}/ after migration (prefer delete)
```

### Step 1 — Create proposal

1. Pick a kebab-case `{{proposal}}` slug and one `--spec` per bounded contract (API, schema, protocol).
2. Run `create-plan.sh` (above). It refuses collisions with `plan/` and `plan/archived/`.
3. Replace every remaining `{{placeholder}}` in the generated files. The templates are in `template/` if you need to create a file by hand.
4. Link upstream context when relevant (roadmap, `plan/IDEA.md`, phase files).
5. Do **not** start implementation until `proposal.md` scope and `task.md` are filled in.

### Step 2 — Implement

- Work tasks top-to-bottom in `task.md`.
- Mark `[x]` immediately when a task is done — not at PR end.
- Update `design.md` / `decision.md` when implementation diverges; add new GIVEN|WHEN|THEN rows for decisions made during build.

### Step 3–5 — Archive & sync

When all `task.md` items are `[x]`, use the **`archive-plan`** skill. Its script lives next to that skill's `SKILL.md`; run it from the repository root:

```bash
bash <archive-plan skill dir>/script/archive-plan.sh {{proposal}}
# e.g. bash .agents/skills/archive-plan/script/archive-plan.sh {{proposal}}
```

See the `archive-plan` skill for validation rules and manual fallback.

## File Responsibilities

| File | Contains | Does not contain |
| --- | --- | --- |
| `proposal.md` | Why, scope, out-of-scope, success criteria | Code, step-by-step tasks |
| `design.md` | Architecture diagram, components, **example code** | Checkbox tasks |
| `decision.md` | GIVEN \| WHEN \| THEN decision log | Architecture prose |
| `task.md` | Ordered `[ ]` checklist for implementation | Design rationale |
| `spec/{{spec}}/spec.md` | API contracts, schemas, acceptance criteria | Implementation tasks |

## decision.md Format

One decision per block:

```markdown
### DEC-001: {{title}}

**GIVEN** {{precondition or context}}
**WHEN** {{action or trigger}}
**THEN** {{expected outcome or rule}}
```

Number sequentially (DEC-001, DEC-002). Never delete — supersede with a new DEC entry.

## Change Requests

Every change request **must** follow this structure:

1. New proposal folder, **or** reopen existing proposal if same feature and not yet archived.
2. Append decisions to `decision.md`; extend `task.md` with new items.
3. If amending a shipped spec, update `plan/spec/{{spec}}/spec.md` via a new proposal that references the spec.

## Agent Checklist

```
- [ ] plan/PROPOSAL.md exists (init-plan.sh) and was read
- [ ] Proposal created with create-plan.sh (slug unique, kebab-case)
- [ ] No {{placeholders}} left in proposal.md, design.md, decision.md, task.md
- [ ] spec.md created for each bounded interface/contract
- [ ] task.md items are concrete and ordered
- [ ] Linked to roadmap / phase if applicable
- [ ] On completion: run `archive-plan` (see archive-plan skill)
```

## Additional Resources

- File templates: `template/` (`PROPOSAL.md`, `proposal.md`, `design.md`, `decision.md`, `task.md`, `spec.md`)
- Repository workflow: `plan/PROPOSAL.md`
- Repository agent guidelines (if present): `AGENTS.md`
