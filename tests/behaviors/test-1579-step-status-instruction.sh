#!/bin/bash
# Content-verification test: test-1579-step-status-instruction
# Verifies structural presence of Step Status instruction block in
# writing-plans/tasks/write.md Plan Format Requirements.
#
# SC-1 (string): Plan Format Requirements includes Step Status instruction
#   as required section 5
# SC-2 (string): Instruction block contains verbatim format with ✅, 🔄, ⏳
# SC-3 (string): Instruction block includes edge case rules (omit ✅ when
#   none, omit ⏳ when last)
# SC-4 (string): Validation rules updated to include Step Status instruction
#   presence
# SC-5 (string): Existing sections renumbered correctly (current 5-9 → 6-10)
#
# RED phase: all SCs FAIL (text doesn't exist yet) → exit 1
# GREEN phase: all SCs PASS (text exists) → exit 0
#
# Issue #1579: Plan writer injects step status instruction block

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

OVERALL_RESULT=0
WRITE_MD="$PROJECT_ROOT/.opencode/skills/writing-plans/tasks/write.md"

echo "=== Content-Verification Test: test-1579-step-status-instruction ==="
echo ""

# ============================================================
# SC-1: Step Status instruction as required section 5
# ============================================================
echo "--- SC-1: Step Status instruction as required section 5 ---"
SC1_COUNT=$(grep -c "Step Status instruction" "$WRITE_MD" 2>/dev/null || true)
echo "  'Step Status instruction' count = $SC1_COUNT"
if [ "$SC1_COUNT" -ge 1 ]; then
    echo "  → PASS"
else
    echo "  → FAIL (expected ≥ 1, got $SC1_COUNT)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-2: Verbatim format with ✅, 🔄, ⏳ markers
# ============================================================
echo ""
echo "--- SC-2: Verbatim format with ✅, 🔄, ⏳ markers ---"
SC2_CHECK=$(grep -c '✅\|🔄\|⏳' "$WRITE_MD" 2>/dev/null || true)
echo "  Status emoji markers count = $SC2_CHECK"
if [ "$SC2_CHECK" -ge 3 ]; then
    echo "  → PASS"
else
    echo "  → FAIL (expected ≥ 3 emoji markers, got $SC2_CHECK)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-3: Edge case rules (omit ✅ when none, omit ⏳ when last)
# ============================================================
echo ""
echo "--- SC-3: Edge case rules ---"
SC3_CHECK=$(grep -c "Omit the ✅ column\|Omit the ⏳ column" "$WRITE_MD" 2>/dev/null || true)
echo "  Edge case rule lines count = $SC3_CHECK"
if [ "$SC3_CHECK" -ge 2 ]; then
    echo "  → PASS"
else
    echo "  → FAIL (expected ≥ 2 edge case lines, got $SC3_CHECK)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-4: Validation rules include Step Status instruction presence
# ============================================================
echo ""
echo "--- SC-4: Validation rules include Step Status instruction ---"
# Look for Step Status reference in the Validation Rules section
SC4_CHECK=$(grep -c "Step Status" "$WRITE_MD" 2>/dev/null || true)
echo "  'Step Status' references count = $SC4_CHECK"
if [ "$SC4_CHECK" -ge 2 ]; then
    echo "  → PASS"
else
    echo "  → FAIL (expected ≥ 2 references, got $SC4_CHECK)"
    OVERALL_RESULT=1
fi

# ============================================================
# SC-5: Existing sections renumbered (current 5-9 → 6-10)
# ============================================================
echo ""
echo "--- SC-5: Section numbering (5-9 → 6-10) ---"
# After renumbering, the old section 5 (Phase sections) should be section 6,
# old section 6 (Bottom admonishment) should be section 7, etc.
# Check that "Phase sections" is now listed as section 6
SC5_PHASE=$(grep -c "^6\\. \\*\\*Phase sections" "$WRITE_MD" 2>/dev/null || true)
SC5_BOTTOM=$(grep -c "^7\\. \\*\\*Bottom admonishment" "$WRITE_MD" 2>/dev/null || true)
SC5_SELF=$(grep -c "^8\\. \\*\\*Self-remediation" "$WRITE_MD" 2>/dev/null || true)
SC5_EXIT=$(grep -c "^9\\. \\*\\*Exit Criteria" "$WRITE_MD" 2>/dev/null || true)
SC5_GLOBAL=$(grep -c "^10\\. \\*\\*Global sequential" "$WRITE_MD" 2>/dev/null || true)
echo "  Section 6 (Phase sections): $([ "$SC5_PHASE" -ge 1 ] && echo 'found' || echo 'missing')"
echo "  Section 7 (Bottom admonishment): $([ "$SC5_BOTTOM" -ge 1 ] && echo 'found' || echo 'missing')"
echo "  Section 8 (Self-remediation): $([ "$SC5_SELF" -ge 1 ] && echo 'found' || echo 'missing')"
echo "  Section 9 (Exit Criteria): $([ "$SC5_EXIT" -ge 1 ] && echo 'found' || echo 'missing')"
echo "  Section 10 (Global sequential): $([ "$SC5_GLOBAL" -ge 1 ] && echo 'found' || echo 'missing')"
if [ "$SC5_PHASE" -ge 1 ] && [ "$SC5_BOTTOM" -ge 1 ] && [ "$SC5_SELF" -ge 1 ] && [ "$SC5_EXIT" -ge 1 ] && [ "$SC5_GLOBAL" -ge 1 ]; then
    echo "  → PASS"
else
    echo "  → FAIL (expected all 5 sections renumbered)"
    OVERALL_RESULT=1
fi

# ============================================================
# Report
# ============================================================
echo ""
echo "=== Results ==="
echo "SC-1 (Step Status section): $([ "$SC1_COUNT" -ge 1 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-2 (emoji markers): $([ "$SC2_CHECK" -ge 3 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-3 (edge case rules): $([ "$SC3_CHECK" -ge 2 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-4 (validation rules): $([ "$SC4_CHECK" -ge 2 ] && echo 'PASS' || echo 'FAIL')"
echo "SC-5 (renumbering): $([ "$SC5_PHASE" -ge 1 ] && [ "$SC5_BOTTOM" -ge 1 ] && [ "$SC5_SELF" -ge 1 ] && [ "$SC5_EXIT" -ge 1 ] && [ "$SC5_GLOBAL" -ge 1 ] && echo 'PASS' || echo 'FAIL')"
echo ""

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: test-1579-step-status-instruction (all SCs pass — GREEN phase)"
else
    echo "FAIL: test-1579-step-status-instruction (expected RED behavior — change not yet applied)"
fi

exit $OVERALL_RESULT
