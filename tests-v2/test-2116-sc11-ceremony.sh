#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: Ceremony criterion present in validate.md
# Maps to SC-11 from issue #2116: the Decomposition Criteria section in
# .opencode/skills/spec-creation/tasks/validate.md includes the Ceremony criterion,
# expressed as an imperative binary decision tree with explicit PASS/FAIL branches,
# computed as set-entailment over prior SCs only.
#
# RED phase (Item 9): assert the `### Ceremony` heading, the `PASS —`/`FAIL —`
# branch tokens, and the string `prior SCs` are PRESENT within the Ceremony block in
# validate.md. The test FAILS while the block is absent (baseline). GREEN phase adds
# the criterion; this test then PASSES.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc11-ceremony.sh
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
echo "=== validate.md Ceremony criterion -- SC-11 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

# Extract the Ceremony decision-tree block (from the Ceremony heading to the next
# heading or end of file).
CEREMONY_BLOCK=$(awk '/^### Ceremony/{flag=1; next} /^### /{if(flag) exit} flag' "$VALIDATE_MD" 2>/dev/null || true)

# SC-11 (RED phase): the heading, branch tokens, and prior-SCs string must be
# present within the Ceremony block. The test FAILS while the block is absent
# (baseline). After GREEN adds the criterion, this PASSES.
if grep -qF '### Ceremony' "$VALIDATE_MD" 2>/dev/null; then
    check_pass "SC-11: '### Ceremony' heading present in .opencode/skills/spec-creation/tasks/validate.md"
else
    check_fail "SC-11: '### Ceremony' heading present in .opencode/skills/spec-creation/tasks/validate.md" \
        "Ceremony heading absent (GREEN not applied)"
fi

for token in "PASS —" "FAIL —" "prior SCs"; do
    if printf '%s' "$CEREMONY_BLOCK" | grep -qF "$token" 2>/dev/null; then
        check_pass "SC-11: '$token' present within Ceremony block in .opencode/skills/spec-creation/tasks/validate.md"
    else
        check_fail "SC-11: '$token' present within Ceremony block in .opencode/skills/spec-creation/tasks/validate.md" \
            "Ceremony criterion element absent (GREEN not applied)"
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
