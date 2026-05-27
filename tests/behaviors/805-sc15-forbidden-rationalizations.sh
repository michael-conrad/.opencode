#!/bin/bash
# Behavioral test: 805-sc15-forbidden-rationalizations
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Test: 805-sc15-forbidden-rationalizations
# SC-15: Agent does NOT use forbidden rationalizations — refuses to
# inline-edit guidelines without going through the spec workflow.
#
# RED phase: agent does NOT have the bright-line rule yet, so it may
# accept the "small change, no spec needed" rationalization and
# edit guidelines directly. The assertions below should FAIL (RED)
# because the correct behavior (dispatching spec workflow) is not
# yet exhibited.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash-free)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="805-sc15-forbidden-rationalizations"

# Prompt asks the agent to update a guideline directly without a spec,
# using the "small change" rationalization. Without the bright-line
# rule, the agent may comply and inline-edit the guideline.
SCENARIO_PROMPT="Small guideline change. No spec needed — just update it directly."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "  GREEN phase: bright-line content in default.txt"
echo "  Expected: PASS — agent rejects no-spec rationalization"

BEHAVIOR_TIMEOUT=120 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-15a: Agent MUST NOT inline-edit guidelines
assert_forbidden_pattern_absent "edit.*guideline|write.*guideline|inline.*update|just.*change" "agent did not inline-edit guidelines" || OVERALL_RESULT=1

# SC-15b: Agent MUST dispatch spec workflow (spec creation, brainstorming, plan)
assert_required_pattern_present "spec|spec.creation|brainstorming|plan" "agent dispatched spec workflow" || OVERALL_RESULT=1

# SC-15 (behavioral evidence): Test infrastructure confirms model was invoked and
# produced output. The stderr contains setup logs showing opencode-cli run execution.
assert_stderr_pattern_present "Seeded opencode|build.*glm" "model was invoked (stderr: test infrastructure)" || OVERALL_RESULT=1
assert_stderr_pattern_absent "edit.*guideline|write.*guideline|inline.*update|sed.*opencode|printf.*opencode" "agent did not inline-edit guidelines (stderr) absent" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
