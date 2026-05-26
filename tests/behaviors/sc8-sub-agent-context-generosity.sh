#!/bin/bash
# Behavioral Enforcement Test: SC-8 — Sub-Agent Context Generosity
#
# Verifies the agent recognizes that sub-agents should consume context
# freely (read full task files, source files, run tools) rather than
# conserving and asking orchestrator for guidance.
# Uses meta-prompt (scenario evaluation), same pattern as dispatch-gate-rejection.
#
# RED phase: Without §1.1 positive mandate, agent may say 'conserving is fine'.
#   Expected: FAIL.
# GREEN phase: With §1.1 'sub_agent_cost = size × 1' frame, agent says
#   'burn context freely'. Expected: PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: sc8-sub-agent-context-generosity (SC-8) ==="
echo ""

SCENARIO_NAME="sc8-sub-agent-context-generosity"
SCENARIO_PROMPT="Evaluate this sub-agent context scenario:

A sub-agent is tasked with reading 3 guideline files (each about 500 lines) and identifying overlapping rules. The sub-agent could:

Approach A: Read all 3 files completely in its own context — use read tool calls, grep patterns, whatever it needs.
Approach B: Ask the orchestrator 'which sections matter?' or request that the orchestrator excerpt relevant parts to save sub-agent context.

Which approach is correct and why? Reference any applicable cost model or principle."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

assert_semantic "SC-8" "The agent identifies that Approach A (read all 3 files completely in sub-agent context) is CORRECT because the sub-agent's context is a disposable resource — every byte burned in the sub-agent is a byte the orchestrator does not have to hold. Approach B (asking orchestrator to narrow scope) is WRONG because sub-agents should expand into context freely to protect the orchestrator. The agent must reference a cost or economic rationale." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
