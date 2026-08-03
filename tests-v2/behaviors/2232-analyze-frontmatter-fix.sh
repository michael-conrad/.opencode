#!/usr/bin/env bash
# RED test for #2232 Phase 1: SC-1, SC-4
# Verify analyze.md checks issue.yaml labels for approved-for-* instead of spec frontmatter approved field
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0
TARGET=".opencode/skills/writing-plans/tasks/analyze.md"

echo "=== RED: SC-1 — analyze.md checks issue.yaml labels for approved-for-* ==="

# SC-1: grep for issue.yaml and approved-for in analyze.md
if grep -q 'issue.yaml' "$TARGET" 2>/dev/null && grep -q 'approved-for' "$TARGET" 2>/dev/null; then
  echo "PASS: analyze.md references issue.yaml and approved-for-*"
else
  echo "FAIL: analyze.md does not reference issue.yaml and approved-for-*"
  OVERALL_RESULT=1
fi

# SC-1: grep for frontmatter.*approved returns zero matches
if grep -q 'frontmatter.*approved' "$TARGET" 2>/dev/null; then
  echo "FAIL: analyze.md still references frontmatter approved field"
  OVERALL_RESULT=1
else
  echo "PASS: analyze.md has no frontmatter approved references"
fi

echo ""
echo "=== RED: SC-4 — analyze.md Entry Criteria and Procedure no longer reference spec frontmatter approved field ==="

# SC-4: grep for 'frontmatter' in analyze.md returns zero matches
if grep -q 'frontmatter' "$TARGET" 2>/dev/null; then
  echo "FAIL: analyze.md still contains 'frontmatter' references"
  OVERALL_RESULT=1
else
  echo "PASS: analyze.md has no 'frontmatter' references"
fi

# SC-4: verify Entry Criteria uses issue.yaml labels, not frontmatter
if grep -q 'issue.yaml.*approved' "$TARGET" 2>/dev/null; then
  echo "PASS: Entry Criteria references issue.yaml for approval check"
else
  echo "FAIL: Entry Criteria does not reference issue.yaml for approval check"
  OVERALL_RESULT=1
fi

echo ""
echo "=== Result ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "ALL PASS"
else
  echo "SOME FAIL"
fi
exit $OVERALL_RESULT
