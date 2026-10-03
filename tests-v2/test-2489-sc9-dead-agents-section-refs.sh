#!/usr/bin/env bash
# SC-9 (issue 2489): Zero references to nonexistent AGENTS.md sections remain.
# Dead-target patterns (spec closed list):
#   1. §Tag Layers / link-form [Tag Layers](AGENTS.md) — section absent from .opencode/AGENTS.md
#   2. §Tag-Based Hash Permanence / link-form — section absent from .opencode/AGENTS.md
#   3. §Idempotent Tag-if-Untagged — section absent from .opencode/AGENTS.md
#   4. Read [Skipping Git Pre-Check](guidelines/000-critical-rules.md) — section absent there
#   5. Relative-path ref to enforcement/halt-conditions.md — correct live target is
#      .opencode/skills/git-workflow/enforcement/halt-conditions.md (referenced dir does not exist)
# Excludes: .opencode/.issues/ and tmp/
# RED expectation: FAIL (non-zero) while dead references still exist.
# Exit 0 = PASS (zero matches). Exit 1 = FAIL (matches found).

set -u
cd "$(dirname "$0")/../.." || exit 2

failures=0
total=0

report() {
  local label="$1" pattern="$2" invert="${3:-}"
  total=$((total + 1))
  local matches
  matches=$(grep -rEn --include='*.md' --exclude-dir='.issues' --exclude-dir='tmp' --exclude-dir='.git' "$pattern" . 2>/dev/null)
  if [ -n "$invert" ]; then
    matches=$(echo "$matches" | grep -v "$invert" || true)
  fi
  if [ -n "$matches" ]; then
    failures=$((failures + 1))
    echo "DEAD-REF [$label] pattern: $pattern"
    echo "$matches" | sed 's/^/  /'
    echo "  count: $(echo "$matches" | wc -l)"
  else
    echo "OK [$label] no matches: $pattern"
  fi
}

report "Tag Layers"                 '§Tag Layers|\[Tag Layers\]\(AGENTS\.md'
report "Tag-Based Hash Permanence"  '§Tag-Based Hash Permanence|\[Tag-Based Hash Permanence\]\(AGENTS\.md'
report "Idempotent Tag-if-Untagged" '§Idempotent Tag-if-Untagged'
report "Skipping Git Pre-Check -> 000-critical-rules" 'Skipping Git Pre-Check\]\(guidelines/000-critical-rules\.md'
report "relative halt-conditions path" 'enforcement/halt-conditions\.md' 'skills/git-workflow/enforcement/halt-conditions'

echo "---"
echo "SC-9 RED result: $failures dead-reference pattern group(s) with matches out of $total"
[ "$failures" -eq 0 ] && exit 0 || exit 1
