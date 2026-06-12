#!/usr/bin/env bash
# SC-1: Verify no split(".")[0] truncation in .ts plugin files
# SC-3: Verify buildSkillIndex() uses full s.description
# RED: should FAIL (truncation still exists)
# GREEN: should PASS (truncation removed)

SCRIPT_DIR="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

fail_count=0

# SC-1: Check for first-sentence truncation pattern split(".")[0]
if grep -qE 'split\("\.\s*"\)\s*\[0\]' "$REPO_DIR/plugins/session-enforcement.ts"; then
    echo "SC-1 FAIL: truncation pattern 'split(\".\")[0]' found in session-enforcement.ts"
    ((fail_count++))
else
    echo "SC-1 PASS: no truncation pattern found"
fi

# SC-3: Check that s.description (not shortDesc) is used in the template
if grep -q 'shortDesc' "$REPO_DIR/plugins/session-enforcement.ts"; then
    echo "SC-3 FAIL: 'shortDesc' still referenced in session-enforcement.ts"
    ((fail_count++))
else
    echo "SC-3 PASS: full s.description used"
fi

if [ "$fail_count" -gt 0 ]; then
    echo "OVERALL: FAIL ($fail_count SCs failed)"
    exit 1
fi
echo "OVERALL: PASS"
exit 0