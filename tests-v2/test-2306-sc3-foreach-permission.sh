#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: submodule-sync task card permits non-recursive
# `git submodule foreach` and forbids `--recursive`.
# Maps to SC-3 from issue .opencode#2306.
#
# SC-3: The `submodule-sync.md` task card permits explicit per-submodule
#       operations including non-recursive `git submodule foreach`, while
#       forbidding `--recursive` with any git submodule command.
#
# Evidence type: SC-3 is string — read the task card and assert the permission
# for non-recursive foreach and the no-`--recursive` constraint.
#
# RED state (expected before GREEN): The task card either forbids `git submodule
# foreach` entirely or does not explicitly permit it. The positive assertions
# below FAIL at baseline (RED); GREEN adds the permission for non-recursive
# foreach and the verbatim no-`--recursive` constraint.
#
# Usage: bash .opencode/tests-v2/test-2306-sc3-foreach-permission.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (nemotron-3-ultra-free)

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
echo "=== SC-3: submodule-sync task card permits non-recursive foreach, forbids --recursive (#2306) ==="
echo ""
echo "Target file: $TASK_CARD"
echo ""

# (a) The task card MUST explicitly permit non-recursive `git submodule foreach`
#     as an explicit per-submodule operation.
if grep -qi 'permit.*non-recursive.*submodule foreach\|explicit per-submodule.*foreach\|permit.*submodule foreach.*non-recursive' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-3: task card permits non-recursive 'git submodule foreach' as explicit per-submodule operation"
else
    check_fail "SC-3: task card permits non-recursive 'git submodule foreach' as explicit per-submodule operation" \
        "no permission for non-recursive 'git submodule foreach' found in $TASK_CARD"
fi

# (b) The task card MUST reference `git submodule foreach` in the context of
#     permission for non-recursive use.
if grep -qi 'submodule foreach' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-3: task card references 'git submodule foreach' in permission context"
else
    check_fail "SC-3: task card references 'git submodule foreach' in permission context" \
        "'git submodule foreach' not referenced in $TASK_CARD"
fi

# (c) The task card MUST explicitly forbid `--recursive` with any git submodule
#     command (verbatim mirror of 060-tool-usage.md §4).
# Use a variable to avoid shell evaluation of backticks
forbidden_pattern='NEVER use `--recursive` with any git submodule command'
if grep -q "$forbidden_pattern" "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-3: task card forbids --recursive verbatim per 060-tool-usage.md §4"
else
    check_fail "SC-3: task card forbids --recursive verbatim per 060-tool-usage.md §4" \
        "verbatim no-\`--recursive\` constraint not found in $TASK_CARD"
fi

# (d) The task card must NOT contain a blanket prohibition of `git submodule foreach`
# Only match explicit forbid/prohibit of foreach for the sync operation
if grep -qi 'forbid.*submodule foreach.*sync\|submodule foreach.*forbid.*sync\|prohibit.*submodule foreach.*sync\|submodule foreach.*prohibit.*sync\|forbid.*foreach.*operation\|foreach.*operation.*forbid' "$TASK_CARD" 2>/dev/null; then
    check_fail "SC-3: task card must NOT contain blanket 'git submodule foreach' prohibition" \
        "blanket prohibition of 'git submodule foreach' found in $TASK_CARD"
else
    check_pass "SC-3: task card does NOT contain blanket 'git submodule foreach' prohibition"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3 (foreach permission + no-`--recursive` constraint) not yet applied."
    exit 1
fi
exit 0