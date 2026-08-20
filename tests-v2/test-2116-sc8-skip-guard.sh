#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: skip-condition guard present in validate.md
# Maps to SC-8 from issue #2116: the decomposition check in
# .opencode/skills/spec-creation/tasks/validate.md is skipped (not evaluated) when
# the spec has exactly 1 SC AND 1 affected file.
#
# RED phase (Item 8): assert the strings `1 SC` and `1 affected file` are PRESENT
# within the skip-condition guard in validate.md. The test FAILS while the guard is
# absent (baseline). GREEN phase adds the guard; this test then PASSES.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc8-skip-guard.sh
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
echo "=== validate.md skip-condition guard -- SC-8 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

# SC-8 (RED phase): the skip-guard strings must be present in validate.md. The
# test FAILS while the guard is absent (baseline). After GREEN adds the guard, this
# PASSES.
for token in "1 SC" "1 affected file"; do
    if grep -qF "$token" "$VALIDATE_MD" 2>/dev/null; then
        check_pass "SC-8: '$token' present in .opencode/skills/spec-creation/tasks/validate.md"
    else
        check_fail "SC-8: '$token' present in .opencode/skills/spec-creation/tasks/validate.md" \
            "skip-condition guard absent (GREEN not applied)"
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
