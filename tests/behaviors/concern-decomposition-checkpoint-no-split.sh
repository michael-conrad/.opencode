#!/bin/bash
# Behavioral Enforcement Test: Concern Decomposition Checkpoint — No Unnecessary Split
#
# Verifies that when the agent receives a prompt to create a spec for a
# single concern (even though it mentions multiple aspects), the agent
# does NOT unnecessarily split it into separate specs.
#
# SCC-5 from Spec #208: behavioral enforcement test for single-concern preservation
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="concern-decomposition-checkpoint-no-split"
SCENARIO_PROMPT="Create a spec for fixing the token refresh failure that causes auth errors and session drops. Both symptoms come from the same root cause — the refresh token not being renewed when it expires."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent does NOT attempt to split a single-concern spec
assert_forbidden_pattern_absent "split.*spec\|separate spec\|two.*spec\|multiple.*spec\|need.*separate\|must.*separate.*issue" \
    "unnecessary split — agent should not split a single-concern spec" || OVERALL_RESULT=1

# Verify the agent recognizes this as a single concern with shared root cause
assert_required_pattern_present "single concern\|same root cause\|related concern\|one concern\|single.*spec\|same cause" \
    "single-concern recognition — agent should recognize shared root cause" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT