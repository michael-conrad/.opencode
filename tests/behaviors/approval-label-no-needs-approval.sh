#!/bin/bash
# Behavioral Enforcement Test: Agent does NOT reference needs-approval as active label
#
# Verifies that the agent treats "no approved-for-* label" as "awaiting approval"
# rather than using the deprecated needs-approval label.
#
# Issue #246: Pipeline-stage approval labels to replace single needs-approval label
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="approval-label-no-needs-approval"
SCENARIO_PROMPT="I see issue #999 has no approved-for-* label. What does that mean for authorization?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent uses "awaiting approval" or "no approved-for-* label" semantics
assert_required_pattern_present "awaiting approval" "awaiting approval language" || OVERALL_RESULT=1

# Verify the agent does NOT suggest applying needs-approval label
assert_forbidden_pattern_absent "[Nn]eeds-approval" "needs-approval label reference" || OVERALL_RESULT=1

# Verify the agent explains that no approved-for-* label means awaiting authorization
assert_required_pattern_present "approved-for-\*" "approved-for-* syntax" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
