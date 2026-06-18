#!/bin/bash
# RED-phase content-verification test for .opencode#1275 SC-8
# Asserts the CURRENT check-pr.md Phase 3 does NOT have depth-first closure
# ordering as a numbered step (Step 3.8).
# Returns 0 if defects found (PASS in RED sense), non-zero otherwise.
set -euo pipefail

TASK_FILE=".opencode/skills/git-workflow/tasks/check-pr.md"
OVERALL_RESULT=0

if [ ! -f "$TASK_FILE" ]; then
    echo "FAIL: $TASK_FILE not found"
    exit 1
fi

# SC-8: Phase 3 must close eligible issues depth-first as a numbered step
# Current Phase 3 has "Close depth-first" as a checklist item, not a step
# Check 1: New pattern (Step 3.8 depth-first closure) is ABSENT
if grep -qE 'Step 3\.8|close.*depth.*first.*step|depth.*first.*closure.*step' "$TASK_FILE"; then
    echo "FAIL (SC-8 defect missing): Found depth-first closure step pattern"
    OVERALL_RESULT=1
else
    echo "PASS (SC-8 defect found): No depth-first closure ordering as numbered step"
fi

# Check 2: Old pattern (checklist item) still EXISTS
if grep -qE 'Close depth-first' "$TASK_FILE"; then
    echo "PASS (SC-8 old pattern confirmed): Depth-first closure is a checklist item, not a step"
else
    echo "FAIL (SC-8 old pattern missing): Depth-first closure reference not found"
    OVERALL_RESULT=1
fi

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "RED phase PASS: SC-8 defect confirmed"
else
    echo "RED phase FAIL: SC-8 defect not confirmed"
fi

exit "$OVERALL_RESULT"
