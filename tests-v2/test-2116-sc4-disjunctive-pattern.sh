#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: binary verifiability disjunctive-pattern sub-check present in validate.md
# Maps to SC-4 from issue #2116: the Binary Verifiability decision-tree block in
# .opencode/skills/spec-creation/tasks/validate.md includes a disjunctive-pattern
# sub-check (either/or, alternatively, one of -> FAIL).
#
# RED phase (Item 4): assert the strings `either/or`, `alternatively`, and `one of`
# are PRESENT within the Binary Verifiability decision-tree block in validate.md.
# The test FAILS while the block is absent (baseline). GREEN phase adds the
# sub-check; this test then PASSES.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc4-disjunctive-pattern.sh
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
echo "=== validate.md binary verifiability disjunctive-pattern sub-check -- SC-4 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

# Extract the Binary Verifiability decision-tree block (from the Binary
# Verifiability heading to the next heading or end of file).
BINARY_BLOCK=$(awk '/^### Binary Verifiability/{flag=1; next} /^### /{if(flag) exit} flag' "$VALIDATE_MD" 2>/dev/null || true)

# SC-4 (RED phase): the disjunctive-pattern strings must be present within the
# Binary Verifiability block. The test FAILS while the block is absent (baseline).
# After GREEN adds the sub-check, this PASSES.
for token in "either/or" "alternatively" "one of"; do
    if printf '%s' "$BINARY_BLOCK" | grep -qF "$token" 2>/dev/null; then
        check_pass "SC-4: '$token' present within Binary Verifiability block in .opencode/skills/spec-creation/tasks/validate.md"
    else
        check_fail "SC-4: '$token' present within Binary Verifiability block in .opencode/skills/spec-creation/tasks/validate.md" \
            "disjunctive-pattern sub-check absent (GREEN not applied)"
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
