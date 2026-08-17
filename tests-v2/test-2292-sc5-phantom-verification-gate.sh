#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: no phantom `verification-*.md` gate requirement
# Maps to SC-5 from issue #2292: the verification-evidence gate in
# `create-pr.md` Step 4.75 SHALL NOT reference `verification-*.md` as a required
# PR-blocking artifact; the gate SHALL require only `vbc-table-*.md` and
# `judgment.yaml`.
#
# RED phase: the `verification-*.md` reference is present in the gate — this
# test FAILS.
# GREEN phase: after the `verification-*.md` check is removed from the gate,
# this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2292-sc5-phantom-verification-gate.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

CREATE_PR_FILE="$PROJECT_DIR/.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md"

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
echo "=== No phantom verification-*.md gate requirement -- SC-5 (#2292) ==="
echo ""
echo "Target file: $CREATE_PR_FILE"
echo ""

# ---------------------------------------------------------------------------
# SC-5: The verification-evidence gate in create-pr.md Step 4.75 SHALL NOT
# reference `verification-*.md` as a required PR-blocking artifact. The gate
# SHALL require only `vbc-table-*.md` and `judgment.yaml`.
#
# RED: the `verification-*.md` reference is present in the gate — this check
# FAILS (the defect exists).
# ---------------------------------------------------------------------------

# (a) No `verification-*.md` reference in the verification-evidence gate.
PHANTOM_REF=$(grep -nF 'verification-*.md' "$CREATE_PR_FILE" 2>/dev/null || true)
if [ -n "$PHANTOM_REF" ]; then
    check_fail "SC-5: no verification-*.md gate reference" \
        "found: $PHANTOM_REF"
else
    check_pass "SC-5: no verification-*.md gate reference"
fi

# (b) The vbc-table-*.md check is intact in the gate.
VBC_REF=$(grep -nF 'vbc-table-*.md' "$CREATE_PR_FILE" 2>/dev/null || true)
if [ -n "$VBC_REF" ]; then
    check_pass "SC-5: vbc-table-*.md check intact"
else
    check_fail "SC-5: vbc-table-*.md check intact" \
        "vbc-table-*.md reference not found in the gate"
fi

# (c) The judgment.yaml check is intact in the gate.
JUDGMENT_REF=$(grep -nF 'judgment.yaml' "$CREATE_PR_FILE" 2>/dev/null || true)
if [ -n "$JUDGMENT_REF" ]; then
    check_pass "SC-5: judgment.yaml check intact"
else
    check_fail "SC-5: judgment.yaml check intact" \
        "judgment.yaml reference not found in the gate"
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
