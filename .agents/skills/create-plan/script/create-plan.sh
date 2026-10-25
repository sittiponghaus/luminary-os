#!/usr/bin/env bash
# Scaffold a new proposal: plan/<proposal>/{proposal,design,decision,task}.md
# plus plan/<proposal>/spec/<spec>/spec.md for each --spec.
# Usage: create-plan.sh <proposal-slug> [--title "Title"] [--spec <spec-slug>]... [--dry-run]
#
# Runs init-plan.sh first when plan/PROPOSAL.md is missing. Refuses slugs that
# are not kebab-case or already exist in plan/ or plan/archived/.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../template"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
export PLAN_DIR="${PLAN_DIR:-$ROOT/plan}"
SLUG_PATTERN='^[a-z0-9]+(-[a-z0-9]+)*$'
RESERVED=(archived spec)
DRY_RUN=false
TITLE=""
SPECS=()

usage() {
  echo "Usage: create-plan.sh <proposal-slug> [--title \"Title\"] [--spec <spec-slug>]... [--dry-run]"
  echo "  Creates plan/<proposal>/ with proposal.md, design.md, decision.md, task.md"
  echo "  and spec/<spec>/spec.md for each --spec. Initializes plan/ if needed."
  exit 1
}

[[ $# -lt 1 ]] && usage
PROPOSAL="$1"
shift
[[ "$PROPOSAL" == "-h" || "$PROPOSAL" == "--help" ]] && usage

while [[ $# -gt 0 ]]; do
  case "$1" in
    --title) [[ $# -ge 2 ]] || usage; TITLE="$2"; shift ;;
    --spec) [[ $# -ge 2 ]] || usage; SPECS+=("$2"); shift ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

if [[ ! "$PROPOSAL" =~ $SLUG_PATTERN ]]; then
  echo "ERROR: Proposal slug must be kebab-case: $PROPOSAL"
  exit 1
fi
for reserved in "${RESERVED[@]}"; do
  if [[ "$PROPOSAL" == "$reserved" ]]; then
    echo "ERROR: '$PROPOSAL' is reserved (plan/$reserved/ is a registry)"
    exit 1
  fi
done
seen=" "
for spec in "${SPECS[@]+"${SPECS[@]}"}"; do
  if [[ ! "$spec" =~ $SLUG_PATTERN ]]; then
    echo "ERROR: Spec slug must be kebab-case: $spec"
    exit 1
  fi
  if [[ "$seen" == *" $spec "* ]]; then
    echo "ERROR: Duplicate --spec: $spec"
    exit 1
  fi
  seen+="$spec "
done

PROPOSAL_DIR="$PLAN_DIR/$PROPOSAL"
if [[ -e "$PROPOSAL_DIR" ]]; then
  echo "ERROR: Proposal already exists: plan/$PROPOSAL/"
  exit 1
fi
shopt -s nullglob
archived=("$PLAN_DIR"/archived/*-"$PROPOSAL")
shopt -u nullglob
if [[ ${#archived[@]} -gt 0 ]]; then
  echo "ERROR: Slug already used by an archived proposal: ${archived[0]#"$PLAN_DIR"/}"
  echo "  Pick a new slug (e.g. $PROPOSAL-v2) or reference the archive from the new proposal."
  exit 1
fi

if [[ -z "$TITLE" ]]; then
  TITLE="$(echo "$PROPOSAL" | tr '-' ' ' | awk '{for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2)} 1')"
fi

if [[ ! -f "$PLAN_DIR/PROPOSAL.md" || ! -d "$PLAN_DIR/archived" || ! -d "$PLAN_DIR/spec" ]]; then
  init_args=()
  [[ "$DRY_RUN" == true ]] && init_args+=(--dry-run)
  bash "$SCRIPT_DIR/init-plan.sh" "${init_args[@]+"${init_args[@]}"}"
  echo ""
fi

# Fill {{Title}}, {{proposal-slug}} and (for specs) {{spec-slug}} / {{Spec Title}}.
# Other {{placeholders}} are left for the author.
render() {
  local template="$1" dest="$2" spec="${3:-}" spec_title="${4:-}"
  echo "CREATE:  ${dest#"$PLAN_DIR"/}"
  [[ "$DRY_RUN" == true ]] && return
  mkdir -p "$(dirname "$dest")"
  TITLE="$TITLE" PROPOSAL="$PROPOSAL" SPEC="$spec" SPEC_TITLE="$spec_title" SPEC_LIST="${SPECS[*]+"${SPECS[*]}"}" awk '
    # Literal (non-regex) replacement: user text may contain & or \.
    function replace(line, token, value,    out, i) {
      out = ""
      while ((i = index(line, token)) > 0) {
        out = out substr(line, 1, i - 1) value
        line = substr(line, i + length(token))
      }
      return out line
    }
    # proposal.md: expand the placeholder Specs row into one row per --spec.
    ENVIRON["SPEC"] == "" && ENVIRON["SPEC_LIST"] != "" && index($0, "| {{spec-slug}} |") == 1 {
      n = split(ENVIRON["SPEC_LIST"], list, " ")
      for (i = 1; i <= n; i++) printf "| %s | `spec/%s/spec.md` | {{one line}} |\n", list[i], list[i]
      next
    }
    {
      $0 = replace($0, "{{Title}}", ENVIRON["TITLE"])
      $0 = replace($0, "{{proposal-slug}}", ENVIRON["PROPOSAL"])
      if (ENVIRON["SPEC"] != "") {
        $0 = replace($0, "{{spec-slug}}", ENVIRON["SPEC"])
        $0 = replace($0, "{{Spec Title}}", ENVIRON["SPEC_TITLE"])
      }
      print
    }' "$TEMPLATE_DIR/$template" > "$dest"
}

for file in proposal design decision task; do
  render "$file.md" "$PROPOSAL_DIR/$file.md"
done

for spec in "${SPECS[@]+"${SPECS[@]}"}"; do
  spec_title="$(echo "$spec" | tr '-' ' ' | awk '{for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2)} 1')"
  render spec.md "$PROPOSAL_DIR/spec/$spec/spec.md" "$spec" "$spec_title"
done

echo ""
echo "Done. Fill the {{placeholders}} in ${PROPOSAL_DIR#"$ROOT"/}/ before implementing."
