#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: atomicity trigger-word sub-check present in validate.md
# Maps to SC-3 from issue #2116: the Atomicity decision-tree block in
# .opencode/skills/spec-creation/tasks/validate.md includes a trigger-word sub-check
# (and, or, comma-separated lists -> FAIL).
#
# RED phase (Item 3): assert the strings `and`, `or`, and `comma-separated` are
# PRESENT within the Atomicity decision-tree block in validate.md. The test FAILS
# while the block is absent (baseline). GREEN phase adds the sub-check; this test
# then PASSES.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc3-atomicity-trigger-words.sh
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
echo "=== validate.md atomicity trigger-word sub-check -- SC-3 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

# Extract the Atomicity decision-tree block (from the Atomicity heading to the
# next heading or end of file).
ATOMICITY_BLOCK=$(awk '/^### Atomicity/{flag=1; next} /^### /{if(flag) exit} flag' "$VALIDATE_MD" 2>/dev/null || true)

# SC-3 (RED phase): the trigger-word strings must be present within the Atomicity
# block. The test FAILS while the block is absent (baseline). After GREEN adds the
# sub-check, this PASSES.
for token in "and" "or" "comma-separated"; do
    if printf '%s' "$ATOMICITY_BLOCK" | grep -qF "$token" 2>/dev/null; then
        check_pass "SC-3: '$token' present within Atomicity block in .opencode/skills/spec-creation/tasks/validate.md"
    else
        check_fail "SC-3: '$token' present within Atomicity block in .opencode/skills/spec-creation/tasks/validate.md" \
            "trigger-word sub-check absent (GREEN not applied)"
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
