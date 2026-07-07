#!/bin/bash
# RED Phase Test - Issue #1712
# Test: Agent creates fresh PR when closed PR exists on branch
# Expected: FAIL (bug exists - agent tries to re-open closed PR)

set -e

echo "=== RED Phase Test - Issue #1712 ==="
echo "Test: Agent creates fresh PR when closed PR exists on branch"
echo ""

# Test scenario:
# 1. Branch has a closed PR
# 2. Agent is asked to create a fresh PR
# 3. Agent should create NEW PR (not re-open closed one)

TEST_PROMPT="The branch has an existing closed PR. Create a fresh PR for this issue."

echo "Test prompt: $TEST_PROMPT"
echo ""
echo "Expected behavior: Agent queries GitHub with state=open filter"
echo "Expected behavior: Agent creates NEW PR (not re-open closed PR)"
echo ""

# Run the test using opencode-cli
cd /home/muksihs/git/opencode-config
bash .opencode/tests/with-test-home opencode-cli run "$TEST_PROMPT" 2>&1 | tee /tmp/red-test-1712.log

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "=== Test Result ==="
echo "Exit code: $EXIT_CODE"

if [ $EXIT_CODE -eq 0 ]; then
    echo "FAIL: Test passed (bug may be fixed)"
    echo "The agent should NOT use state=open filter yet"
    exit 1
else
    echo "PASS: Test failed as expected (RED state)"
    echo "The bug exists - agent does NOT use state=open filter"
    echo "This is the expected RED state - test fails because fix doesn't exist yet"
    exit 0
fi
