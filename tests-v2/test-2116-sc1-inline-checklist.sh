#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: inline decomposition criteria checklist present in validate.md
# Maps to SC-1 from issue #2116: .opencode/skills/spec-creation/tasks/validate.md
# includes inline decomposition criteria checklist for 6 spec-level criteria.
#
# RED phase (Item 1): assert the 6 criterion headings are PRESENT in
# .opencode/skills/spec-creation/tasks/validate.md. The test FAILS while the
# headings are absent (baseline). GREEN phase adds the checklist; this test then
# PASSES, confirming the addition.
#
# validate.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2116-sc1-inline-checklist.sh
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
echo "=== validate.md inline decomposition criteria checklist -- SC-1 (#2116) ==="
echo ""

VALIDATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/validate.md"

HEADINGS=(
    "### Atomicity"
    "### Single Deliverable"
    "### Binary Verifiability"
    "### PR-Gate Viability"
    "### Ceremony"
    "### Coverage / Covered-by-Prior"
)

# SC-1 (RED phase): all 6 criterion headings must be present in validate.md.
# The test FAILS while the headings are absent (baseline). After GREEN adds the
# checklist, this PASSES.
for heading in "${HEADINGS[@]}"; do
    if grep -qF "$heading" "$VALIDATE_MD" 2>/dev/null; then
        check_pass "SC-1: heading '$heading' present in .opencode/skills/spec-creation/tasks/validate.md"
    else
        check_fail "SC-1: heading '$heading' present in .opencode/skills/spec-creation/tasks/validate.md" \
            "criterion heading absent (GREEN not applied)"
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
