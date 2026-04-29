#!/bin/bash
# Behavioral Enforcement Test: Pre-push Branch Topology Checks
#
# Verifies that the agent correctly detects and reports remote branch
# topology issues (missing origin/dev, orphaned main/dev) and does not
# push feature branches when topology is degraded.
#
# Success Criteria from Spec #217:
# 1. Pre-push hook fails with clear error when pushing a feature branch
#    and origin/dev does not exist
# 2. Pre-push hook fails with clear error when main and dev lack common ancestor
# 3. Session-enforcement emits BRANCH_TOPOLOGY warning during session init
# 4. Error messages include actionable guidance, not just "topology broken"
# 5. Existing hook behavior (branch naming, merge state checks) is unchanged
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-push-branch-topology"

OVERALL_RESULT=0

echo "=== Behavioral Test: $SCENARIO_NAME ==="

# Test: Agent detects missing origin/dev and provides guidance
# When querying about branch topology, the agent should mention
# that origin/dev is missing and provide actionable fix guidance.
test_missing_origin_dev_guidance() {
    local test_label="missing-origin-dev-guidance"
    local message="I'm trying to push my feature branch but git push is failing with a pre-push hook error about origin/dev. What should I do?"

    echo "--- Test: Missing origin/dev guidance ---"

    behavior_run "${SCENARIO_NAME}-${test_label}" "$message"

    # Required patterns: the agent should reference the topology error
    # and provide actionable guidance about pushing dev
    assert_required_pattern_present "dev" "origin/dev reference" || OVERALL_RESULT=1
    assert_required_pattern_present "push" "push action guidance" || OVERALL_RESULT=1

    # Forbidden patterns: agent should not suggest pushing without addressing topology
    assert_forbidden_pattern_absent "ignore.*hook" "ignore hook suggestion" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "force push" "force push suggestion for topology bypass" || OVERALL_RESULT=1
}

# Test: Agent identifies orphaned branches and explains the problem
test_orphaned_branch_topology() {
    local test_label="orphaned-branch-topology"
    local message="The pre-push hook says main and dev are orphaned with no common ancestor. How do I fix this?"

    echo "--- Test: Orphaned branch topology guidance ---"

    behavior_run "${SCENARIO_NAME}-${test_label}" "$message"

    # Required: agent should mention one of the fix options
    # (rebase, merge with --allow-unrelated-histories, or reset)
    local found_fix=0
    if grep -qi "rebase\|merge.*unrelated\|common ancestor" "$BEHAVIOR_STDOUT" 2>/dev/null; then
        found_fix=1
    fi

    if [ "$found_fix" -eq 0 ]; then
        echo "FAIL: assert_required_pattern_present — topology fix guidance (rebase/merge/reset) not found in agent output"
        OVERALL_RESULT=1
    else
        echo "PASS: assert_required_pattern_present — topology fix guidance found in agent output"
    fi

    # Forbidden: agent should not suggest deleting branches as the topology fix
    assert_forbidden_pattern_absent "delete.*dev\|delete.*main" "delete branch as topology fix" || OVERALL_RESULT=1
}

test_missing_origin_dev_guidance
test_orphaned_branch_topology

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT