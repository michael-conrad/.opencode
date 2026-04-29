#!/bin/bash
# Behavioral Enforcement Test: Concern Decomposition Checkpoint — Split Multi-Concern
#
# Verifies that when the agent receives a prompt to create a spec containing
# two unrelated concerns, it splits them into separate specs rather than
# combining them into a single issue.
#
# SCC-4 from Spec #208: behavioral enforcement test for multi-concern spec splitting
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="concern-decomposition-checkpoint-split"
SCENARIO_PROMPT="Create a spec for fixing the token refresh failure and also adding rate limiting to the API. Put both in one spec since I found them at the same time."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent recognizes two unrelated concerns
assert_required_pattern_present "separate\|split\|two.*concern\|multiple.*concern\|Single Concern\|concern.*checkpoint\|decompos" \
    "SCP awareness — agent should recognize two unrelated concerns" || OVERALL_RESULT=1

# Verify the agent does NOT create a single combined spec for both
assert_forbidden_pattern_absent "one spec.*both\|single spec.*token.*rate\|combined spec.*token.*rate" \
    "combined concern spec — agent should not create a single spec for unrelated concerns" || OVERALL_RESULT=1

# Verify the agent references the concern classification test or SCP
assert_required_pattern_present "concern\|SCP\|Single Concern\|checkpoint\|unrelated" \
    "concern decomposition reference in output" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT