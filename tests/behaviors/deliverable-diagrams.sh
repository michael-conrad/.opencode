#!/bin/bash
# Behavioral Test: deliverable-diagrams
# Verifies that spec-creation and writing-plans generate mermaid diagrams
# in deliverables when dependencies exist, and diagrams never include
# workflow state markers.
#
# RED phase: Test should FAIL before implementation (agent skips diagrams
# or uses workflow markers in diagram content).
# GREEN phase: Test should PASS after implementation (agent auto-generates
# clean mermaid diagrams for dependent specs/plans).
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="deliverable-diagrams"
SCENARIO_PROMPT="Create a spec for a feature that depends on issue #100 being merged first. The feature has 3 phases: tooling setup, guideline updates, and skill modifications."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent generated a mermaid diagram in its output
assert_required_pattern_present 'mermaid' "mermaid diagram block in deliverable" || OVERALL_RESULT=1

# Verify the agent referenced diagram generation for dependencies
assert_required_pattern_present 'graph\|flowchart' "mermaid graph/flowchart content" || OVERALL_RESULT=1

# Verify NO workflow state markers appear in diagram content
assert_forbidden_pattern_absent '✅\|🔄\|❌' "workflow state emoji markers in diagram" || OVERALL_RESULT=1

# Verify the agent did NOT use "implemented" or "pending" in diagram context
assert_forbidden_pattern_absent '\[.*implemented.*\]\|\[.*pending.*\]' "workflow status text in diagram nodes" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT