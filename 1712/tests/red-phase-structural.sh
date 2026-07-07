#!/bin/bash
# RED Phase Test - Issue #1712
# Test: enforcement-gate.md Step 1.5 does NOT have state=open filter (RED)
# Expected: FAIL (bug exists - filter is missing)

set -e

echo "=== RED Phase Test - Issue #1712 ==="
echo "Test: enforcement-gate.md Step 1.5 has state=open filter"
echo ""

ENFORCEMENT_GATE="/home/muksihs/git/opencode-config/.opencode/skills/git-workflow/tasks/pr-creation/enforcement-gate.md"

echo "Checking: $ENFORCEMENT_GATE"
echo ""

# Check if state=open filter exists in Step 1.5
if grep -q "state=open" "$ENFORCEMENT_GATE"; then
    echo "PASS: state=open filter found in enforcement-gate.md"
    echo "Bug is FIXED - test PASSES"
    exit 0
else
    echo "FAIL: state=open filter NOT found in enforcement-gate.md"
    echo "Bug EXISTS - test FAILS (RED state)"
    echo ""
    echo "Current Step 1.5 content:"
    grep -A 10 "### Step 1.5:" "$ENFORCEMENT_GATE"
    echo ""
    echo "Expected: state=open filter in PR query"
    echo "This is the RED state - test fails because fix doesn't exist yet"
    exit 1
fi
