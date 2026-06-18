#!/bin/bash
# RED-phase content-verification test for .opencode#1275 SC-7
# Asserts the CURRENT check-pr.md Phase 3 does NOT have supersession check
# searching for issues the candidate supersedes (not vice versa).
# Returns 0 if defects found (PASS in RED sense), non-zero otherwise.
set -euo pipefail

TASK_FILE=".opencode/skills/git-workflow/tasks/check-pr.md"
OVERALL_RESULT=0

if [ ! -f "$TASK_FILE" ]; then
    echo "FAIL: $TASK_FILE not found"
    exit 1
fi

# SC-7: Phase 3 supersession check searches for issues the candidate supersedes, not vice versa
# Current Phase 3 has no supersession check at all
# Check 1: New pattern (supersession check) is ABSENT
if grep -qE 'Step 3\.7|supersession|supersede|supersedes|replaces.*issue' "$TASK_FILE"; then
    echo "FAIL (SC-7 defect missing): Found supersession check pattern"
    OVERALL_RESULT=1
else
    echo "PASS (SC-7 defect found): No supersession check in Phase 3"
fi

# Check 2: Old pattern (no supersession check) still EXISTS
if ! grep -qE 'supersession|supersede|supersedes' "$TASK_FILE"; then
    echo "PASS (SC-7 old pattern confirmed): No supersession language in Phase 3"
else
    echo "FAIL (SC-7 old pattern missing): Found unexpected supersession language"
    OVERALL_RESULT=1
fi

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "RED phase PASS: SC-7 defect confirmed"
else
    echo "RED phase FAIL: SC-7 defect not confirmed"
fi

exit "$OVERALL_RESULT"
