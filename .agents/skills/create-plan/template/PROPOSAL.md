# Proposal Workflow

> **AGENTS MUST NEVER EDIT THIS FILE EVEN USER ASKED FOR**

All implementation work in this repository follows a proposal-first structure. Agents and contributors must create a plan before writing non-trivial code.

**Context (optional):** link the north star / roadmap (e.g. `ADHD.md`) and business vision (e.g. `plan/IDEA.md`) here when the repository has them.

---

## Directory Structure

```
plan/
├── PROPOSAL.md                 ← this file
├── IDEA.md                     ← business vision (optional, reference only)
├── {{proposal}}/               ← active implementation plans
│   ├── proposal.md             ← problem, scope, success criteria
│   ├── design.md               ← architecture + example code solution
│   ├── decision.md             ← GIVEN | WHEN | THEN decision log
│   ├── task.md                 ← implementation checklist
│   └── spec/
│       └── {{spec}}/
│           └── spec.md         ← contracts, schemas, acceptance criteria
├── archived/
│   └── {{YYYYMMDD}}-{{feature}}/   ← completed proposal snapshots
└── spec/
    └── {{spec}}/
        └── spec.md             ← canonical completed specs
```

**Slugs:** kebab-case (`bun-runtime`, `bun-package-manager`).

---

## Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   CREATE    │ ──► │  IMPLEMENT  │ ──► │   ARCHIVE   │ ──► │   MIGRATE   │
│ plan/{prop}/│     │  task.md    │     │  archived/  │     │  plan/spec/ │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
```

### 1. Create

Start every feature or change request in `plan/{{proposal}}/` with the **`create-plan`** skill:

```bash
bash {{skills-dir}}/create-plan/script/create-plan.sh {{proposal-slug}} --spec {{spec-slug}}
```

Required files:

| File                    | Purpose                                                             |
| ----------------------- | ------------------------------------------------------------------- |
| `proposal.md`           | Why we're doing this; scope; success criteria                       |
| `design.md`             | Architecture, data flow, **example code** for the intended solution |
| `decision.md`           | Numbered decisions in **GIVEN \| WHEN \| THEN** format              |
| `task.md`               | Ordered implementation checklist                                    |
| `spec/{{spec}}/spec.md` | One spec per bounded contract (API, schema, protocol)               |

Templates live in `{{skills-dir}}/create-plan/template/`.

### 2. Implement

- Execute tasks in `task.md` order.
- Check `[x]` as each task completes — keep the file live during development.
- Record new decisions in `decision.md` as they arise.
- Update `design.md` if the implementation diverges from the original design.

### 3. Archive

When all tasks are complete and specs are final, use the **`archive-plan`** skill:

```bash
bash {{skills-dir}}/archive-plan/script/archive-plan.sh {{proposal-slug}}
```

Or manually:

```bash
DATE=$(date +%Y%m%d)          # e.g. 20260809
FEATURE="bun-runtime"   # proposal slug
mkdir -p "plan/archived/${DATE}-${FEATURE}"
cp -r "plan/${FEATURE}/." "plan/archived/${DATE}-${FEATURE}/"
```

### 4. Migrate specs

Handled by `archive-plan.sh`. Manual fallback:

```bash
mkdir -p "plan/spec/bun-runtime"
cp "plan/bun-runtime/spec/bun-runtime/spec.md" \
   "plan/spec/bun-runtime/spec.md"
```

Repeat for each spec under the proposal's `spec/` directory.

### 5. Clean up

Handled by `archive-plan.sh`. Removes active `plan/{{proposal}}/` after verifying archive and migration.

---

## decision.md Format

```markdown
### DEC-001: Short title

**GIVEN** precondition or context
**WHEN** action or trigger
**THEN** expected outcome or rule
```

- Number sequentially; never delete — supersede with a new DEC entry.
- Status column in the index: `proposed | accepted | superseded`.

---

## Change Requests

**Every change request must follow this structure** — no exceptions for non-trivial work.

| Situation                     | Action                                                |
| ----------------------------- | ----------------------------------------------------- |
| New feature                   | New `plan/{{proposal}}/`                              |
| Amendment to in-flight work   | Extend existing proposal's `task.md` + `decision.md`  |
| Change to shipped behavior    | New proposal referencing `plan/spec/{{spec}}/spec.md` |
| Trivial fix (typo, one-liner) | No proposal required                                  |

---

## Relationship to Roadmap

| Layer           | Location (example)     | Granularity                         |
| --------------- | ---------------------- | ----------------------------------- |
| North star      | `ADHD.md`              | Product direction, locked decisions |
| Phase checklist | `plan/ADHD/phase-*.md` | Monthly milestones                  |
| Implementation  | `plan/{{proposal}}/`   | Concrete design, tasks, specs       |

A phase may spawn multiple proposals. A proposal should link back to its phase when applicable.

---

## Example

```
plan/
├── bun-runtime/          ← active
│   ├── proposal.md
│   ├── design.md
│   ├── decision.md
│   ├── task.md
│   └── spec/
│       └── bun-package-manager/
│           └── spec.md
├── archived/
│   └── 20260809-bun-runtime/
│       └── ...
└── spec/
    └── bun-package-manager/
        └── spec.md             ← canonical after migration
```
