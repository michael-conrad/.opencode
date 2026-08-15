#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: authorization carve-out coverage (V-SC-10 checklist)
# Maps to SC-10 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL explicitly cover all
# 4 carve-out categories (spec→plan→implementation pipeline, task tracking files,
# spec and plan files, authorization-gated project items).
#
# All checks are scoped to the Self-Simulation Prohibition section (the section
# starting at the 'Self-Simulation' heading) so pre-existing content in the
# No-Echo / Trigger Map / Suppression sections cannot satisfy them.
#
# RED phase: the Self-Simulation section does not yet exist — the section block
# is empty and all 4 V-SC-10 checks FAIL.
# GREEN phase: after the section is added with all 4 carve-out categories, this
# test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc10-carveout-coverage.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== Authorization Carve-out Coverage -- SC-10 (V-SC-10, #2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# Extract the Self-Simulation Prohibition section: from the 'Self-Simulation'
# heading to the next same-or-higher-level heading.
SELF_SIM_BLOCK=$(awk '/Self-Simulation/{found=1} found && /^#{1,4} / && !/Self-Simulation/{exit} found{print}' "$GUIDELINE_FILE" 2>/dev/null || true)

if [ -z "$SELF_SIM_BLOCK" ]; then
    echo "  (Self-Simulation Prohibition section not present — RED phase)"
fi

# V-SC-10 #1: spec→plan→implementation pipeline
if echo "$SELF_SIM_BLOCK" | grep -qiE "spec.?plan.?implementation|spec-creation|writing-plans"; then
    check_pass "V-SC-10 #1: spec→plan→implementation pipeline"
else
    check_fail "V-SC-10 #1: spec→plan→implementation pipeline" "guideline does not explicitly permit the sanctioned spec→plan→implementation pipeline"
fi

# V-SC-10 #2: task tracking files
if echo "$SELF_SIM_BLOCK" | grep -qiE "task tracking|work state|checkpoint tag"; then
    check_pass "V-SC-10 #2: task tracking files"
else
    check_fail "V-SC-10 #2: task tracking files" "guideline does not explicitly permit task tracking files (work state files, checkpoint tags)"
fi

# V-SC-10 #3: spec and plan files
if echo "$SELF_SIM_BLOCK" | grep -qiE "spec files|plan files"; then
    check_pass "V-SC-10 #3: spec and plan files"
else
    check_fail "V-SC-10 #3: spec and plan files" "guideline does not explicitly permit spec files and plan files the agent writes and later follows"
fi

# V-SC-10 #4: authorization-gated project items
if echo "$SELF_SIM_BLOCK" | grep -qiE "authorization-gated|authorization gate|project items"; then
    check_pass "V-SC-10 #4: authorization-gated project items"
else
    check_fail "V-SC-10 #4: authorization-gated project items" "guideline does not explicitly permit other project items through the authorization-gated pipeline"
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
