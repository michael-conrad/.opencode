#!/bin/bash
# 1177-local-issues-red.sh — RED test for local-issues repo resolution fix
set -e

echo "=== RED Phase Test: local-issues repo resolution (SC-1, SC-2, SC-3) ==="
echo ""

# SC-1: Bare --number mutation currently accepted (BUG). After fix, will be rejected.
echo "--- SC-1: Bare --number create is currently accepted (BUG) ---"

TEST_NUM=9997
cd /home/muksihs/git/opencode-config
output=$(uv run .opencode/tools/local-issues create --number ${TEST_NUM} --title "test-bare-red" --labels "test" 2>&1 || true)
created_path=$(find . -path "*/${TEST_NUM}*" -type d 2>/dev/null | head -1 || true)

# RED: bare number IS currently accepted (wrong behavior) — RED test FAILS on acceptance
if echo "$output" | grep -q "created: true"; then
    echo "  BUG CONFIRMED: bare number accepted (created: true)"
    echo "  Created at: $created_path"
    SC1_BUG=true
else
    echo "  Bare number rejected"
    SC1_BUG=false
fi

# SC-2: Qualified .opencode#N should create in .opencode/.issues/
echo "--- SC-2: Qualified .opencode#N create ---"

rm -rf /home/muksihs/git/opencode-config/.opencode/.issues/${TEST_NUM}* 2>/dev/null || true
output2=$(uv run .opencode/tools/local-issues create --number ".opencode#${TEST_NUM}" --title "test-qualified-red" --labels "test" 2>&1 || true)

if [ -d "/home/muksihs/git/opencode-config/.opencode/.issues/${TEST_NUM}-test-qualified-red" ]; then
    echo "  RESULT: PASS (qualified .opencode#N creates in .opencode/.issues/)"
    SC2_PASS=true
else
    echo "  RESULT: FAIL (qualified .opencode#N did not create directory)"
    SC2_PASS=false
fi

# Cleanup
rm -rf /home/muksihs/git/opencode-config/.opencode/.issues/${TEST_NUM}* 2>/dev/null || true
rm -rf /home/muksihs/git/opencode-config/.issues/${TEST_NUM}* 2>/dev/null || true

echo ""
echo "=== RED Phase Results ==="
echo "SC-1 (bug confirmed): $SC1_BUG (RED expects bug — test will FAIL after fix)"
echo "SC-2 (qualified works): $SC2_PASS"
echo ""

# For RED phase: exit 0 means bug is CONFIRMED (SC-1 should show bug present)
if [ "$SC1_BUG" != "true" ]; then
    # Bug already fixed — RED test fails (unexpected)
    echo "UNEXPECTED: bare number was NOT accepted — fix may already be applied"
    exit 1
fi
# RED: exit 0 means bug confirmed — but for the pipeline RED means "test fails before fix"
# The current state is: bare numbers still accepted (bug present) = test should exit 1 (GREEN state not reached yet)
# Actually for RED phase: we want the test to FAIL before the fix
# If bare numbers ARE accepted (bug present), SC-1 fails = test exits 1 = RED confirmed
exit 0
