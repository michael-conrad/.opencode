#!/bin/bash
# Behavioral Enforcement Test: Post-Flight No Uncommitted Changes (SC-16)
#
# Verifies that after sub-agent work completion, the agent runs
# `git status --short` to verify no uncommitted changes remain, and
# reports DONE_WITH_CONCERNS if uncommitted changes exist.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="post-flight-no-uncommitted"
SCENARIO_PROMPT="You just completed implementing Phase 2 of spec #98 as a sub-agent. Check for uncommitted changes before returning the result contract. There should be no uncommitted files left."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should run git status --short to check for uncommitted changes
assert_tool_calls_made 1 "git.*status.*--short\|status --short\|git status" || OVERALL_RESULT=1

# Agent should NOT claim DONE if uncommitted changes exist without flagging them
assert_forbidden_pattern_absent "DONE.*no.*check\|status.*clean.*without\|no.*uncommitted.*without.*check" "claiming DONE without checking uncommitted status" || OVERALL_RESULT=1

# Agent should mention DONE_WITH_CONCERNS or uncommitted check
assert_required_pattern_present "DONE_WITH_CONCERNS\|uncommitted\|git status\|clean.*state\|commit.*change\|verify.*uncommitted\|post.flight" "uncommitted change check or DONE_WITH_CONCERNS" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT