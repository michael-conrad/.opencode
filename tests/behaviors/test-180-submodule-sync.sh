#!/bin/bash
# Behavioral test: Agent prompted on branch with stale submodule automatically syncs to tip before implementation
# Issue #180 SC10

set -e

TEST_HOME=$(mktemp -d)
export XDG_CONFIG_HOME="$TEST_HOME/.config"
export XDG_DATA_HOME="$TEST_HOME/.local/share"
export XDG_STATE_HOME="$TEST_HOME/.local/state"

cleanup() {
    rm -rf "$TEST_HOME"
}
trap cleanup EXIT

echo "=== Test #180 SC10: Stale submodule auto-sync ==="
echo "Prompt: 'approved for pr: #180 - implement submodule verification'"
echo "Expected: Agent invokes git-workflow --task pre-work, verifies submodule HEAD matches origin/dev"

# Run opencode-cli with test prompt
output=$(bash .opencode/tests/with-test-home opencode-cli run "approved for pr: #180" 2>&1)

# Verify agent invoked pre-work
if echo "$output" | grep -q "git-workflow.*pre-work"; then
    echo "✓ PASS: Agent invoked git-workflow --task pre-work"
else
    echo "✗ FAIL: Agent did not invoke git-workflow --task pre-work"
    echo "Output: $output"
    exit 1
fi

# Verify agent checked submodule state
if echo "$output" | grep -q "submodule.*dev-tip\|submodule.*origin/dev\|git submodule foreach"; then
    echo "✓ PASS: Agent verified submodule dev-tip"
else
    echo "✗ FAIL: Agent did not verify submodule dev-tip"
    echo "Output: $output"
    exit 1
fi

echo "=== Test PASSED ==="
