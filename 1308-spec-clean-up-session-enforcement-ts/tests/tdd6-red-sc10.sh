#!/bin/bash
# Behavioral test: tdd6-red-sc10
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# TDD-6 RED: First-turn injection fires on first user message in a fresh session (SC-10)
# RED condition: Verify that opencode-cli run with a single-turn prompt shows
# no enforcement/injection blocks in first-turn context.
# The test FAILS (exit non-zero) when injection blocks ARE present.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
SCENARIO_NAME="tdd6-red-sc10"
ARTIFACT_DIR="$PROJECT_ROOT/tmp/1308/artifacts/tdd6-red-sc10"
mkdir -p "$ARTIFACT_DIR"

echo "=== RED Phase Test: TDD-6 First-turn injection fires on first user message (SC-10) ==="
echo ""

# Run opencode-cli with a single-turn prompt
bash "$PROJECT_ROOT/.opencode/tests/with-test-home" opencode-cli run "hello" --log-level INFO --print-logs \
    > "$ARTIFACT_DIR/stdout.log" 2> "$ARTIFACT_DIR/stderr.log" \
    || true

echo "Stderr file: $ARTIFACT_DIR/stderr.log"
echo ""

# Check for injection blocks in stderr
# The remaining injection content that should still fire on first turn includes:
# - Session Triggers block
# - Plugin Diagnostics block
# - NESTED_OPENCODE_FATAL block
INJECTION_FOUND=false

if grep -q "Session Triggers" "$ARTIFACT_DIR/stderr.log" 2>/dev/null; then
    echo "  FOUND: Session Triggers injection block in stderr"
    INJECTION_FOUND=true
fi

if grep -q "Plugin Diagnostics" "$ARTIFACT_DIR/stderr.log" 2>/dev/null; then
    echo "  FOUND: Plugin Diagnostics injection block in stderr"
    INJECTION_FOUND=true
fi

if grep -q "NESTED_OPENCODE_FATAL" "$ARTIFACT_DIR/stderr.log" 2>/dev/null; then
    echo "  FOUND: NESTED_OPENCODE_FATAL block in stderr"
    INJECTION_FOUND=true
fi

echo ""
if [ "$INJECTION_FOUND" = true ]; then
    echo "FAIL: Injection blocks ARE present in first-turn context"
    echo "  RED condition (injection missing) NOT met — test FAILS"
    exit 1
else
    echo "PASS: No injection blocks found in first-turn context"
    echo "  RED condition (injection missing) confirmed"
    exit 0
fi
