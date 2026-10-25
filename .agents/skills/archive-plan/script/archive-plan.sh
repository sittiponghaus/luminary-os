#!/usr/bin/env bash
# Archive a completed proposal: snapshot → migrate specs → remove active folder.
# Usage: archive-plan.sh <proposal-slug> [--dry-run]
#
# Run from anywhere inside the target repository. The plan directory resolves to
# $PLAN_DIR if set, otherwise <git toplevel>/plan, otherwise ./plan. This keeps
# the script working whether the skill is installed per-project (.agents/skills,
# .claude/skills, ...) or globally (~/.config/opencode/skills, ~/.claude/skills).

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN_DIR="${PLAN_DIR:-$ROOT/plan}"
DRY_RUN=false

usage() {
  echo "Usage: archive-plan.sh <proposal-slug> [--dry-run]"
  echo "  Archives plan/<proposal>/ to plan/archived/YYYYMMDD-<proposal>/"
  echo "  Migrates spec/* to plan/spec/ and removes the active proposal folder."
  echo "  Override the plan directory with PLAN_DIR=/path/to/plan."
  exit 1
}

run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

[[ $# -lt 1 ]] && usage

PROPOSAL="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

if [[ ! "$PROPOSAL" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "ERROR: Proposal slug must be kebab-case: $PROPOSAL"
  exit 1
fi

PROPOSAL_DIR="$PLAN_DIR/$PROPOSAL"
TASK_FILE="$PROPOSAL_DIR/task.md"
DATE=$(date +%Y%m%d)
ARCHIVE_DIR="$PLAN_DIR/archived/${DATE}-${PROPOSAL}"

# --- validate proposal exists ---
if [[ ! -d "$PROPOSAL_DIR" ]]; then
  echo "ERROR: Proposal not found: plan/$PROPOSAL/"
  exit 1
fi

# --- validate required files ---
REQUIRED=(proposal.md design.md decision.md task.md)
for f in "${REQUIRED[@]}"; do
  if [[ ! -f "$PROPOSAL_DIR/$f" ]]; then
    echo "ERROR: Missing required file: plan/$PROPOSAL/$f"
    exit 1
  fi
done

# --- validate all tasks complete ---
UNCHECKED=$(grep -cE '^- \[ \]' "$TASK_FILE" 2>/dev/null || true)
if [[ "$UNCHECKED" -gt 0 ]]; then
  echo "ERROR: $UNCHECKED unchecked task(s) in plan/$PROPOSAL/task.md"
  grep -nE '^- \[ \]' "$TASK_FILE" || true
  exit 1
fi

# --- validate at least one task exists ---
if ! grep -qE '^- \[[xX ]\] ' "$TASK_FILE"; then
  echo "ERROR: No tasks found in plan/$PROPOSAL/task.md"
  exit 1
fi

# --- validate specs are final (no **Status:** draft) ---
if [[ -d "$PROPOSAL_DIR/spec" ]]; then
  DRAFTS=$(grep -rlE '^\*\*Status:\*\*[[:space:]]*draft' "$PROPOSAL_DIR/spec" --include=spec.md 2>/dev/null || true)
  if [[ -n "$DRAFTS" ]]; then
    echo "ERROR: Spec(s) still draft — set **Status:** accepted or remove them:"
    echo "$DRAFTS" | sed "s|^$PLAN_DIR/|  plan/|"
    exit 1
  fi
fi

# --- check archive collision ---
if [[ -d "$ARCHIVE_DIR" ]]; then
  echo "ERROR: Archive already exists: plan/archived/${DATE}-${PROPOSAL}/"
  echo "  Use a different date or remove the existing archive."
  exit 1
fi

echo "Proposal:  plan/$PROPOSAL/"
echo "Archive:   plan/archived/${DATE}-${PROPOSAL}/"
echo ""

# --- archive ---
run mkdir -p "$ARCHIVE_DIR"
run cp -r "$PROPOSAL_DIR/." "$ARCHIVE_DIR/"

# --- migrate specs ---
SPEC_SRC="$PROPOSAL_DIR/spec"
if [[ -d "$SPEC_SRC" ]]; then
  shopt -s nullglob
  for spec_dir in "$SPEC_SRC"/*/; do
    spec_slug=$(basename "$spec_dir")
    spec_file="$spec_dir/spec.md"
    if [[ ! -f "$spec_file" ]]; then
      echo "WARN: Skipping spec/$spec_slug/ — no spec.md"
      continue
    fi
    dest_dir="$PLAN_DIR/spec/$spec_slug"
    dest_file="$dest_dir/spec.md"
    if [[ -f "$dest_file" ]]; then
      echo "SYNC:  plan/spec/$spec_slug/spec.md (overwrite with proposal version)"
    else
      echo "MIGRATE: plan/spec/$spec_slug/spec.md (new)"
    fi
    run mkdir -p "$dest_dir"
    run cp "$spec_file" "$dest_file"
  done
  shopt -u nullglob
else
  echo "INFO: No spec/ directory — skipping spec migration"
fi

# --- remove active proposal ---
echo "CLEAN:  removing plan/$PROPOSAL/"
run rm -rf "$PROPOSAL_DIR"

echo ""
echo "Done. Archived to plan/archived/${DATE}-${PROPOSAL}/"
