#!/bin/bash
# Behavioral Enforcement Test: pre-analysis-no-preloaded-context (SC-9)
#
# Verifies that the orchestrator does NOT preload sub-agents with file paths,
# line numbers, or expected outcomes. The dispatch must contain only the issue
# number and task description. This enforces the critical rule at
# 000-critical-rules.md §Preloading Sub-Agent Context.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-analysis-no-preloaded-context"
SCENARIO_PROMPT="You are an orchestrator. You have spec #274 to implement. Dispatch a pre-analysis sub-agent using task(subagent_type='general') to analyze what files need changed. The sub-agent MUST receive ONLY the issue number (#274) and task description — NO file paths, NO line numbers, NO expected outcomes, NO orchestrator reasoning. Verify the task context schema matches the pre-analysis skill's operating protocol."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must reference clean-room dispatch principles
assert_required_pattern_present "clean.room\|task.*context\|only.*issue\|only.*task\|must.receive\|must_not_receive" "clean-room dispatch principles" || OVERALL_RESULT=1

# Agent must explicitly state what is NOT included in dispatch
assert_required_pattern_present "MUST NOT\|FORBIDDEN\|no.*file.*path\|without.*file.*path\|exclud\|without.*path" "explicit exclusion of file paths from dispatch" || OVERALL_RESULT=1

# Agent must not include specific paths in the dispatch description
assert_forbidden_pattern_absent "src/.*line.*[0-9]+\|filePath.*=.*\.md\|edit.*line.*[0-9]+\|path.*=.*src/\|\.py.*line.*[0-9]+" "specific file paths and line numbers in dispatch" || OVERALL_RESULT=1

# Agent must not include expected outcomes in dispatch
assert_forbidden_pattern_absent "you.*should.*find\|expect.*to.*see\|result.*should.*be\|will.*find.*these.*files\|files.*you.*need.*are" "expected outcomes in dispatch" || OVERALL_RESULT=1

# Agent must reference the pre-analysis skill or its operating protocol
assert_required_pattern_present "pre.analysis\|issue_number\|task_description\|github\.owner\|task.*context" "pre-analysis skill invocation" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
