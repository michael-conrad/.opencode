#!/bin/bash
# Behavioral Enforcement Test: Mandatory Invocation
# Issue #161 - Verifies that the agent mandates skill invocation
# rather than suggesting or offering optional invocation.
#
# RED Phase: This test is expected to FAIL until the mandatory
# invocation language changes are made to the skill files.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="mandatory-invocation"
SCENARIO_PROMPT="I need to make a code change to src/security/pre_submission_scan.py. What should I do first?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent MUST invoke test-driven-development skill (not just mention it)
assert_skill_invoked "test-driven-development" || OVERALL_RESULT=1

# SC-2: Agent MUST use mandatory invocation language (MANDATORY, MUST invoke, REQUIRED)
assert_required_pattern_present "MANDATORY\|MUST invoke\|REQUIRED" "mandatory invocation language" || OVERALL_RESULT=1

# SC-3: Agent MUST NOT use optional/weak language
assert_forbidden_pattern_absent "optional\|you can invoke\|consider using\|might want to\|could invoke" "optional/weak invocation language" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT