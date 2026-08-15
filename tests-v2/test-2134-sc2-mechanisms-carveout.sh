#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: prohibition covers all 5 UNAUTHORIZED mechanisms
# + authorized-pipeline carve-out (V-SC-2 checklist)
# Maps to SC-2 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL cover all 5
# UNAUTHORIZED mechanisms (shell, file, comment, tool output, session trigger)
# AND the authorized-pipeline carve-out, qualified by an authorization boundary.
#
# All checks are scoped to the Self-Simulation Prohibition section (the section
# starting at the 'Self-Simulation' heading) so pre-existing content in the
# No-Echo / Trigger Map / Suppression sections cannot satisfy them.
#
# RED phase: the Self-Simulation section does not yet exist — the section block
# is empty and all 7 V-SC-2 checks FAIL.
# GREEN phase: after the section is added with all 5 mechanisms + authorization
# boundary + carve-out, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc2-mechanisms-carveout.sh
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
echo "=== Prohibition Mechanisms + Carve-out -- SC-2 (V-SC-2, #2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# Extract the Self-Simulation Prohibition section: from the 'Self-Simulation'
# heading to the next same-or-higher-level heading.
SELF_SIM_BLOCK=$(awk '/Self-Simulation/{found=1} found && /^#{1,4} / && !/Self-Simulation/{exit} found{print}' "$GUIDELINE_FILE" 2>/dev/null || true)

if [ -z "$SELF_SIM_BLOCK" ]; then
    echo "  (Self-Simulation Prohibition section not present — RED phase)"
fi

# V-SC-2 #1: shell output mechanism
if echo "$SELF_SIM_BLOCK" | grep -qiE "echo|printf|heredoc|shell"; then
    check_pass "V-SC-2 #1: shell output mechanism (echo/printf/heredoc)"
else
    check_fail "V-SC-2 #1: shell output mechanism (echo/printf/heredoc)" "no MUST NOT statement covering shell output in the Self-Simulation section"
fi

# V-SC-2 #2: file write + read mechanism
if echo "$SELF_SIM_BLOCK" | grep -qiE "file|write.*read|reading that file"; then
    check_pass "V-SC-2 #2: file write + read mechanism"
else
    check_fail "V-SC-2 #2: file write + read mechanism" "no MUST NOT statement covering writing instructions to a file and reading them back"
fi

# V-SC-2 #3: comment + process mechanism
if echo "$SELF_SIM_BLOCK" | grep -qiE "comment"; then
    check_pass "V-SC-2 #3: comment + process mechanism"
else
    check_fail "V-SC-2 #3: comment + process mechanism" "no MUST NOT statement covering posting a comment and reading it back as instructions"
fi

# V-SC-2 #4: tool output re-ingestion mechanism
if echo "$SELF_SIM_BLOCK" | grep -qiE "tool output|re-ingest|one tool"; then
    check_pass "V-SC-2 #4: tool output re-ingestion mechanism"
else
    check_fail "V-SC-2 #4: tool output re-ingestion mechanism" "no MUST NOT statement covering producing output via one tool and consuming via another"
fi

# V-SC-2 #5: session trigger echoing mechanism
if echo "$SELF_SIM_BLOCK" | grep -qiE "SESSION_TRIGGERS|trigger.*verbatim|session trigger"; then
    check_pass "V-SC-2 #5: session trigger echoing mechanism"
else
    check_fail "V-SC-2 #5: session trigger echoing mechanism" "no MUST NOT statement covering printing trigger data verbatim and acting on it"
fi

# V-SC-2 #6: authorization boundary language
if echo "$SELF_SIM_BLOCK" | grep -qiE "authorization boundary|authorization gate|without authorization"; then
    check_pass "V-SC-2 #6: authorization boundary language"
else
    check_fail "V-SC-2 #6: authorization boundary language" "no authorization boundary qualifier on the prohibition"
fi

# V-SC-2 #7: authorized-pipeline carve-out exists
if echo "$SELF_SIM_BLOCK" | grep -qiE "carve.?out|authorized pipeline|spec.?plan.?implementation"; then
    check_pass "V-SC-2 #7: authorized-pipeline carve-out exists"
else
    check_fail "V-SC-2 #7: authorized-pipeline carve-out exists" "no explicit carve-out for the sanctioned pipeline (spec/plan/implementation)"
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
