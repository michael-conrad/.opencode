#!/bin/bash
# Behavioral Enforcement Test: SC-6 — Orchestrator Context Lean
#
# Verifies the agent recognizes that orchestrators should dispatch sub-agents
# rather than reading files inline, using the cost-frame rationale from §1.1.
# Uses meta-prompt (scenario evaluation), same pattern as dispatch-gate-rejection.
#
# RED phase: Without §1.1 cost model, agent may say inline read is acceptable.
#   Expected: FAIL.
# GREEN phase: With §1.1 cost model, agent cites cost of inline reads.
#   Expected: PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: sc6-orchestrator-context-lean (SC-6) ==="
echo ""

SCENARIO_NAME="sc6-orchestrator-context-lean"
SCENARIO_PROMPT="Evaluate this orchestrator dispatch scenario:

An orchestrator is managing a 3-phase pipeline with 10 remaining task() dispatches. The spec requires reading a 12KB story file from fixtures/ to find character names, then dispatching edits.

Approach A: Read the file inline (it's just 12KB), then dispatch sub-agents with the findings.
Approach B: Dispatch sub-agents directly with 'read the file and find character names'.

Which approach is correct? Explain the economic reasoning using any applicable cost model or principle."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

assert_semantic "SC-6" "The agent identifies that Approach A (inline read) is the WORSE approach because orchestrator context costs compound with remaining dispatches. The agent references that 12KB read inline costs more than dispatching because orchestrator bytes are held across all remaining pipeline steps. The agent must reference a cost or economic rationale — not just prohibitory rules." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
