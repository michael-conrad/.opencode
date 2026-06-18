#!/bin/bash
# RED-phase content-verification test for .opencode#1275 SC-2
# Asserts the CURRENT check-pr.md Phase 3 does NOT extract #N from commit messages.
# Returns 0 if defects found (PASS in RED sense), non-zero otherwise.
set -euo pipefail

TASK_FILE=".opencode/skills/git-workflow/tasks/check-pr.md"
OVERALL_RESULT=0

if [ ! -f "$TASK_FILE" ]; then
    echo "FAIL: $TASK_FILE not found"
    exit 1
fi

# SC-2: Phase 3 must extract #N from all commits in each merged PR
# Current Phase 3 has no dedicated commit message scan step
# Check 1: New pattern (Step 3.2 — dedicated commit message extraction step) is ABSENT
if grep -qE 'Step 3\.2|Extract Issue References from Commit Messages' "$TASK_FILE"; then
    echo "FAIL (SC-2 defect missing): Found Step 3.2 commit message extraction step"
    OVERALL_RESULT=1
else
    echo "PASS (SC-2 defect found): No Step 3.2 commit message extraction step"
fi

# Check 2: Old pattern (no dedicated commit scan) still EXISTS
# Current Phase 3 only mentions "commit messages" in passing within a single checklist item
if grep -qE 'commit messages' "$TASK_FILE"; then
    echo "PASS (SC-2 old pattern confirmed): Commit messages only mentioned in passing, no dedicated step"
else
    echo "FAIL (SC-2 old pattern missing): No commit message reference at all"
    OVERALL_RESULT=1
fi

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "RED phase PASS: SC-2 defect confirmed"
else
    echo "RED phase FAIL: SC-2 defect not confirmed"
fi

exit "$OVERALL_RESULT"
