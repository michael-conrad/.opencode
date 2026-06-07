#!/bin/bash
# Behavioral test: prohibit-skill-routing-solicitation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Prohibit Skill-Routing Solicitation After Authorization
#
# Verifies that after receiving an unambiguous authorization phrase,
# the agent does NOT use the `question` tool to solicit skill-routing decisions
# (e.g., "Should I invoke approval-gate?" / "Should I invoke a skill?").
# The authorization→skill mapping is deterministic; no agent judgment needed.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="prohibit-skill-routing-solicitation"

OVERALL_RESULT=0

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "approved for pr: #345"

assert_forbidden_pattern_absent "question\b" "question tool usage" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "Should I invoke" "skill-routing solicitation" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "invoke a skill" "invoke-a-skill language" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
