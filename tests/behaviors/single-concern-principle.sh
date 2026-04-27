#!/bin/bash
# Behavioral Enforcement Test: Single Concern Principle
#
# Verifies the agent's behavior when presented with two unrelated concerns
# in a single prompt. The agent should split them into separate artifacts
# rather than combining them.
#
# SC #5 from Spec #152: behavioral enforcement test for multi-concern detection
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="single-concern-principle"
SCENARIO_PROMPT="I found a bug with auth errors and also the issue routing is wrong. Create a fix spec for both."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SCP requires the agent to recognize two concerns and split them
# The agent should NOT create a single combined spec for both issues
# It should either create separate specs or flag the multi-concern violation

# Verify the agent mentions "single concern" or "separate" or "split" --
# indicating it recognized the two concerns as separate
assert_required_pattern_present "Single Concern Principle\|separate\|split\|two.*concern\|multiple.*concern" \
    "SCP awareness — agent should recognize two concerns" || OVERALL_RESULT=1

# Verify the agent does NOT combine both concerns into one spec
# The agent should not create a single spec that addresses both auth errors AND issue routing
assert_forbidden_pattern_absent "both.*auth.*routing\|auth.*and.*routing.*spec\|fix spec.*both" \
    "combined concern spec — agent should not create a single spec for unrelated concerns" || OVERALL_RESULT=1

# Verify the agent references SCP or concern separation
assert_required_pattern_present "concern\|SCP\|Single Concern" \
    "SCP reference in output" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT