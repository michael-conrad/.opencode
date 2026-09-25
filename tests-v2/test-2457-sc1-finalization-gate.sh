#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-1 — single-mechanism finalization
# gate at the Step 6 -> Step 7 terminal transition of the explore deck.
#
# Issue: .opencode#2457 — brainstorming explore deck single-mechanism
#        finalization gate.
# Phase: 1 (step 6), SC-1 (structural gate-text RED).
#
# The explore deck SHALL carry an explicit single-mechanism finalization gate
# at the terminal transition ("User approves?" -> "Invoke spec-creation" edge):
#
#   (a) .opencode/skills/brainstorming/tasks/explore.md carries a gate text
#       block at the terminal transition (Step 6 -> Step 7): a finalization
#       hard gate section at the "User approves? -> Invoke spec-creation"
#       edge;
#
#   (b) .opencode/skills/brainstorming/tasks/explore/exploration-workflow.md
#       at Step 7 defines the gate:
#       (b1) gate defined — hard gate, user finalization REQUIRED before
#            spec-creation dispatch;
#       (b2) non-finalization classification — refinements/corrections/
#            clarifications route to discussion mode, hold awaiting_finalization;
#       (b3) finalization-signal semantics — recognized, unforgeable user
#            statement, never agent inference;
#       (b4) approved/go vocabulary-separation note present via Read-link.
#
# RED state: the gate text does not exist yet.
#   Assertions (a), (b1), (b2), (b3), (b4) FAIL because the gate text blocks
#   are absent (baseline confirmed zero matches).
#
# Evidence type: structural (content check on skill deck text).
#
# Usage: bash .opencode/tests-v2/test-2457-sc1-finalization-gate.sh
# Exit:  0 if the finalization gate text is complete (GREEN),
#        1 if it is missing (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

EXPLORE_MD="$PROJECT_DIR/.opencode/skills/brainstorming/tasks/explore.md"
WORKFLOW_MD="$PROJECT_DIR/.opencode/skills/brainstorming/tasks/explore/exploration-workflow.md"

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
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== SC-1 — single-mechanism finalization gate at the Step 6 -> Step 7 transition (Spec .opencode#2457) ==="
echo ""
echo "Target (a):  $EXPLORE_MD"
echo "Target (b):  $WORKFLOW_MD"
echo ""

if [ ! -f "$EXPLORE_MD" ]; then
    check_fail "target file exists: explore.md" "missing $EXPLORE_MD"
    EXPLORE_MD=""
fi
if [ ! -f "$WORKFLOW_MD" ]; then
    check_fail "target file exists: exploration-workflow.md" "missing $WORKFLOW_MD"
    WORKFLOW_MD=""
fi

# ---------------------------------------------------------------------------
# (a) Gate text block in explore.md at the terminal transition
#     ("User approves?" -> "Invoke spec-creation" edge).
# ---------------------------------------------------------------------------
echo "--- (a): gate text block in explore.md at the terminal transition ---"

if [ -n "$EXPLORE_MD" ]; then
    # The digraph terminal edge must still exist (anchor of the transition).
    if grep -q '"User approves?" -> "Invoke spec-creation" \[label="yes"\];' "$EXPLORE_MD" 2>/dev/null; then
        check_pass "(a) terminal edge 'User approves? -> Invoke spec-creation' present"
    else
        check_fail "(a) terminal edge present" \
            "no '\"User approves?\" -> \"Invoke spec-creation\" [label=\"yes\"];' edge in $EXPLORE_MD"
    fi

    # The finalization hard gate text block must exist at that transition.
    if grep -qi 'finalization' "$EXPLORE_MD" 2>/dev/null \
        && grep -qi 'finalization gate' "$EXPLORE_MD" 2>/dev/null \
        && grep -qi 'spec-creation' "$EXPLORE_MD" 2>/dev/null; then
        check_pass "(a) finalization hard gate text block present at the terminal transition"
    else
        check_fail "(a) finalization hard gate text block present" \
            "no finalization gate text block in $EXPLORE_MD (RED: gate text does not exist yet)"
    fi
else
    check_fail "(a) finalization hard gate text block present" "target file missing"
fi

# ---------------------------------------------------------------------------
# (b) Gate definition in exploration-workflow.md at Step 7.
# ---------------------------------------------------------------------------
echo "--- (b): gate definition in exploration-workflow.md at Step 7 ---"

if [ -n "$WORKFLOW_MD" ]; then
    # (b1) Gate defined: hard gate, user finalization REQUIRED before
    #      spec-creation dispatch.
    if grep -qi 'Step 7' "$WORKFLOW_MD" 2>/dev/null \
        && grep -qi 'finalization' "$WORKFLOW_MD" 2>/dev/null \
        && grep -qi 'hard gate' "$WORKFLOW_MD" 2>/dev/null \
        && grep -qi 'REQUIRED' "$WORKFLOW_MD" 2>/dev/null; then
        check_pass "(b1) Step 7 gate defined: hard gate, user finalization REQUIRED before spec-creation dispatch"
    else
        check_fail "(b1) Step 7 gate defined" \
            "Step 7 in $WORKFLOW_MD lacks a finalization hard-gate definition (RED: gate text does not exist yet)"
    fi

    # (b2) Non-finalization classification: refinements/corrections/
    #      clarifications -> discussion mode, hold awaiting_finalization.
    if grep -qi 'refinements' "$WORKFLOW_MD" 2>/dev/null \
        && grep -qi 'clarifications' "$WORKFLOW_MD" 2>/dev/null \
        && grep -qi 'discussion mode' "$WORKFLOW_MD" 2>/dev/null \
        && grep -qi 'awaiting_finalization' "$WORKFLOW_MD" 2>/dev/null; then
        check_pass "(b2) non-finalization classification: refinements/corrections/clarifications -> discussion mode, hold awaiting_finalization"
    else
        check_fail "(b2) non-finalization classification" \
            "Step 7 in $WORKFLOW_MD lacks non-finalization classification (discussion mode, awaiting_finalization) (RED)"
    fi

    # (b3) Finalization-signal semantics: recognized, unforgeable user
    #      statement — never agent inference.
    if grep -qi 'unforgeable' "$WORKFLOW_MD" 2>/dev/null \
        && grep -qi 'never agent inference' "$WORKFLOW_MD" 2>/dev/null; then
        check_pass "(b3) finalization-signal semantics: unforgeable user statement, never agent inference"
    else
        check_fail "(b3) finalization-signal semantics" \
            "Step 7 in $WORKFLOW_MD lacks unforgeable finalization-signal semantics (never agent inference) (RED)"
    fi

    # (b4) Approved/go vocabulary-separation note via Read-link.
    if grep -qi 'approved/go' "$WORKFLOW_MD" 2>/dev/null \
        && grep -Eqi 'Read \[[^]]+\]\([^)]+\)' "$WORKFLOW_MD" 2>/dev/null; then
        check_pass "(b4) approved/go vocabulary-separation note via Read-link"
    else
        check_fail "(b4) approved/go vocabulary-separation note via Read-link" \
            "Step 7 in $WORKFLOW_MD lacks approved/go vocabulary-separation Read-link note (RED)"
    fi
else
    check_fail "(b1) Step 7 gate defined" "target file missing"
    check_fail "(b2) non-finalization classification" "target file missing"
    check_fail "(b3) finalization-signal semantics" "target file missing"
    check_fail "(b4) approved/go vocabulary-separation note" "target file missing"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (.opencode#2457) not yet implemented. The"
    echo "single-mechanism finalization gate text does not exist in the explore"
    echo "deck (baseline confirmed zero matches). GREEN adds:"
    echo "  (a)  gate text block in explore.md at the terminal transition"
    echo "  (b1) Step 7 gate definition (hard gate, user finalization REQUIRED)"
    echo "  (b2) non-finalization classification (discussion mode, awaiting_finalization)"
    echo "  (b3) finalization-signal semantics (unforgeable, never agent inference)"
    echo "  (b4) approved/go vocabulary-separation Read-link note"
    echo ""
    exit 1
fi
echo "SC-1 is GREEN — the explore deck carries the explicit single-mechanism"
echo "finalization gate at the Step 6 -> Step 7 transition."
echo ""
exit 0