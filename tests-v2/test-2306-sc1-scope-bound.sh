#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: submodule-sync task card scope-bound statement.
# Maps to SC-1 from issue .opencode#2306.
#
# SC-1: The `submodule-sync.md` task card explicitly bounds scope to the parent
#       repo's direct submodule pointers passed in `submodule_paths`.
#
# Evidence type: SC-1 is string — read the task card and assert a scope-bound
# statement referencing `submodule_paths` and direct pointers is present.
#
# RED state: The task card (`.opencode/skills/git-workflow-branch/tasks/
# submodule-sync.md`) currently does NOT reference `submodule_paths` or bound its
# scope to the parent repo's direct submodule pointers. The positive assertions
# below FAIL at baseline (RED); GREEN adds the scope-bound statement.
#
# Usage: bash .opencode/tests-v2/test-2306-sc1-scope-bound.sh
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
echo "=== SC-1: submodule-sync task card bounds scope to submodule_paths/direct pointers (#2306) ==="
echo ""
echo "Target file: $TASK_CARD"
echo ""

# (a) The task card MUST reference `submodule_paths` (the scope source passed by
#     the orchestrator).
if grep -q 'submodule_paths' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-1: task card references 'submodule_paths'"
else
    check_fail "SC-1: task card references 'submodule_paths'" \
        "'submodule_paths' not found in $TASK_CARD"
fi

# (b) The task card MUST bound its scope to the parent repo's direct submodule
#     pointers (not nested/recursive).
if grep -qi 'direct submodule pointer\|direct pointers\|direct paths' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-1: task card bounds scope to parent repo direct submodule pointers"
else
    check_fail "SC-1: task card bounds scope to parent repo direct submodule pointers" \
        "no direct-pointer scope-bound statement found in $TASK_CARD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (scope-bound statement) not yet applied."
    echo "$TASK_CARD does not yet bound its scope to the parent repo's direct"
    echo "submodule pointers passed in submodule_paths."
    echo ""
    exit 1
fi
exit 0
