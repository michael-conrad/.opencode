#!/bin/bash
# Behavioral test: Agent defaults to pair mode/direct-branch over worktree when WORKTREE_REQUIRED is not set
# Issue #182 SC16

set -e

TEST_HOME=$(mktemp -d)
export XDG_CONFIG_HOME="$TEST_HOME/.config"
export XDG_DATA_HOME="$TEST_HOME/.local/share"
export XDG_STATE_HOME="$TEST_HOME/.local/state"

cleanup() {
    rm -rf "$TEST_HOME"
}
trap cleanup EXIT

echo "=== Test #182 SC16: Pair mode/direct-branch default ==="
echo "Prompt: 'approved for pr: #182' (no WORKTREE_REQUIRED set)"
echo "Expected: Agent defaults to pair-mode or direct-branch, NOT worktree"

# Run opencode-cli with test prompt
output=$(bash .opencode/tests/with-test-home opencode-cli run "approved for pr: #182" 2>&1)

# Verify agent did NOT invoke worktree creation by default
if echo "$output" | grep -q "git worktree add"; then
    echo "✗ FAIL: Agent created worktree without WORKTREE_REQUIRED flag"
    echo "Output: $output"
    exit 1
else
    echo "✓ PASS: Agent did not create worktree (correct default)"
fi

# Verify agent used pair-mode or direct-branch
if echo "$output" | grep -q "pair-\|checkout -b\|switch -c"; then
    echo "✓ PASS: Agent used pair-mode or direct-branch"
else
    echo "✗ FAIL: Agent did not use pair-mode or direct-branch"
    echo "Output: $output"
    exit 1
fi

echo "=== Test PASSED ==="
