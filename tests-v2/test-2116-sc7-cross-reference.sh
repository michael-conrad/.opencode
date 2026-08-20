#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: cross-reference comment present in validate.md
# Maps to SC-7 from issue #2116: the inline decomposition criteria copy in
# .opencode/skills/spec-creation/tasks/validate.md includes the cross-reference
# comment 'See audit/reference/decomposition-criteria.md for master definition'.
#
# RED phase (Item 7): assert the exact string
# 'See audit/reference/decomposition-criteria.md for master definition' is PRESENT
# in validate.md. The test FAILS while the string is absent (baseline). GREEN phase
# adds the comment; this test then PASSES.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc7-cross-reference.sh
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
echo "=== validate.md cross-reference comment -- SC-7 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

# SC-7 (RED phase): the cross-reference comment must be present in validate.md.
# The test FAILS while the string is absent (baseline). After GREEN adds the
# comment, this PASSES.
if grep -qF 'See audit/reference/decomposition-criteria.md for master definition' "$VALIDATE_MD" 2>/dev/null; then
    check_pass "SC-7: cross-reference comment present in .opencode/skills/spec-creation/tasks/validate.md"
else
    check_fail "SC-7: cross-reference comment present in .opencode/skills/spec-creation/tasks/validate.md" \
        "cross-reference comment absent (GREEN not applied)"
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
