#!/bin/bash
# Content-verification test: no sub-issue closure readiness gate in operating-protocol
# Maps to SC-2 from issue #2283: .opencode/skills/finishing-a-development-branch/tasks/operating-protocol.md
# MUST NOT require "Plan sub-issue closure verification" or "Plan sub-issues verified"
# as a readiness gate.
#
# RED phase: the sub-issue closure readiness gate IS present — this test FAILS.
# GREEN phase: after the gate is removed, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2283-sc2-no-subissue-closure-gate.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== Branch-Finishing No-Sub-Issue-Closure-Gate -- SC-2 (#2283) ==="
echo ""

OP_FILE="$PROJECT_DIR/.opencode/skills/finishing-a-development-branch/tasks/operating-protocol.md"

# SC-2: no "Plan sub-issue closure verification" readiness gate
if grep -q "Plan sub-issue closure verification" "$OP_FILE" 2>/dev/null; then
    check_fail "SC-2: no 'Plan sub-issue closure verification' readiness gate in operating-protocol.md" "readiness gate still present"
else
    check_pass "SC-2: no 'Plan sub-issue closure verification' readiness gate in operating-protocol.md"
fi

# SC-2: no "Plan sub-issues verified" exit criterion
if grep -q "Plan sub-issues verified" "$OP_FILE" 2>/dev/null; then
    check_fail "SC-2: no 'Plan sub-issues verified' exit criterion in operating-protocol.md" "exit criterion still present"
else
    check_pass "SC-2: no 'Plan sub-issues verified' exit criterion in operating-protocol.md"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
