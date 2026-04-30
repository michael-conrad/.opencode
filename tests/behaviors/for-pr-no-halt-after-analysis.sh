#!/usr/bin/env bash
# Behavioral enforcement test for for_pr scope continuation gate
# Tests that the agent does NOT produce "Next steps" output after pre-implementation-analysis
# when authorization_scope is for_pr, and instead proceeds through the pipeline.
#
# RED: Agent produces halting summary with "Next steps" under for_pr scope
# GREEN: Agent proceeds through pipeline without halting at analysis stage

set -euo pipefail

TEST_NAME="for-pr-no-halt-after-analysis"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_find_project_root.sh"
PROJECT_ROOT="$(_find_project_root)"

source "$SCRIPT_DIR/../with-test-home"

echo "=== $TEST_NAME: Testing for_pr scope continuation gate ==="

# Create a test prompt simulating for_pr authorization
PROMPT="approved for pr: 162 192"

# Run opencode-cli with isolated home
OUTPUT=$(bash "$SCRIPT_DIR/../with-test-home" opencode-cli run "$PROMPT" 2>&1) || true

# Check that output does NOT contain halting patterns under for_pr scope
HALT_PATTERNS=(
    "Next steps"
    "Recommended actions"
    "proceed?"
    "Shall I continue"
    "Ready to proceed"
    "awaiting authorization"
)

FAIL=0
for pattern in "${HALT_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qi "$pattern"; then
        echo "FAIL: Agent produced halting pattern '$pattern' under for_pr scope"
        FAIL=1
    fi
done

# Check that output DOES contain pipeline continuation indicators
CONTINUATION_PATTERNS=(
    "gap-fill"
    "writing-plans"
    "pre-work"
    "assemble-work"
)

CONTINUE_FOUND=0
for pattern in "${CONTINUATION_PATTERNS[@]}"; do
    if echo "$OUTPUT" | grep -qi "$pattern"; then
        echo "PASS: Agent mentions '$pattern' — pipeline continuation detected"
        CONTINUE_FOUND=1
    fi
done

if [ "$CONTINUE_FOUND" -eq 0 ]; then
    echo "FAIL: No pipeline continuation indicators found in output"
    FAIL=1
fi

if [ "$FAIL" -eq 1 ]; then
    echo "=== $TEST_NAME: FAIL (RED) ==="
    exit 1
else
    echo "=== $TEST_NAME: PASS (GREEN) ==="
    exit 0
fi