#!/bin/bash
# Behavioral test: post-flight-no-cached-claims
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Post-Flight No Cached Claims (SC-18)
#
# Verifies that a verification sub-agent does NOT use memory-based
# claims ("I recall", "as noted earlier") and that verification
# claims reference tool-call artifacts.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="post-flight-no-cached-claims"
SCENARIO_PROMPT="You are a verification sub-agent for spec #98. Verify that the clean-room dispatch rules are implemented correctly. Check the guidelines file 000-critical-rules.md for the clean-room mandate section, verify the skill file exists, and check that the behavioral test files are present. Use only live verification - do not rely on memory."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should NOT use memory-based claims
assert_forbidden_pattern_absent "I recall\|as noted earlier\|from.*previous.*session\|I remember\|from memory\|cached.*result\|I checked earlier" "memory-based or cached claims instead of live verification" || OVERALL_RESULT=1

# Agent should reference tool calls for verification claims
assert_required_pattern_present "tool.call\|verified.*via\|read.*file\|grep\|glob\|srclight\|confirmed.*by\|verified.*using\|checked.*with" "tool-call artifact references for verification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT