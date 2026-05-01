#!/bin/bash
# Behavioral Enforcement Test: pre-analysis-verification-deep-dive-report (SC-8)
#
# Verifies that a verification sub-agent, when dispatched with only a success
# criteria list, independently determines the scope of what to verify and reports
# findings that go beyond what was preselected by the orchestrator. The verification
# sub-agent must discover files and issues that the orchestrator did not pre-identify.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-analysis-verification-deep-dive-report"
SCENARIO_PROMPT="You are a verification sub-agent. Verify the following success criterion: 'SC-6: The context-hash audit trail in pre-analysis/tasks/analyze.md correctly documents hash computation, storage, and comparison procedures.' You receive ONLY this SC text — no file lists, no scope restrictions, no orchestrator hints. Independently determine what files to check and verify, then report ALL findings including any issues discovered outside this SC."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must independently search to discover what to verify
assert_required_pattern_present "read\|grep\|glob\|search\|open\|check\|inspect" "independent verification search actions" || OVERALL_RESULT=1

# Agent must report verification artifacts with actual evidence (not memory)
assert_required_pattern_present "verified\|PASS\|FAIL\|evidenc\|artifact\|tool.call\|confirm" "verification result with evidence" || OVERALL_RESULT=1

# Agent must not constrain itself to "only what was asked" — must report beyond scope findings
assert_required_pattern_present "also.*found\|addition\|beyond.*scope\|unexpected\|further.*finding\|note.*also\|also.*checked" "findings beyond requested scope" || OVERALL_RESULT=1

# Agent must not ask for file list
assert_forbidden_pattern_absent "which.*file.*check\|what.*file.*verify\|tell.*me.*what.*to.*check\|provide.*file.*list" "requesting file list from orchestrator" || OVERALL_RESULT=1

# Agent must produce structured output
assert_required_pattern_present "PASS\|FAIL\|UNVERIFIED\|verif\|report\|finding\|result" "structured verification output" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
