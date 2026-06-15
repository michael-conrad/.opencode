#!/bin/bash
# Content-verification test: 1228-content-verify-compliance
# Verifies structural presence of compliance statement mandate in task files.
#
# SC-5 (string): The compliance statement uses the exact wording specified
#   in the spec. Content-verification confirms structural presence.
#
# RED phase: grep returns 0 matches (text doesn't exist yet) → exit 1 (FAIL)
# GREEN phase: grep returns ≥ 1 match per file → exit 0 (PASS)
#
# Issue #1228: Mandate compliance statement in every spec and plan body

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

OVERALL_RESULT=0

echo "=== Content-Verification Test: 1228-content-verify-compliance ==="
echo ""

# SC-1: spec-creation/tasks/write.md contains compliance statement mandate
WRITE_MD="$PROJECT_ROOT/.opencode/skills/spec-creation/tasks/write.md"
COUNT_WRITE=$(grep -c "Compliance Requirement" "$WRITE_MD" 2>/dev/null || true)
COUNT_WRITE="${COUNT_WRITE:-0}"
echo "SC-1: write.md 'Compliance Requirement' count = $COUNT_WRITE"
if [ "$COUNT_WRITE" -ge 1 ] 2>/dev/null; then
    echo "  → PASS"
else
    echo "  → FAIL (expected ≥ 1, got $COUNT_WRITE)"
    OVERALL_RESULT=1
fi

# SC-2: writing-plans/tasks/create/create-and-validate.md contains compliance statement mandate
PLAN_MD="$PROJECT_ROOT/.opencode/skills/writing-plans/tasks/create/create-and-validate.md"
COUNT_PLAN=$(grep -c "Compliance Requirement" "$PLAN_MD" 2>/dev/null || true)
COUNT_PLAN="${COUNT_PLAN:-0}"
echo "SC-2: create-and-validate.md 'Compliance Requirement' count = $COUNT_PLAN"
if [ "$COUNT_PLAN" -ge 1 ] 2>/dev/null; then
    echo "  → PASS"
else
    echo "  → FAIL (expected ≥ 1, got $COUNT_PLAN)"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "Result: PASS"
else
    echo "Result: FAIL"
fi

exit $OVERALL_RESULT
