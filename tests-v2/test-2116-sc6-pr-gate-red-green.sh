#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: PR-gate viability meta RED/GREEN reference present in validate.md
# Maps to SC-6 from issue #2116: the PR-Gate Viability decision-tree block in
# .opencode/skills/spec-creation/tasks/validate.md references the meta RED/GREEN
# principle.
#
# RED phase (Item 6): assert the strings `RED` and `GREEN` are PRESENT within the
# PR-Gate Viability decision-tree block in validate.md. The test FAILS while the
# block is absent (baseline). GREEN phase adds the reference; this test then PASSES.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc6-pr-gate-red-green.sh
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
echo "=== validate.md PR-gate viability meta RED/GREEN reference -- SC-6 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

# Extract the PR-Gate Viability decision-tree block (from the PR-Gate Viability
# heading to the next heading or end of file).
PRGATE_BLOCK=$(awk '/^### PR-Gate Viability/{flag=1; next} /^### /{if(flag) exit} flag' "$VALIDATE_MD" 2>/dev/null || true)

# SC-6 (RED phase): the RED and GREEN strings must be present within the PR-Gate
# Viability block. The test FAILS while the block is absent (baseline). After GREEN
# adds the reference, this PASSES.
for token in "RED" "GREEN"; do
    if printf '%s' "$PRGATE_BLOCK" | grep -qF "$token" 2>/dev/null; then
        check_pass "SC-6: '$token' present within PR-Gate Viability block in .opencode/skills/spec-creation/tasks/validate.md"
    else
        check_fail "SC-6: '$token' present within PR-Gate Viability block in .opencode/skills/spec-creation/tasks/validate.md" \
            "meta RED/GREEN reference absent (GREEN not applied)"
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
