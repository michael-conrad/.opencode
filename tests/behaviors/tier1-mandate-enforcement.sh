#!/bin/bash
# Behavioral Enforcement Test: Tier 1 Mandate Enforcement Gate
#
# Verifies that session-enforcement.ts contains a systematic Tier 1
# mandate enforcement gate that prescriptively enforces all 9 mandates
# from 000-critical-rules.md Table "Tier 1 — Non-Yielding Mandates".
#
# This test checks for the PRESENCE of a dedicated Tier 1 gate function
# in session-enforcement.ts that:
#   1. Enumerates all Tier 1 mandates programmatically (not just ad-hoc prose)
#   2. Injects a Tier 1 enforcement block into messages when violations are detected
#   3. Blocks inline work (already Gate 3), protected branch commits,
#      spec bypass, /tmp/ usage, self-authorization, and other Tier 1 violations
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   No buildTier1EnforcementBlock() function exists in
#          session-enforcement.ts — test fails
#   GREEN: buildTier1EnforcementBlock() added, Tier 1 gate injected
#          into messages.transform — test passes
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$WORKTREE_ROOT")" != ".opencode" ]; do
    WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"
done
WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"

SCENARIO_NAME="tier1-mandate-enforcement"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

SESSION_FILE=".opencode/plugins/session-enforcement.ts"
WORKTREE_FILE="$WORKTREE_ROOT/$SESSION_FILE"

