---
name: archive-plan
description: Archives completed implementation plans and syncs specs to plan/spec/. Use when a proposal is finished, all task.md items are checked, the user asks to archive or close a plan, or after merging implemented work.
---

# Archive Plan

Completes the proposal lifecycle: validate → snapshot → migrate specs → remove active folder.

Pairs with **`create-plan`**. If the repository has `plan/PROPOSAL.md`, read it first — it overrides this skill where they differ.

## When to Use

- All `task.md` items are `[x]`
- Implementation merged or verified locally
- User says "archive plan", "close proposal", "sync specs", or "plan is done"
- Before starting a new proposal that supersedes an old one

Do **not** archive if tasks remain unchecked or specs are still draft.

## Quick Run

The script ships with this skill at `script/archive-plan.sh` (relative to this `SKILL.md`). Run it from anywhere inside the target repository — it resolves `plan/` from the git top-level directory (override with `PLAN_DIR=/path/to/plan`).

```bash
bash <this skill dir>/script/archive-plan.sh <proposal-slug>
# project install example:
bash .agents/skills/archive-plan/script/archive-plan.sh <proposal-slug>
```

Dry run (validate only, no writes):

```bash
bash <this skill dir>/script/archive-plan.sh <proposal-slug> --dry-run
```

Always invoke it through `bash`: skill installers do not reliably preserve the executable bit.

## Manual Workflow

Use the script above when possible. Manual steps if needed:

### 1. Pre-flight

```bash
PROPOSAL="hardware-passport"
grep -cE '^- \[ \]' "plan/$PROPOSAL/task.md"   # must be 0
ls plan/$PROPOSAL/{proposal,design,decision,task}.md  # all must exist
```

| Check | Pass condition |
| --- | --- |
| Proposal exists | `plan/{{proposal}}/` is a directory |
| Required files | `proposal.md`, `design.md`, `decision.md`, `task.md` present |
| Tasks complete | Zero `- [ ]` lines in `task.md` |
| Specs final | No `spec/*/spec.md` has `**Status:** draft` (the script enforces this) |
| No archive collision | `plan/archived/{{YYYYMMDD}}-{{proposal}}/` does not exist |

### 2. Archive snapshot

```bash
DATE=$(date +%Y%m%d)
FEATURE="{{proposal}}"
mkdir -p "plan/archived/${DATE}-${FEATURE}"
cp -r "plan/${FEATURE}/." "plan/archived/${DATE}-${FEATURE}/"
```

### 3. Sync specs to canonical registry

For each `plan/{{proposal}}/spec/{{spec}}/spec.md`:

```bash
mkdir -p "plan/spec/{{spec}}"
cp "plan/{{proposal}}/spec/{{spec}}/spec.md" "plan/spec/{{spec}}/spec.md"
```

**Sync rules:**

| Situation | Action |
| --- | --- |
| `plan/spec/{{spec}}/spec.md` missing | Create (migrate) |
| Already exists | Overwrite with proposal version — proposal is source of truth at archive time |
| Spec amended later | New proposal required; archive that proposal to update canonical spec |

### 4. Clean up

```bash
rm -rf "plan/{{proposal}}/"
```

### 5. Post-archive

- [ ] Verify `plan/archived/{{YYYYMMDD}}-{{proposal}}/` contains full snapshot
- [ ] Verify each spec landed in `plan/spec/{{spec}}/spec.md`
- [ ] Update linked phase/roadmap checklist if applicable
- [ ] Record crucial decisions in `RULES.md` linking the synced spec (see the `project-rules` skill)
- [ ] Reference archive path in PR/MR description if archiving as part of merge

## Spec Status Before Archive

Set each proposal spec to accepted in the header:

```markdown
**Status:** accepted
```

If a spec is still `draft`, finish it or remove it from `spec/` before archiving.

## Edge Cases

| Case | Resolution |
| --- | --- |
| Partial completion | Do not archive — leave proposal active, or split remaining work into a new proposal |
| Same-day re-archive | Script fails on collision; append suffix manually (`20260809a-feature`) only if intentional |
| No specs directory | Archive proceeds; only snapshot is created |
| Superseding a shipped spec | Archive the amending proposal; overwrite `plan/spec/{{spec}}/spec.md` |

## Agent Checklist

```
- [ ] Confirmed all task.md items are [x]
- [ ] Ran archive-plan.sh (or manual steps) successfully
- [ ] plan/archived/{{YYYYMMDD}}-{{proposal}}/ exists with full copy
- [ ] plan/spec/{{spec}}/spec.md synced for each spec
- [ ] plan/{{proposal}}/ removed
- [ ] Phase checklist updated if linked
```

## Additional Resources

- Create proposals: `create-plan` skill
- Repository workflow (if present): `plan/PROPOSAL.md`
- Repository agent guidelines (if present): `AGENTS.md`
