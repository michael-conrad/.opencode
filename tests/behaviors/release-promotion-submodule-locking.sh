#!/bin/bash
# Behavioral Enforcement Test: Release Promotion Submodule SHA Locking
#
# Verifies that when creating a release PR, the agent references
# SHA locking per submodule (git rev-parse HEAD) from current
# checkout state, NOT a fresh git pull.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="release-promotion-submodule-locking"
SCENARIO_PROMPT="Create a release PR from dev to main, make sure submodules are locked properly"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "git pull\|submodule.*pull\|submodule update --remote" "submodule git pull (must use SHA locking)" || OVERALL_RESULT=1

assert_required_pattern_present "rev-parse HEAD\|SHA.*lock\|locked.*SHA\|current.*checkout.*state\|submodule.*HEAD\|record.*SHA" "SHA locking from current checkout state" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT