#!/bin/bash
# Content-verification test: immediate-abort-with-zero-further-analysis and
# orchestrator-only-remediation statements absent from red.md and green.md
# Maps to SC-12 from issue #2298: .opencode/skills/test-driven-development/tasks/red.md
# and green.md must each contain (1) the immediate-abort-with-zero-further-analysis
# normative statement (a sub-agent detecting a BLOCK condition SHALL immediately return a
# classified abort with no additional reading, analysis, remediation, or re-evaluation after
# detecting the block) and (2) the orchestrator-only-remediation statement (remediation is
# exclusively the orchestrator's responsibility — the orchestrator tasks new sub-agents with
# the needed remediation tasks; the aborting sub-agent does not remediate).
#
# RED phase (Item 12): assert both statements are ABSENT from
# .opencode/skills/test-driven-development/tasks/red.md and green.md. The test passes while
# they are absent (baseline). GREEN phase adds them; this test then FAILS, confirming the
# addition, and the GREEN verify asserts they are PRESENT.
#
# red.md and green.md are regular tracked files in the .opencode repo (not the .issues/
# worktree), so they are read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2298-sc12-immediate-abort-orchestrator-remediation-absent.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== red.md/green.md immediate-abort-with-zero-further-analysis + orchestrator-only-remediation -- SC-12 (#2298) ==="
echo ""

RED_MD="$PROJECT_DIR/skills/test-driven-development/tasks/red.md"
GREEN_MD="$PROJECT_DIR/skills/test-driven-development/tasks/green.md"

# SC-12 (RED phase): the immediate-abort-with-zero-further-analysis normative statement
# (a sub-agent detecting a BLOCK condition SHALL immediately return a classified abort with
# no additional reading, analysis, remediation, or re-evaluation after detecting the block)
# must be ABSENT from red.md and green.md before the change. After GREEN adds it, this FAILS.
for FILE in "$RED_MD" "$GREEN_MD"; do
    FILE_NAME="$(basename "$FILE")"
    if grep -q 'immediately return a classified abort' "$FILE" 2>/dev/null \
        || grep -q 'zero further analysis' "$FILE" 2>/dev/null \
        || grep -q 'no additional reading' "$FILE" 2>/dev/null; then
        check_fail "SC-12: immediate-abort-with-zero-further-analysis ABSENT in .opencode/skills/test-driven-development/tasks/$FILE_NAME" \
            "immediate-abort-with-zero-further-analysis statement already added (GREEN applied)"
    else
        check_pass "SC-12: immediate-abort-with-zero-further-analysis ABSENT in .opencode/skills/test-driven-development/tasks/$FILE_NAME"
    fi
done

# SC-12 (RED phase): the orchestrator-only-remediation statement (remediation is exclusively
# the orchestrator's responsibility — the orchestrator tasks new sub-agents with the needed
# remediation tasks; the aborting sub-agent does not remediate) must be ABSENT from red.md
# and green.md before the change. After GREEN adds it, this FAILS.
for FILE in "$RED_MD" "$GREEN_MD"; do
    FILE_NAME="$(basename "$FILE")"
    if grep -q 'exclusively the orchestrator' "$FILE" 2>/dev/null \
        || grep -q 'orchestrator.s responsibility' "$FILE" 2>/dev/null \
        || grep -q 'does not remediate' "$FILE" 2>/dev/null; then
        check_fail "SC-12: orchestrator-only-remediation ABSENT in .opencode/skills/test-driven-development/tasks/$FILE_NAME" \
            "orchestrator-only-remediation statement already added (GREEN applied)"
    else
        check_pass "SC-12: orchestrator-only-remediation ABSENT in .opencode/skills/test-driven-development/tasks/$FILE_NAME"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
