#!/usr/bin/env bash
# Create RULES.md from the template (idempotent, never overwrites).
# Usage: init-rules.sh [--dry-run]
#
# The file resolves to $RULES_FILE if set, otherwise <git toplevel>/RULES.md,
# otherwise ./RULES.md. An existing RULES.md is repository-owned and is left
# untouched. AGENTS.md is never edited; the lines to add are printed instead.

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$SKILL_DIR/template/RULES.md"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
RULES_FILE="${RULES_FILE:-$ROOT/RULES.md}"
DRY_RUN=false

usage() {
  echo "Usage: init-rules.sh [--dry-run]"
  echo "  Creates RULES.md from the project-rules template if it is missing."
  echo "  Never overwrites an existing RULES.md."
  echo "  Override the file with RULES_FILE=/path/to/RULES.md."
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

if [[ ! -f "$TEMPLATE" ]]; then
  echo "ERROR: Template not found: $TEMPLATE"
  exit 1
fi

name="${RULES_FILE#"$ROOT"/}"
if [[ -f "$RULES_FILE" ]]; then
  echo "KEEP:    $name (repository-owned, not modified)"
else
  echo "CREATE:  $name"
  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry-run] cp $TEMPLATE $RULES_FILE"
  else
    mkdir -p "$(dirname "$RULES_FILE")"
    cp "$TEMPLATE" "$RULES_FILE"
  fi
fi

AGENTS_FILE="$ROOT/AGENTS.md"
if [[ ! -f "$AGENTS_FILE" ]] || ! grep -q 'RULES\.md' "$AGENTS_FILE"; then
  echo ""
  echo "AGENTS.md does not reference RULES.md. Ask the owner to add:"
  echo "- **ALWAYS** read [RULES.md](./RULES.md) before planning solution."
  echo "- **ALWAYS** document crucial implementation detail in [RULES.md](./RULES.md) with proper link to spec in \`plan/\` folder."
fi
