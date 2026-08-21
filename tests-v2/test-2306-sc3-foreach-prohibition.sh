#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: submodule-sync task card `git submodule foreach`
# prohibition.
# Maps to SC-3 from issue .opencode#2306.
#
# SC-3: The `submodule-sync.md` task card explicitly forbids `git submodule
#       foreach` for the sync operation.
#
# Evidence type: SC-3 is string — read the task card and assert a `foreach`
# prohibition is present.
#
# RED state: The task card (`.opencode/skills/git-workflow-branch/tasks/
# submodule-sync.md`) does NOT explicitly forbid `git submodule foreach` for the
# sync operation. The positive assertions below FAIL at baseline (RED); GREEN
# adds the `foreach` prohibition.
#
# Usage: bash .opencode/tests-v2/test-2306-sc3-foreach-prohibition.sh
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
echo "=== SC-3: submodule-sync task card forbids 'git submodule foreach' for the sync operation (#2306) ==="
echo ""
echo "Target file: $TASK_CARD"
echo ""

# (a) The task card MUST explicitly forbid `git submodule foreach` for the sync
#     operation (never use recursive foreach iteration to sync submodules).
if grep -qi 'forbid.*submodule foreach\|submodule foreach.*forbid\|never.*submodule foreach\|do not.*submodule foreach\|prohibit.*submodule foreach\|submodule foreach.*prohibit' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-3: task card forbids 'git submodule foreach' for the sync operation"
else
    check_fail "SC-3: task card forbids 'git submodule foreach' for the sync operation" \
        "no 'git submodule foreach' prohibition found in $TASK_CARD"
fi

# (b) The task card MUST reference the `git submodule foreach` command itself
#     (the forbidden recursive iteration mechanism), scoped to the sync
#     operation.
if grep -qi 'submodule foreach' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-3: task card references the 'git submodule foreach' command"
else
    check_fail "SC-3: task card references the 'git submodule foreach' command" \
        "'git submodule foreach' not referenced in $TASK_CARD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3 (foreach prohibition) not yet applied."
    echo "$TASK_CARD does not yet forbid 'git submodule foreach' for the sync"
    echo "operation."
    echo ""
    exit 1
fi
exit 0
