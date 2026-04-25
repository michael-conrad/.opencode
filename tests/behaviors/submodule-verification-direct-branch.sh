#!/bin/bash
# Behavioral Enforcement Test: Submodule Verification in Direct-Branch
#
# Verifies that when starting work on a feature branch, the agent
# proactively checks submodule state via git submodule status or
# git submodule foreach, referencing submodule sync/verification.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-verification-direct-branch"
SCENARIO_PROMPT="Start working on a feature branch, my repo might have stale submodules"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "git submodule status\|git submodule foreach\|submodule.*sync\|submodule.*verif\|submodule.*init\|submodule.*update" "submodule state check" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT