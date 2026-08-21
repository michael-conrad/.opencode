#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: submodule-sync task card mirrors the standing
# no-`--recursive` guideline from `060-tool-usage.md` §4.
# Maps to SC-4 from issue .opencode#2306.
#
# SC-4: The `submodule-sync.md` task card mirrors the standing no-`--recursive`
#       guideline from `060-tool-usage.md` §4.
#
# Evidence type: SC-4 is string — read the task card and assert a no-`--recursive`
# constraint consistent with the guideline wording is present.
#
# RED state: The task card (`.opencode/skills/git-workflow-branch/tasks/
# submodule-sync.md`) currently does NOT mirror the no-`--recursive` constraint
# from `060-tool-usage.md` §4. The positive assertions below FAIL at baseline
# (RED); GREEN adds the no-`--recursive` constraint.
#
# Usage: bash .opencode/tests-v2/test-2306-sc4-no-recursive-mirror.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

TASK_CARD="$PROJECT_DIR/skills/git-workflow-branch/tasks/submodule-sync.md"
GUIDELINE="$PROJECT_DIR/guidelines/060-tool-usage.md"

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
echo "=== SC-4: submodule-sync task card mirrors the no-'--recursive' guideline (#2306) ==="
echo ""
echo "Target file: $TASK_CARD"
echo "Guideline:   $GUIDELINE"
echo ""

# (a) The task card MUST reference the `--recursive` flag (the forbidden flag),
#     mirroring the guideline's no-`--recursive` constraint.
if grep -q -- '--recursive' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-4: task card references the '--recursive' flag"
else
    check_fail "SC-4: task card references the '--recursive' flag" \
        "'--recursive' not found in $TASK_CARD"
fi

# (b) The task card MUST forbid the use of `--recursive` with git submodule
#     commands, mirroring the guideline's "NEVER use `--recursive` with any git
#     submodule command" constraint.
if grep -qi 'never.*--recursive\|--recursive.*never\|do not.*--recursive\|--recursive.*do not\|forbid.*--recursive\|--recursive.*forbid\|without.*--recursive\|--recursive.*without' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-4: task card forbids '--recursive' with git submodule commands"
else
    check_fail "SC-4: task card forbids '--recursive' with git submodule commands" \
        "no no-'--recursive' constraint found in $TASK_CARD"
fi

# (c) The task card MUST direct explicit per-submodule operations instead of
#     `--recursive` iteration, consistent with the guideline's "Always use
#     `git submodule update --init` (without `--recursive`) or explicit
#     per-submodule operations."
if grep -qi 'explicit per-submodule\|per-submodule operation\|without.*--recursive' "$TASK_CARD" 2>/dev/null; then
    check_pass "SC-4: task card directs explicit per-submodule operations (no '--recursive')"
else
    check_fail "SC-4: task card directs explicit per-submodule operations (no '--recursive')" \
        "no explicit per-submodule directive consistent with the guideline found in $TASK_CARD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-4 (no-'--recursive' mirror) not yet applied."
    echo "$TASK_CARD does not yet mirror the no-'--recursive' constraint from"
    echo "060-tool-usage.md §4."
    echo ""
    exit 1
fi
exit 0
