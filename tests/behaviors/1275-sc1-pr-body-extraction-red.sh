#!/bin/bash
# RED-phase content-verification test for .opencode#1275 SC-1
# Asserts the CURRENT check-pr.md Phase 3 does NOT extract #N from PR body
# without requiring Fixes/Closes prefix.
# Returns 0 if defects found (PASS in RED sense), non-zero otherwise.
set -euo pipefail

TASK_FILE=".opencode/skills/git-workflow/tasks/check-pr.md"
OVERALL_RESULT=0

if [ ! -f "$TASK_FILE" ]; then
    echo "FAIL: $TASK_FILE not found"
    exit 1
fi

# SC-1: Phase 3 must extract #N from PR body without Fixes/Closes prefix
# Current Phase 3 searches the wrong direction (issues referencing PR, not PR body #N)
# Check 1: New pattern (Step 3.1 — dedicated PR body extraction step) is ABSENT
if grep -qE 'Step 3\.1|Extract Issue References from PR Body' "$TASK_FILE"; then
    echo "FAIL (SC-1 defect missing): Found Step 3.1 PR body extraction step"
    OVERALL_RESULT=1
else
    echo "PASS (SC-1 defect found): No Step 3.1 PR body extraction step"
fi

# Check 2: Old pattern (wrong-direction search) still EXISTS
if grep -qE 'open issues referencing the PR number' "$TASK_FILE"; then
    echo "PASS (SC-1 old pattern confirmed): Wrong-direction search still present"
else
    echo "FAIL (SC-1 old pattern missing): Wrong-direction search not found"
    OVERALL_RESULT=1
fi

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "RED phase PASS: SC-1 defect confirmed"
else
    echo "RED phase FAIL: SC-1 defect not confirmed"
fi

exit "$OVERALL_RESULT"
