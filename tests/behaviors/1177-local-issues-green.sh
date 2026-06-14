#!/bin/bash
# 1177-local-issues-green.sh — GREEN test for local-issues repo resolution fix
set -e

echo "=== GREEN Phase Test: local-issues repo resolution ==="
echo ""

OVERALL_RESULT=0

# SC-1: Bare --number mutation must fail with qualifier help
echo "--- SC-1: Bare --number create rejected with qualifier help ---"
cd /home/muksihs/git/opencode-config
output=$(uv run .opencode/tools/local-issues create --number 9997 --title "test" --labels "test" 2>&1 || true)

if echo "$output" | grep -q "Error: bare number"; then
    echo "  PASS: bare number rejected"
else
    echo "  FAIL: bare number was not rejected"
    OVERALL_RESULT=1
fi

if echo "$output" | grep -q "Available qualifiers"; then
    echo "  PASS: qualifiers listed in error"
else
    echo "  FAIL: qualifiers not listed"
    OVERALL_RESULT=1
fi

# SC-2: Qualified .opencode#N create -> creates in .opencode/.issues/
echo "--- SC-2: Qualified .opencode#N creates in .opencode/.issues/ ---"
rm -rf /home/muksihs/git/opencode-config/.opencode/.issues/9997* 2>/dev/null || true
output2=$(uv run .opencode/tools/local-issues create --number ".opencode#9997" --title "test-qualified" --labels "test" 2>&1 || true)

if [ -d "/home/muksihs/git/opencode-config/.opencode/.issues/9997-test-qualified" ]; then
    echo "  PASS: directory created in .opencode/.issues/"
else
    echo "  FAIL: directory not created"
    echo "  output: $output2"
    OVERALL_RESULT=1
fi

# SC-3: Parent repo issues still work (no regression)
echo "--- SC-3: Parent repo qualified create still works ---"
rm -rf /home/muksihs/git/opencode-config/.issues/9996* 2>/dev/null || true
output3=$(uv run .opencode/tools/local-issues create --number "opencode-config#9996" --title "test-parent-green" --labels "test" 2>&1 || true)

if [ -d "/home/muksihs/git/opencode-config/.issues/9996-test-parent-green" ]; then
    echo "  PASS: parent repo create still works"
else
    echo "  FAIL: parent repo create broken"
    OVERALL_RESULT=1
fi

# Cleanup
rm -rf /home/muksihs/git/opencode-config/.opencode/.issues/9997* /home/muksihs/git/opencode-config/.issues/9996* 2>/dev/null || true

echo ""
echo "=== GREEN Phase Results ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "ALL SCs PASS"
else
    echo "FAILURES DETECTED"
fi
exit $OVERALL_RESULT