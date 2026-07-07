#!/bin/bash
# RED phase: content-verification test for issue #1442
# Verifies the per-criterion YAML template in plan-fidelity.md has
# unconditional `next_step: "proceed"` for ALL criteria (including FAIL).
# This test MUST FAIL now (RED) and PASS after GREEN implementation
# changes next_step to be conditional on result.
set -euo pipefail

OVERALL_RESULT=0
TASK_FILE=".opencode/skills/audit/tasks/plan-fidelity.md"

echo "=== RED Phase: Content-Verification Test ==="
echo "Verifying per-criterion YAML template has unconditional next_step: proceed"
echo "(expecting FAIL — RED — because template currently has unconditional default)"
echo ""

# ============================================================
# SC-1: Template has unconditional next_step: "proceed"
# ============================================================
echo "--- SC-1: Unconditional next_step: proceed in per_criterion template ---"

# Extract the per_criterion YAML block from Step 7
# Look for the pattern: next_step: "proceed" inside the per_criterion section
UNCONDITIONAL_COUNT=$(grep -c 'next_step: "proceed"' "$TASK_FILE" 2>/dev/null || true)

if [ "$UNCONDITIONAL_COUNT" -gt 0 ]; then
    echo "  FOUND: next_step: \"proceed\" appears $UNCONDITIONAL_COUNT time(s) — unconditional default exists"
    echo "  RESULT: FAIL (expected RED — unconditional default still present)"
    SC1_RESULT=1
    OVERALL_RESULT=1
else
    echo "  NOT FOUND: next_step: \"proceed\" has zero matches"
    echo "  RESULT: PASS (unconditional default already removed — unexpected for RED)"
    SC1_RESULT=0
fi

# ============================================================
# SC-2: No conditional next_step logic exists (no re-evaluate for FAIL)
# ============================================================
echo ""
echo "--- SC-2: No conditional next_step: re-evaluate for FAIL ---"

# Check if there's any conditional logic that sets next_step based on result
CONDITIONAL_COUNT=$(grep -c 'next_step.*re-evaluate\|next_step.*re_evaluate\|if.*result.*FAIL.*next_step\|next_step.*conditional' "$TASK_FILE" 2>/dev/null || true)

if [ "$CONDITIONAL_COUNT" -eq 0 ]; then
    echo "  NOT FOUND: No conditional next_step logic — template is unconditional"
    echo "  RESULT: FAIL (expected RED — no conditional logic yet)"
    SC2_RESULT=1
    OVERALL_RESULT=1
else
    echo "  FOUND: Conditional next_step logic appears $CONDITIONAL_COUNT time(s)"
    echo "  RESULT: PASS (conditional logic exists — unexpected for RED)"
    SC2_RESULT=0
fi

# ============================================================
# Report
# ============================================================
echo ""
echo "=== RED Phase Results ==="
echo "SC-1: $([ "$SC1_RESULT" -eq 0 ] && echo "PASS (unconditional default removed)" || echo "FAIL (unconditional default present — expected RED)")"
echo "SC-2: $([ "$SC2_RESULT" -eq 0 ] && echo "PASS (conditional logic exists)" || echo "FAIL (no conditional logic — expected RED)")"

# Write artifact output
mkdir -p "tmp/1442/artifacts"
cat > "tmp/1442/artifacts/red-phase-test-output.log" << EOF
=== RED Phase Test: Plan-Fidelity next_step Conditional ===
SC-1 (unconditional next_step: "proceed"):
  grep count: $UNCONDITIONAL_COUNT
  result: $([ "$SC1_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")

SC-2 (conditional next_step logic for FAIL):
  grep count: $CONDITIONAL_COUNT
  result: $([ "$SC2_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL")

OVERALL: $([ "$OVERALL_RESULT" -eq 0 ] && echo "PASS" || echo "FAIL (expected RED — unconditional default still present)")
EOF

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: 1442-red-plan-fidelity-next-step (all SCs pass — unexpected for RED phase)"
else
    echo "FAIL: 1442-red-plan-fidelity-next-step (expected RED behavior — unconditional default still present)"
fi

exit $OVERALL_RESULT