if [ ! -f "$WORKTREE_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — $SESSION_FILE not found"
    exit 1
fi

OVERALL_RESULT=0

# --------------------------------------------------------------------------
# Verify 1: Tier 1 enforcement block builder function EXISTS
#   The function name MUST be buildTier1EnforcementBlock (or similar)
#   to be distinct from the existing ad-hoc injection blocks.
# --------------------------------------------------------------------------
if grep -q 'function buildTier1EnforcementBlock' "$WORKTREE_FILE"; then
    echo "PASS: $SCENARIO_NAME — buildTier1EnforcementBlock() function found"
else
    echo "FAIL: $SCENARIO_NAME — buildTier1EnforcementBlock() function NOT found in session-enforcement.ts"
    OVERALL_RESULT=1
fi

# --------------------------------------------------------------------------
# Verify 2: Tier 1 gate enumerates the mandated violations systematically
#   Must reference "Tier 1" and mandate keywords from the 9 mandates table:
#   - protected branch / main / dev commits
#   - self-authorization (agents must never self-authorize)
#   - /tmp/ usage prohibition
#   - inline work / orchestrator file edits
#   - spec bypass (Tier 2 that escalates under Tier 1 protection)
# --------------------------------------------------------------------------
TIER1_GATE_FOUND=false

# Check for Tier 1 gate injection in messages.transform
if grep -q 'Tier 1' "$WORKTREE_FILE"; then
    echo "PASS: $SCENARIO_NAME — 'Tier 1' referenced in session-enforcement.ts"
else
    echo "FAIL: $SCENARIO_NAME — 'Tier 1' NOT referenced in session-enforcement.ts"
    OVERALL_RESULT=1
fi

# --------------------------------------------------------------------------
# Verify 3: Protected branch detection — must block commits to main/dev
#   Either exists as part of Tier 1 gate or as a standalone gate,
#   but MUST be present as a prescriptive enforcement (not just advisory prose)
# --------------------------------------------------------------------------
PROTECTED_BRANCH_ENFORCEMENT=false

# Check for a buildProtectedBranchBlock or similar function
if grep -qi 'function buildProtectedBranch\|function build.*Branch.*Block\|protectedBranch\|no.commit.*main\|no.commit.*dev' "$WORKTREE_FILE"; then
    PROTECTED_BRANCH_ENFORCEMENT=true
    echo "PASS: $SCENARIO_NAME — protected branch enforcement function found"
fi

# Also accept if Tier 1 gate references protected branches
if ! $PROTECTED_BRANCH_ENFORCEMENT; then
    if grep -qi 'protected.*branch\|branch.*protect\|commit.*to.*main\|commit.*to.*dev' "$WORKTREE_FILE"; then
        # Check if this is in an enforcement block, not just comments
        if grep -qi 'protected.*branch.*violation\|branch.*protect.*gate\|TIER_1_MANDATE.*PROTECTED_BRANCH\|tier1Mandate.*protectedBranch' "$WORKTREE_FILE"; then
            echo "PASS: $SCENARIO_NAME — protected branch referenced in Tier 1 enforcement"
        else
            echo "FAIL: $SCENARIO_NAME — protected branch referenced but NOT in enforcement gate (advisory prose only)"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: $SCENARIO_NAME — protected branch enforcement NOT found"
        OVERALL_RESULT=1
    fi
fi

# --------------------------------------------------------------------------
# Verify 4: Self-authorization prevention — must be in enforcement, not just prose
#   Tier 1 mandate: "Agents must never self-authorize"
# --------------------------------------------------------------------------
SELF_AUTH_ENFORCEMENT=false

if grep -qi 'self.authoriz\|self_authoriz\|SELF_AUTHORIZ\|never.*self.*authoriz\|must never self-authorize' "$WORKTREE_FILE"; then
    echo "PASS: $SCENARIO_NAME — self-authorization prohibition found in enforcement"
    SELF_AUTH_ENFORCEMENT=true
else
    echo "FAIL: $SCENARIO_NAME — self-authorization prohibition NOT found in enforcement"
    OVERALL_RESULT=1
fi

# --------------------------------------------------------------------------
# Verify 5: /tmp/ prohibition — must be in enforcement block
#   Tier 1 mandate: "No /tmp/ usage — ./tmp/ only"
# --------------------------------------------------------------------------
TMP_PROHIBITION=false

if grep -qi '/tmp/\|NO_TMP\|no.*tmp.*usage\|tmp.*only\|tmp.*prohibit' "$WORKTREE_FILE"; then
    TMP_PROHIBITION=true
fi

if $TMP_PROHIBITION; then
    # Verify it's in an enforcement block, not just a comment
    if grep -qi 'TIER_1_MANDATE.*TMP\|tier1Mandate.*tmp\|buildTier1.*tmp\|CRITICAL VIOLATION.*tmp\|forbidden.*tmp\|No.*tmp.*usage\|tmp.*only.*Prevents' "$WORKTREE_FILE"; then
        echo "PASS: $SCENARIO_NAME — /tmp/ prohibition in Tier 1 enforcement"
    else
        echo "FAIL: $SCENARIO_NAME — /tmp/ referenced but NOT in Tier 1 enforcement block"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: $SCENARIO_NAME — /tmp/ prohibition NOT found"
    OVERALL_RESULT=1
fi

# --------------------------------------------------------------------------
# Verify 6: Tier 1 gate is INJECTED into messages (not just defined)
#   The gate must be called from the messages.transform hook
# --------------------------------------------------------------------------
GATE_INJECTED=false

if grep -qi 'buildTier1EnforcementBlock\|Tier1EnforcementBlock\|Tier.1.*gate\|tier1.*mandate.*enforcement' "$WORKTREE_FILE"; then
    # Check if it's called/injected, not just defined
    if grep -qi 'buildTier1EnforcementBlock()' "$WORKTREE_FILE"; then
        # Check invocation in message transform (not just function definition)
        INVOKE_COUNT=$(grep -c 'buildTier1EnforcementBlock' "$WORKTREE_FILE" 2>/dev/null || echo "0")
        if [ "$INVOKE_COUNT" -ge 2 ]; then
            echo "PASS: $SCENARIO_NAME — Tier 1 enforcement gate function defined AND invoked (count: $INVOKE_COUNT)"
            GATE_INJECTED=true
        else
            echo "FAIL: $SCENARIO_NAME — Tier 1 enforcement gate function defined but NOT invoked in messages.transform"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: $SCENARIO_NAME — Tier 1 enforcement gate referenced but buildTier1EnforcementBlock() function not found"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: $SCENARIO_NAME — Tier 1 enforcement gate NOT referenced in session-enforcement.ts"
    OVERALL_RESULT=1
fi

# --------------------------------------------------------------------------
# Verify 7: Inline work detection (Gate 3) still present and intact
#   This is an existing gate that will become part of Tier 1 enforcement,
#   but it must still exist regardless.
# --------------------------------------------------------------------------
if grep -qi 'Inline work detect\|inline.*work.*detect\|Gate 3\|buildInlineWorkDetectedBlock' "$WORKTREE_FILE"; then
    echo "PASS: $SCENARIO_NAME — inline work detection gate (Gate 3) present"
else
    echo "FAIL: $SCENARIO_NAME — inline work detection gate (Gate 3) NOT found"
    OVERALL_RESULT=1
fi

# --------------------------------------------------------------------------
# Verify 8: Mandatory skill invocation enforcement
#   Tier 1 Core Principles block references mandatory skills (divide-and-conquer,
#   adversarial-audit, etc.) — verify this remains present
# --------------------------------------------------------------------------
if grep -qi 'divide-and-conquer\|adversarial-audit\|verification-before-completion' "$WORKTREE_FILE"; then
    echo "PASS: $SCENARIO_NAME — mandatory skill references present in core principles"
else
    echo "FAIL: $SCENARIO_NAME — mandatory skill references NOT found in core principles"
    OVERALL_RESULT=1
fi

# --------------------------------------------------------------------------
# Summary
# --------------------------------------------------------------------------
echo ""
echo "=== Tier 1 Mandate Enforcement Gate Test Results ==="
echo "  buildTier1EnforcementBlock():       $(if grep -q 'function buildTier1EnforcementBlock' "$WORKTREE_FILE"; then echo 'PRESENT'; else echo 'MISSING (RED)'; fi)"
echo "  Tier 1 references:                  $(if grep -q 'Tier 1' "$WORKTREE_FILE"; then echo 'PRESENT'; else echo 'MISSING (RED)'; fi)"
echo "  Protected branch enforcement:        $(if $PROTECTED_BRANCH_ENFORCEMENT; then echo 'PRESENT'; else echo 'MISSING (RED)'; fi)"
echo "  Self-authorization prohibition:      $(if $SELF_AUTH_ENFORCEMENT; then echo 'PRESENT'; else echo 'MISSING (RED)'; fi)"
echo "  /tmp/ prohibition in enforcement:    $(if $TMP_PROHIBITION; then echo 'PRESENT'; else echo 'MISSING (RED)'; fi)"
echo "  Tier 1 gate invoked in transform:   $(if $GATE_INJECTED; then echo 'PRESENT'; else echo 'MISSING (RED)'; fi)"
echo "  Gate 3 inline work detection:        $(if grep -qi 'Inline work detect\|buildInlineWorkDetectedBlock' "$WORKTREE_FILE"; then echo 'PRESENT'; else echo 'MISSING'; fi)"
echo "  Mandatory skill references:          $(if grep -qi 'divide-and-conquer\|adversarial-audit\|verification-before-completion' "$WORKTREE_FILE"; then echo 'PRESENT'; else echo 'MISSING'; fi)"
echo ""

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME (RED phase — expected, gate not yet implemented)"
fi

exit $OVERALL_RESULT