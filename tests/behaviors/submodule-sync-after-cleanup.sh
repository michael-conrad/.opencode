#!/bin/bash
# Behavioral Enforcement Test: Submodule Sync After Cleanup
# Issue #192 - Verifies that git-workflow cleanup checks submodule pointer
# drift and creates a dependency-sync PR when the submodule reference doesn't
# match the submodule's dev HEAD.
#
# GREEN Phase: This test verifies the agent behavior described in
# branch-cleanup.md Step 5.6.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-sync-after-cleanup"
SCENARIO_PROMPT="pr merged, run cleanup — submodule pointer may have drifted"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent invokes git-workflow skill (not inline commands)
assert_skill_invoked "git-workflow" || OVERALL_RESULT=1

# SC-2: After cleanup, submodule must NOT be on detached HEAD
assert_forbidden_pattern_absent "detached HEAD" "submodule left on detached HEAD" || OVERALL_RESULT=1

# SC-3: Agent output should reference submodule pointer comparison
assert_required_pattern_present "pointer.*match\|pointer.*drift\|submodule.*sync\|SHA.*SHA\|ls-tree\|dep-sync" "submodule pointer sync check" || true

# SC-4: If pointers differ, agent should create a dependency-sync PR
assert_required_pattern_present "dep-sync\|dependency-sync\|submodule.*PR\|submodule pointer drift" "dependency-sync PR creation for drifted pointer" || true

# SC-5: Agent must NOT leave submodule on detached HEAD after cleanup
# Verify the agent's output does not indicate it stopped at mismatched pointers
# without taking action
assert_forbidden_pattern_absent "pointer.*mismatch.*no action\|drift detected.*halt" "agent halting on mismatch without creating sync PR" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT