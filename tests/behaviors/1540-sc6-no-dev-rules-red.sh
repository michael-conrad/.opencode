#!/bin/bash
# Content-verification test: SC-6 — No dev-specific rules remain in git-workflow/SKILL.md
# RED phase: should FAIL because "trunk-based" and dev-mandatory patterns still exist

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.opencode/tests/behaviors/helpers.sh"

OVERALL_RESULT=0
SCENARIO_NAME="1540-sc6-no-dev-rules-red"
TARGET_FILE=".opencode/skills/git-workflow/SKILL.md"

# RED phase: these patterns should be PRESENT (test FAILS because they exist)
# After GREEN phase, these patterns should be ABSENT

# Check for "trunk-based" pattern
if grep -q "trunk-based" "$TARGET_FILE" 2>/dev/null; then
    echo "RED PASS: 'trunk-based' pattern found in $TARGET_FILE (expected — not yet removed)"
else
    echo "RED FAIL: 'trunk-based' pattern NOT found in $TARGET_FILE"
    OVERALL_RESULT=1
fi

# Check for dev-only PR routing
if grep -q "feature/\\* → dev" "$TARGET_FILE" 2>/dev/null; then
    echo "RED PASS: 'feature/* → dev' routing found (expected — not yet removed)"
else
    echo "RED FAIL: 'feature/* → dev' routing NOT found"
    OVERALL_RESULT=1
fi

# Check for dev-only compare URL
if grep -q "compare/dev" "$TARGET_FILE" 2>/dev/null; then
    echo "RED PASS: 'compare/dev' pattern found (expected — not yet removed)"
else
    echo "RED FAIL: 'compare/dev' pattern NOT found"
    OVERALL_RESULT=1
fi

# Check for "main`/`dev" protected branches
if grep -q "main.*dev" "$TARGET_FILE" 2>/dev/null; then
    echo "RED PASS: 'main/dev' protected branches found (expected — not yet removed)"
else
    echo "RED FAIL: 'main/dev' protected branches NOT found"
    OVERALL_RESULT=1
fi

# RED phase: exit 1 if any pattern was NOT found (test FAILS because patterns should exist)
if [ "$OVERALL_RESULT" -ne 0 ]; then
    echo "RED FAIL: Some expected patterns were not found"
    exit 1
fi
echo "RED PASS: All expected dev-specific patterns found — test FAILS as expected for RED phase"
exit 1  # RED phase MUST fail — patterns exist but should be removed
