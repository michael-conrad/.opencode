#!/bin/bash
# RED phase: content-verification test for SC-4 (Worktree Mode sections)
# Verifies that most SKILL.md files are missing "Worktree Mode" sections
# This test MUST FAIL now (RED) and PASS after GREEN implementation
#
# SC-4: grep -c "Worktree Mode" across all SKILL.md files returns < 30
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"

OVERALL_RESULT=0

echo "=== RED Phase: SC-4 Worktree Mode Section Coverage ==="
echo "Verifying that most SKILL.md files are missing 'Worktree Mode' sections"
echo ""

# SC-4: Count Worktree Mode occurrences across all SKILL.md files
RAW=$(grep -c 'Worktree Mode' "$PROJECT_DIR/.opencode/skills/"*/SKILL.md "$PROJECT_DIR/.opencode/skills/issue-operations/platforms/"*/SKILL.md 2>/dev/null || true)
SUM=0
while IFS=: read -r file count; do
    if [ -n "$count" ]; then
        SUM=$((SUM + count))
    fi
done <<< "$RAW"

echo "  Total 'Worktree Mode' occurrences: $SUM"
echo "  Expected (GREEN target): >= 30"
echo ""

# SC-4: Assert count is >= 30 (GREEN target) — will FAIL in RED state
if [ "$SUM" -ge 30 ]; then
    echo "  PASS: $SUM occurrences found — Worktree Mode sections are sufficiently present"
else
    echo "  FAIL: Only $SUM occurrences found (expected >= 30) — RED state confirmed"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "=== RESULT: ALL PASS — GREEN confirmed ==="
else
    echo "=== RESULT: FAIL — RED confirmed (Worktree Mode sections not yet implemented) ==="
fi

exit $OVERALL_RESULT
