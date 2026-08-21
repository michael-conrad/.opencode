#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: submodule-sync task card recursion prohibition.
# Maps to SC-2 from issue .opencode#2306.
#
# SC-2: The `submodule-sync.md` task card explicitly forbids recursion into
#       nested submodules.
#
# Evidence type: SC-2 is string — read the task card and assert a recursion
# prohibition is present.
#
# RED state: The task card (`.opencode/skills/git-workflow-branch/tasks/
# submodule-sync.md`) does NOT explicitly forbid recursion into nested
# submodules. The positive assertions below FAIL at baseline (RED); GREEN adds
# the recursion prohibition.
#
# Usage: bash .opencode/tests-v2/test-2306-sc2-recursion-prohibition.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

TASK_CARD="$PROJECT_DIR/skills/git-workflow-branch/tasks/submodule-sync.md"

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
echo "=== SC-2: submodule-sync task card forbids recursion into nested submodules (#2306) ==="
echo ""
echo "Target file: $TASK_CARD"
echo ""

# (a) The task card MUST explicitly forbid recursion into nested submodules.
if grep -qi 'never recurse\|no recursion\|do not recurse\|forbid.*recurs\|recursion is forbidden' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-2: task card forbids recursion into nested submodules"
else
    check_fail "SC-2: task card forbids recursion into nested submodules" \
        "no recursion prohibition found in $TASK_CARD"
fi

# (b) The task card MUST scope the no-recursion constraint to the direct
#     submodule paths in `submodule_paths` (the scope source passed by the
#     orchestrator).
if grep -qi 'direct submodule path\|nested submodule' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-2: task card scopes recursion prohibition to direct/nested submodule paths"
else
    check_fail "SC-2: task card scopes recursion prohibition to direct/nested submodule paths" \
        "no direct/nested submodule scope reference found in $TASK_CARD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-2 (recursion prohibition) not yet applied."
    echo "$TASK_CARD does not yet forbid recursion into nested submodules."
    echo ""
    exit 1
fi
exit 0
