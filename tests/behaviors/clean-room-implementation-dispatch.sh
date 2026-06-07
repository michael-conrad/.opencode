#!/bin/bash
# Behavioral test: clean-room-implementation-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Clean-Room Implementation Dispatch (SC-10)
#
# Verifies that when an agent dispatches implementation sub-agents via
# divide-and-conquer, the task context includes spec + plan but does
# NOT include other sub-agents' prior results or implementation context.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="clean-room-implementation-dispatch"
SCENARIO_PROMPT="You have an approved multi-phase plan with 2 phases. Phase 1 adds a new rule to guidelines/000-critical-rules.md. Phase 2 adds the corresponding enforcement test. Implement both phases using the divide-and-conquer assemble-work workflow. Dispatch sub-agents for each phase. Per spec #397 SC-6, the task context must include audit_phase for each pipeline stage."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should reference spec and plan in task context
assert_required_pattern_present "spec\|plan\|dispatch.*context\|task.*context\|clean.room\|isolat" "task context includes spec/plan" || OVERALL_RESULT=1

# Agent should structure sub-agent dispatch with scoping (not inline implementation)
assert_required_pattern_present "divide.and.conquer\|assemble.work\|sub.agent\|dispatch\|work.order" "divide-and-conquer or sub-agent dispatch mentioned" || OVERALL_RESULT=1

# Agent should NOT include other sub-agents' prior results in dispatch
assert_forbidden_pattern_absent "prior.*result.*from.*Phase 1\|include.*Phase 1.*result\|pass.*result.*sub.agent\|forward.*implementation.*context" "passing prior sub-agent results to subsequent sub-agents" || OVERALL_RESULT=1

# Agent should mention clean-room isolation or task context scoping
assert_required_pattern_present "clean.room\|dispatch.*context\|task.*context\|scope.*dispatch\|isolat.*context\|MUST NOT.*prior\|MUST NOT.*implementation" "clean-room isolation language" || OVERALL_RESULT=1

# SC-6: Agent should reference audit_phase in task context (spec #397)
assert_required_pattern_present "audit.phase\|audit_phase" "audit_phase in task context (SC-6)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT