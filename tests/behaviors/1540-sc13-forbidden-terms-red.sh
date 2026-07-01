#!/bin/bash
# Content-verification test: SC-13 — No FORBIDDEN terms remain in skill/guideline/test files
# RED phase: should FAIL because FORBIDDEN terms still exist
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.

set -euo pipefail

OVERALL_RESULT=0
SCENARIO_NAME="1540-sc13-forbidden-terms-red"

# Target files to scan for FORBIDDEN terms
TARGET_FILES=(
    ".opencode/skills/git-workflow/SKILL.md"
    ".opencode/skills/pr-creation-workflow/SKILL.md"
    ".opencode/skills/approval-gate/tasks/verify-qa-mode.md"
    ".opencode/README.md"
    ".opencode/tests/behaviors/1540-sc6-no-dev-rules-red.sh"
    ".opencode/tests/behaviors/1540-sc1-prework-no-dev-red.sh"
)

# FORBIDDEN terms per the Terminology Anchor table in the spec
FORBIDDEN_TERMS=(
    "single-path workflow"
    "single-path branch workflow"
    "three-branch model"
    "Three-branch model"
    "three-branch workflow"
)

echo "=== SC-13 RED phase: Checking for FORBIDDEN terms ==="
echo ""

for term in "${FORBIDDEN_TERMS[@]}"; do
    found=false
    for file in "${TARGET_FILES[@]}"; do
        if [ -f "$file" ] && grep -q "$term" "$file" 2>/dev/null; then
            echo "RED PASS: FORBIDDEN term '$term' found in $file (expected — not yet removed)"
            found=true
        fi
    done
    if [ "$found" = false ]; then
        echo "RED FAIL: FORBIDDEN term '$term' NOT found in any target file"
        OVERALL_RESULT=1
    fi
done

echo ""
if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "RED FAIL: Some FORBIDDEN terms were not found — test FAILS as expected for RED phase"
    exit 1
fi
echo "RED PASS: All FORBIDDEN terms found — test FAILS as expected for RED phase"
exit 1  # RED phase MUST fail — FORBIDDEN terms exist but should be removed
