#!/usr/bin/env bash
# Audit RULES.md: title, broken relative links, sections without a plan/ link,
# leftover {{placeholders}}.
# Usage: check-rules.sh [--strict]
#
# The file resolves to $RULES_FILE if set, otherwise <git toplevel>/RULES.md,
# otherwise ./RULES.md. Exit 1 on any error (or any warning with --strict).

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
RULES_FILE="${RULES_FILE:-$ROOT/RULES.md}"
STRICT=false

usage() {
  echo "Usage: check-rules.sh [--strict]"
  echo "  Errors: missing file, missing '# ' title, relative link to a missing file."
  echo "  Warnings (errors with --strict): '## ' section without a plan/ link, {{placeholder}}."
  echo "  Override the file with RULES_FILE=/path/to/RULES.md."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --strict) STRICT=true ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

if [[ ! -f "$RULES_FILE" ]]; then
  echo "ERROR: RULES.md not found: $RULES_FILE"
  echo "  Create it with init-rules.sh."
  exit 1
fi

BASE_DIR="$(cd "$(dirname "$RULES_FILE")" && pwd)"

# Emit one record per finding: KIND<TAB>LINE<TAB>DETAIL. Fenced and inline code
# are ignored.
findings="$(awk '
  function flush() {
    if (section != "" && !linked) printf "UNLINKED\t%d\t%s\n", section_line, section
  }
  /^(```|~~~)/ { fenced = !fenced; next }
  fenced { next }
  /^# / { titled = 1 }
  /^## / { flush(); section = substr($0, 4); section_line = NR; linked = 0 }
  {
    # Inline code documents syntax; it is never a placeholder or a link.
    line = $0
    gsub(/`[^`]*`/, "", line)
    if (line ~ /\{\{[^}]*\}\}/) printf "PLACEHOLDER\t%d\t%s\n", NR, $0
    while (match(line, /\]\([^)]*\)/)) {
      target = substr(line, RSTART + 2, RLENGTH - 3)
      line = substr(line, RSTART + RLENGTH)
      sub(/[ \t]+".*$/, "", target)
      if (target ~ /(^|\/)plan\//) linked = 1
      if (target ~ /^[a-zA-Z][a-zA-Z0-9+.-]*:/ || target ~ /^#/ || target == "") continue
      sub(/#.*$/, "", target)
      if (target ~ /\{\{/) continue
      printf "LINK\t%d\t%s\n", NR, target
    }
  }
  END {
    flush()
    if (!titled) print "UNTITLED\t1\t"
  }
' "$RULES_FILE")"

errors=0
warnings=0
name="${RULES_FILE#"$ROOT"/}"

while IFS=$'\t' read -r kind line detail; do
  [[ -z "$kind" ]] && continue
  case "$kind" in
    UNTITLED)
      echo "ERROR:   $name has no '# ' title"
      errors=$((errors + 1)) ;;
    LINK)
      if [[ "$detail" == /* ]]; then path="$ROOT$detail"; else path="$BASE_DIR/$detail"; fi
      if [[ ! -e "$path" ]]; then
        echo "ERROR:   $name:$line broken link: $detail"
        errors=$((errors + 1))
      fi ;;
    UNLINKED)
      echo "WARN:    $name:$line section '$detail' has no plan/ spec link"
      warnings=$((warnings + 1)) ;;
    PLACEHOLDER)
      echo "WARN:    $name:$line unfilled placeholder: $detail"
      warnings=$((warnings + 1)) ;;
  esac
done <<< "$findings"

echo ""
echo "$name: $errors error(s), $warnings warning(s)"
if [[ "$errors" -gt 0 ]] || { [[ "$STRICT" == true ]] && [[ "$warnings" -gt 0 ]]; }; then
  exit 1
fi
