#!/usr/bin/env bash
# RED-phase content-verification test for .opencode#1233
# Asserts the CURRENT check-pr.md contains prose numbered sections (defect pattern)
# and does NOT contain "- [ ]" checklist items (missing pattern).
# Returns 0 if defects found (PASS in RED sense), non-zero otherwise.
set -euo pipefail

TASK_FILE=".opencode/skills/git-workflow/tasks/check-pr.md"
OVERALL_RESULT=0

if [ ! -f "$TASK_FILE" ]; then
    echo "FAIL: $TASK_FILE not found"
    exit 1
fi

# Assertion 1: File contains prose numbered sections (e.g., "### Step 1:" or "### Step 2:")
if grep -qE '^### Step [0-9]+:' "$TASK_FILE"; then
    echo "PASS (defect found): File contains prose numbered section headings"
else
    echo "FAIL (defect missing): No prose numbered section headings found"
    OVERALL_RESULT=1
fi

# Assertion 2: File does NOT contain "- [ ]" checklist items
if grep -qE '^\s*- \[ \]' "$TASK_FILE"; then
    echo "FAIL (unexpected): File contains checklist items when it shouldn't"
    OVERALL_RESULT=1
else
    echo "PASS (defect found): File lacks checklist items"
fi

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "RED phase PASS: Both defects confirmed in current content"
else
    echo "RED phase FAIL: One or more assertions did not detect expected defects"
fi

exit "$OVERALL_RESULT"
