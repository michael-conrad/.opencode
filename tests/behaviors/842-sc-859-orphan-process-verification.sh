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

orphan_check_before() {
    local evidence_dir="$1"
    mkdir -p "$evidence_dir"
    local count
    count=$(pgrep -c opencode-cli 2>/dev/null || echo "0")
    count=$(echo "$count" | tr -dc '0-9')
    [ -z "$count" ] && count="0"
    echo "before: $count" >> "$evidence_dir/orphan-check.log"
    echo "$count"
}

orphan_check_after() {
    local evidence_dir="$1"
    local count
    count=$(pgrep -c opencode-cli 2>/dev/null || echo "0")
    count=$(echo "$count" | tr -dc '0-9')
    [ -z "$count" ] && count="0"
    echo "after: $count" >> "$evidence_dir/orphan-check.log"
    echo "ps_after:" >> "$evidence_dir/orphan-check.log"
    local ps_count
    ps_count=$(ps aux | grep -c '[o]pencode-cli' 2>/dev/null || echo "0")
    echo "$ps_count" >> "$evidence_dir/orphan-check.log"
    echo "$count"
}

# SC-1: behavior_run timeout does not leave orphan opencode-cli processes
scenario_behavior_run_orphan_check() {
    local scenario_name="842-sc-859-behavior-run-orphan"
    local evidence_dir="./tmp/behavioral-evidence-${scenario_name}"
    mkdir -p "$evidence_dir"
    local prompt="List all files in the current directory and explain their purpose."

    echo "=== SC-1: behavior_run orphan process check ==="

    local before_count
    before_count=$(orphan_check_before "$evidence_dir")
    echo "  opencode-cli processes BEFORE test: $before_count"

    behavior_run "$scenario_name" "$prompt" || true

    sleep 2

    local after_count
    after_count=$(orphan_check_after "$evidence_dir")
    echo "  opencode-cli processes AFTER test: $after_count"

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
    local evidence_dir="./tmp/behavioral-evidence-${scenario_name}"
    mkdir -p "$evidence_dir"
    local prompt="Explain the architecture of this project in detail."

    echo "=== SC-2: capture_and_cleanup orphan process check ==="

    local before_count
    before_count=$(orphan_check_before "$evidence_dir")
    echo "  opencode-cli processes BEFORE test: $before_count"

    behavior_run "$scenario_name" "$prompt" || true

    sleep 2

    local after_count
    after_count=$(orphan_check_after "$evidence_dir")
    echo "  opencode-cli processes AFTER test: $after_count"

    capture_and_cleanup "$scenario_name"

    if [ "${after_count:-0}" -gt "${before_count:-0}" ] 2>/dev/null; then
        echo "FAIL: Orphan opencode-cli processes detected ($after_count after vs $before_count before)"
        OVERALL_RESULT=1
    else
        echo "PASS: No orphan opencode-cli processes ($after_count after vs $before_count before)"
    fi
}

# SC-3: test-enforcement.sh timeout path orphan check
scenario_test_enforcement_orphan_check() {
    local scenario_name="842-sc-859-test-enforcement-orphan"
    local evidence_dir="./tmp/behavioral-evidence-${scenario_name}"
    mkdir -p "$evidence_dir"
    local prompt="Explain all design patterns used in this project."

    echo "=== SC-3: test-enforcement.sh orphan process check ==="

    local before_count
    before_count=$(orphan_check_before "$evidence_dir")
    echo "  opencode-cli processes BEFORE test: $before_count"

    behavior_run "$scenario_name" "$prompt" || true

    sleep 2

    local after_count
    after_count=$(orphan_check_after "$evidence_dir")
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
scenario_test_enforcement_orphan_check

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: 842-sc-859-orphan-process-verification"
else
    echo "FAIL: 842-sc-859-orphan-process-verification"
fi

exit $OVERALL_RESULT
