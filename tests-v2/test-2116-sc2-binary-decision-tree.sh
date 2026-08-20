#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: imperative binary PASS/FAIL branch tokens present in validate.md
# Maps to SC-2 from issue #2116: each of the 6 decomposition criteria in
# .opencode/skills/spec-creation/tasks/validate.md uses imperative binary decision
# tree format with explicit PASS/FAIL branches (not prose guidance).
#
# RED phase (Item 2): assert the branch tokens `PASS —` and `FAIL —` are PRESENT in
# .opencode/skills/spec-creation/tasks/validate.md. The test FAILS while the tokens
# are absent (baseline). GREEN phase adds the decision trees; this test then PASSES.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc2-binary-decision-tree.sh
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
echo "=== validate.md imperative binary PASS/FAIL branch tokens -- SC-2 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

# SC-2 (RED phase): the branch tokens must be present in validate.md. The test
# FAILS while the tokens are absent (baseline). After GREEN adds the decision
# trees, this PASSES.
if grep -qF 'PASS —' "$VALIDATE_MD" 2>/dev/null; then
    check_pass "SC-2: 'PASS —' branch token present in .opencode/skills/spec-creation/tasks/validate.md"
else
    check_fail "SC-2: 'PASS —' branch token present in .opencode/skills/spec-creation/tasks/validate.md" \
        "branch token absent (GREEN not applied)"
fi

if grep -qF 'FAIL —' "$VALIDATE_MD" 2>/dev/null; then
    check_pass "SC-2: 'FAIL —' branch token present in .opencode/skills/spec-creation/tasks/validate.md"
else
    check_fail "SC-2: 'FAIL —' branch token present in .opencode/skills/spec-creation/tasks/validate.md" \
        "branch token absent (GREEN not applied)"
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
