#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: semantic preservation of original actionable
# instructions (V-SC-9 checklist)
# Maps to SC-9 from issue #2134: every actionable instruction in the original
# guideline (no-echo rule, trigger behavior map, suppression rule) SHALL be
# preserved in the rewrite with equivalent semantic force.
#
# The four V-SC-9 checks are scoped to the NARROWED sections. The narrowing
# (the GREEN change) must preserve each instruction with equivalent semantic
# force while removing the historical #426 purge references and framing the
# No-Echo rule as a specific case of the Self-Simulation Prohibition.
#
# RED phase: the sections are not yet narrowed — the No-Echo section does not
# reference the Self-Simulation Prohibition and the Trigger Map / Suppression
# Rule still carry the historical #426 purge reference — so this test FAILS.
# GREEN phase: after the sections are narrowed while preserving the four
# instructions, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc9-semantic-preservation.sh
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
echo "=== Semantic Preservation of Original Instructions -- SC-9 (V-SC-9, #2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

extract_section() {
    local heading="$1"
    awk -v h="$heading" '$0 ~ h {found=1} found && /^#{1,4} / && $0 !~ h {exit} found{print}' "$GUIDELINE_FILE" 2>/dev/null || true
}

NO_ECHO_BLOCK=$(extract_section "No-Echo")
MAP_BLOCK=$(extract_section "Trigger Behavior Map")
SUPPRESS_BLOCK=$(extract_section "Suppression Rule")

# V-SC-9 #1: No-Echo rule preserved — a MUST NOT statement covering session
# trigger echoing exists within the No-Echo section, and the section is
# narrowed as a specific case of the Self-Simulation Prohibition.
if echo "$NO_ECHO_BLOCK" | grep -q "MUST NOT" && echo "$NO_ECHO_BLOCK" | grep -qiE "Self-Simulation|specific case"; then
    check_pass "V-SC-9 #1: No-Echo rule preserved (MUST NOT + narrowed as specific case of Self-Simulation Prohibition)"
else
    check_fail "V-SC-9 #1: No-Echo rule preserved (MUST NOT + narrowed as specific case of Self-Simulation Prohibition)" "No-Echo section lacks a MUST NOT statement or is not narrowed as a specific case of the Self-Simulation Prohibition"
fi

# V-SC-9 #2: pair_mode_resume → continue pair mode workflow preserved in the
# narrowed Trigger Behavior Map (no historical #426 purge reference).
if echo "$MAP_BLOCK" | grep -q "pair_mode_resume" && echo "$MAP_BLOCK" | grep -qiE "continue pair mode"; then
    if echo "$MAP_BLOCK" | grep -qiE "#426|purge|purged"; then
        check_fail "V-SC-9 #2: pair_mode_resume → continue pair mode workflow preserved in narrowed map" "pair_mode_resume behavior preserved but the map still carries the historical #426 purge reference"
    else
        check_pass "V-SC-9 #2: pair_mode_resume → continue pair mode workflow preserved in narrowed map"
    fi
else
    check_fail "V-SC-9 #2: pair_mode_resume → continue pair mode workflow preserved in narrowed map" "pair_mode_resume trigger or its 'continue pair mode' behavior not found in the Trigger Behavior Map"
fi

# V-SC-9 #3: nested_opencode_fatal → HALT all operations preserved in the
# narrowed Trigger Behavior Map (no historical #426 purge reference).
if echo "$MAP_BLOCK" | grep -q "nested_opencode_fatal" && echo "$MAP_BLOCK" | grep -qiE "HALT"; then
    if echo "$MAP_BLOCK" | grep -qiE "#426|purge|purged"; then
        check_fail "V-SC-9 #3: nested_opencode_fatal → HALT preserved in narrowed map" "nested_opencode_fatal behavior preserved but the map still carries the historical #426 purge reference"
    else
        check_pass "V-SC-9 #3: nested_opencode_fatal → HALT preserved in narrowed map"
    fi
else
    check_fail "V-SC-9 #3: nested_opencode_fatal → HALT preserved in narrowed map" "nested_opencode_fatal trigger or its HALT behavior not found in the Trigger Behavior Map"
fi

# V-SC-9 #4: Suppression Rule preserved — a rule to suppress non-actionable
# triggers exists in the narrowed Suppression Rule section (no historical
# #426 purge reference).
if echo "$SUPPRESS_BLOCK" | grep -qiE "suppress"; then
    if echo "$SUPPRESS_BLOCK" | grep -qiE "#426|purge|purged"; then
        check_fail "V-SC-9 #4: Suppression Rule preserved (suppress non-actionable triggers, no #426 reference)" "Suppression Rule preserved but still carries the historical #426 purge reference"
    else
        check_pass "V-SC-9 #4: Suppression Rule preserved (suppress non-actionable triggers, no #426 reference)"
    fi
else
    check_fail "V-SC-9 #4: Suppression Rule preserved (suppress non-actionable triggers, no #426 reference)" "no suppression instruction found in the Suppression Rule section"
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
