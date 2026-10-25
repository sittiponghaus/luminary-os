#!/usr/bin/env bash
# Scaffold the repository plan/ structure (idempotent, never overwrites).
# Usage: init-plan.sh [--dry-run]
#
# Creates plan/PROPOSAL.md (workflow), plan/archived/ and plan/spec/. The plan
# directory resolves to $PLAN_DIR if set, otherwise <git toplevel>/plan,
# otherwise ./plan. An existing PROPOSAL.md is repository-owned and is left
# untouched.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE_DIR="$SKILL_DIR/template"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
PLAN_DIR="${PLAN_DIR:-$ROOT/plan}"
DRY_RUN=false

usage() {
  echo "Usage: init-plan.sh [--dry-run]"
  echo "  Creates plan/PROPOSAL.md, plan/archived/ and plan/spec/ if missing."
  echo "  Never overwrites an existing plan/PROPOSAL.md."
  echo "  Override the plan directory with PLAN_DIR=/path/to/plan."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

run() {
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

if [[ ! -f "$TEMPLATE_DIR/PROPOSAL.md" ]]; then
  echo "ERROR: Template not found: $TEMPLATE_DIR/PROPOSAL.md"
  exit 1
fi

run mkdir -p "$PLAN_DIR"

if [[ -f "$PLAN_DIR/PROPOSAL.md" ]]; then
  echo "KEEP:    plan/PROPOSAL.md (repository-owned, not modified)"
else
  echo "CREATE:  plan/PROPOSAL.md"
  run cp "$TEMPLATE_DIR/PROPOSAL.md" "$PLAN_DIR/PROPOSAL.md"
fi

for dir in archived spec; do
  if [[ -d "$PLAN_DIR/$dir" ]]; then
    echo "KEEP:    plan/$dir/"
  else
    echo "CREATE:  plan/$dir/"
    run mkdir -p "$PLAN_DIR/$dir"
  fi
  # Keep empty registries in git until the first archive lands.
  if [[ "$DRY_RUN" == false ]] && [[ -z "$(ls -A "$PLAN_DIR/$dir")" ]]; then
    touch "$PLAN_DIR/$dir/.gitkeep"
  fi
done

echo ""
echo "Plan structure ready at ${PLAN_DIR#"$ROOT"/}/"
