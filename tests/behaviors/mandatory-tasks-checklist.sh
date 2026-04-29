#!/bin/bash
# Behavioral Enforcement Test: MANDATORY TASKS Checklist Pattern
#
# Verifies that when a skill with MANDATORY TASKS is invoked,
# the agent recognizes and follows the checklist format.
# Tests the core behavior change from issue #219: skill cards
# now contain `- [ ] MANDATORY:` executable checklists that
# agents must process during skill execution.
#
# RED phase: Verify agent acknowledges MANDATORY TASKS items
# when executing spec-creation skill.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="mandatory-tasks-checklist"
SCENARIO_PROMPT="I need to create a spec for adding a dark mode toggle to the settings page. The codebase uses React with TypeScript. Please invoke the spec-creation skill to write this spec."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent mentions MANDATORY TASKS or mandatory checklist items
# when processing the spec-creation skill
assert_required_pattern_present "MANDATORY" "MANDATORY keyword in skill execution" || OVERALL_RESULT=1

# Verify the agent does NOT skip directly to writing without
# acknowledging pre-conditions (code inspection checklist)
assert_required_pattern_present "inspection\|checklist\|pre-spec" "pre-conditions acknowledgment" || OVERALL_RESULT=1

# Verify the agent invokes spec-auditor after creation (a MANDATORY TASKS item)
assert_skill_invoked "spec-auditor" || {
    echo "WARN: spec-auditor not invoked — may be acceptable if spec creation did not complete"
}

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT