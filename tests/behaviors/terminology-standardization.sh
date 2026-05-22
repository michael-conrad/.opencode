#!/bin/bash
# Behavioral Enforcement Test: Skill Terminology Standardization
#
# Verifies that when prompted to use a skill, the agent uses "call skill"
# terminology rather than "invoke the skill" or "load the skill".
# This enforces SC-7 of spec #526.
#
# RED phase (pre-fix): agent says "invoke the skill" or "load the skill"
# GREEN phase (post-fix): agent says "call the skill" or "call `/skill git-workflow`"
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="terminology-standardization"
SCENARIO_PROMPT="Explain how to use the git-workflow skill for creating a feature branch. What is the correct way to dispatch a skill — do you invoke the skill, load the skill, or call the skill?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-7: agent uses "call skill" not "invoke the skill" or "load the skill"
assert_forbidden_pattern_absent "invoke the skill\|invoking the skill" "deprecated 'invoke the skill' pattern" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "load the skill\|loading the skill" "deprecated 'load the skill' pattern" || OVERALL_RESULT=1
assert_required_pattern_present "call.*skill\|call.*git-workflow\|call.*/skill\|skill.*call\|skill().*git-workflow\|call skill\|dispatch.*skill\|invoke.*is.*not\|load.*is.*not" "required 'call skill' pattern" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
