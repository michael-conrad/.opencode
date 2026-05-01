#!/bin/bash
# Behavioral Enforcement Test: pre-analysis-autonomous-discover-full-scope (SC-7)
#
# Verifies that a pre-analysis sub-agent independently discovers the full scope
# of affected files when dispatched with only an issue number and task description.
# The sub-agent must search beyond the obvious paths specified in the plan and
# find all files affected by the change.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-analysis-autonomous-discover-full-scope"
SCENARIO_PROMPT="Dispatch a pre-analysis sub-agent for the following task: add a context-hash audit trail to the pre-analysis skill. The issue is spec #274 in michael-conrad/.opencode. The pre-analysis sub-agent must receive ONLY the issue number and task description — it must independently search the codebase to discover all affected files, including the analyze.md task file, the SKILL.md file, and any related test infrastructure. Return only the dispatch plan with all discovered files listed."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must demonstrate independent codebase search (not just parroting back provided paths)
assert_required_pattern_present "search\|grep\|glob\|discover\|find\|enumerate\|scan\|lookup" "independent codebase search actions" || OVERALL_RESULT=1

# Agent must identify files beyond the initial task description scope
assert_required_pattern_present "analyze\.md\|SKILL\.md\|completion\.md\|task.*file" "task files discovered" || OVERALL_RESULT=1

# Agent must reference discovered files list
assert_required_pattern_present "discovered\|affected.*files\|found.*files\|file.*scope" "discovered files enumeration" || OVERALL_RESULT=1

# Agent must produce a structured plan (not free text)
assert_required_pattern_present "partition\|dispatch.*plan\|PLAN_READY\|task_actions\|concern" "structured dispatch plan" || OVERALL_RESULT=1

# Agent must NOT ask the orchestrator for file paths
assert_forbidden_pattern_absent "which.*file.*should\|tell.*me.*which.*file\|what.*file.*to.*edit\|provide.*the.*file.*path" "requesting file paths from orchestrator" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
