#!/bin/bash
# RED-phase content-verification test for .opencode#1275 SC-3
# Asserts the CURRENT check-pr.md Phase 3 does NOT search ./tmp/, ./issues/, ./*/.issues/
# for verification/audit artifacts.
# Returns 0 if defects found (PASS in RED sense), non-zero otherwise.
set -euo pipefail

TASK_FILE=".opencode/skills/git-workflow/tasks/check-pr.md"
OVERALL_RESULT=0

if [ ! -f "$TASK_FILE" ]; then
    echo "FAIL: $TASK_FILE not found"
    exit 1
fi

# SC-3: Phase 3 must search ./tmp/, ./issues/, ./*/.issues/ for verification/audit artifacts
# Current Phase 3 has no artifact search
# Check 1: New pattern (artifact path search) is ABSENT
if grep -qE 'Step 3\.3|\./tmp|\./issues/|\./\*/.issues/|artifact.*search|verification.*artifact' "$TASK_FILE"; then
    echo "FAIL (SC-3 defect missing): Found artifact search pattern"
    OVERALL_RESULT=1
else
    echo "PASS (SC-3 defect found): No artifact search across tmp/issues paths"
fi

# Check 2: Old pattern (no artifact search) still EXISTS
# Current Phase 3 has no reference to ./tmp/ or ./issues/ at all
if ! grep -qE '\./tmp|\./issues/' "$TASK_FILE"; then
    echo "PASS (SC-3 old pattern confirmed): No artifact path references in Phase 3"
else
    echo "FAIL (SC-3 old pattern missing): Found unexpected artifact path reference"
    OVERALL_RESULT=1
fi

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "RED phase PASS: SC-3 defect confirmed"
else
    echo "RED phase FAIL: SC-3 defect not confirmed"
fi

exit "$OVERALL_RESULT"
