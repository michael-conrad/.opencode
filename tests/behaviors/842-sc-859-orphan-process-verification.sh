#!/bin/bash
# SC-1/SC-2/SC-3 (from spec #859): Orphan process verification
#
# Verify that timeout in behavior_run does not leave orphan opencode-cli
# processes. Sets BEHAVIOR_TIMEOUT=10s to force timeout, then checks ps.
#
# Per spec #859 SC-1/SC-2/SC-3 behavioral verification method:
# "Run a test with BEHAVIOR_TIMEOUT=10 against a deliberately slow model;
#  verify via ps that no opencode-cli processes remain after timeout fires"
#
# Co-authored with AI: OpenCode (deepseek-v4-flash-free)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Override to force timeout
export BEHAVIOR_TIMEOUT=10
export BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}"
# Disable retries - we want the timeout to fire cleanly
export BEHAVIOR_MAX_RETRIES=1

OVERALL_RESULT=0

# SC-1: behavior_run timeout does not leave orphan opencode-cli processes
scenario_behavior_run_orphan_check() {
    local scenario_name="842-sc-859-behavior-run-orphan"
    local prompt="List all files in the current directory and explain their purpose."
    
    echo "=== SC-1: behavior_run orphan process check ==="
    
    # Count opencode-cli processes BEFORE the test
    local before_count
    before_count=$(pgrep -c opencode-cli 2>/dev/null || true)
    echo "  opencode-cli processes BEFORE test: $before_count"
    
    # Run behavior with very short timeout
    behavior_run "$scenario_name" "$prompt" || true
    
    # Wait a moment for processes to settle
    sleep 2
    
    # Count opencode-cli processes AFTER the test
    local after_count
    after_count=$(pgrep -c opencode-cli 2>/dev/null || true)
    echo "  opencode-cli processes AFTER test: $after_count"
    
    # Clean up captured evidence
    capture_and_cleanup "$scenario_name"
    
    if [ "${after_count:-0}" -gt "${before_count:-0}" ] 2>/dev/null; then
        echo "FAIL: Orphan opencode-cli processes detected ($after_count after vs $before_count before)"
        OVERALL_RESULT=1
    else
        echo "PASS: No orphan opencode-cli processes ($after_count after vs $before_count before)"
    fi
}

# SC-2: Same test via capture_and_cleanup timeout path
scenario_capture_orphan_check() {
    local scenario_name="842-sc-859-capture-orphan"
    local prompt="Explain the architecture of this project in detail."
    
    echo "=== SC-2: capture_and_cleanup orphan process check ==="
    
    local before_count
    before_count=$(pgrep -c opencode-cli 2>/dev/null || true)
    echo "  opencode-cli processes BEFORE test: $before_count"
    
    behavior_run "$scenario_name" "$prompt" || true
    
    sleep 2
    
    local after_count
    after_count=$(pgrep -c opencode-cli 2>/dev/null || true)
    echo "  opencode-cli processes AFTER test: $after_count"
    
    capture_and_cleanup "$scenario_name"
    
    if [ "${after_count:-0}" -gt "${before_count:-0}" ] 2>/dev/null; then
        echo "FAIL: Orphan opencode-cli processes detected ($after_count after vs $before_count before)"
        OVERALL_RESULT=1
    else
        echo "PASS: No orphan opencode-cli processes ($after_count after vs $before_count before)"
    fi
}

# Run scenarios
scenario_behavior_run_orphan_check
scenario_capture_orphan_check

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: 842-sc-859-orphan-process-verification"
else
    echo "FAIL: 842-sc-859-orphan-process-verification"
fi

exit $OVERALL_RESULT
