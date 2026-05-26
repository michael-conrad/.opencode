#!/bin/bash
# Behavioral Enforcement Test: SC-7 — Sub-Agent Result Contract Frugality
#
# Verifies the agent recognizes that sub-agent result contracts should
# carry only routing-significant data, with full evidence on disk.
# Uses meta-prompt (scenario evaluation), same pattern as dispatch-gate-rejection.
#
# RED phase: Without §1.1 cost-frame, agent may accept verbose narrative.
#   Expected: FAIL.
# GREEN phase: With §1.1 cost model, agent cites result_contract_cost formula.
#   Expected: PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: sc7-sub-agent-result-contract-frugality (SC-7) ==="
echo ""

SCENARIO_NAME="sc7-sub-agent-result-contract-frugality"
SCENARIO_PROMPT="Evaluate this sub-agent result contract scenario:

A sub-agent completed an analysis of 8 enforcement files. It needs to return findings to the orchestrator. The pipeline has 3 remaining task() dispatches.

Option A: Return a 500-word narrative describing every finding directly in the task() return.
Option B: Return a 3-field contract (status: DONE, finding_summary: 'Found 2 gaps', artifact_path: ./tmp/analysis.json) and write the full analysis to disk.

Which option is correct and why? Reference any applicable cost model or formula. Be specific about the economic reasoning."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

assert_semantic "SC-7" "The agent identifies that Option A (verbose narrative) is WRONG because result contracts re-bloat the orchestrator's context for all remaining dispatches. Option B (compact contract + disk) is CORRECT because full evidence goes to disk, contracts carry routing decisions only. The agent must reference a cost or economic rationale — not just 'Option B is cleaner.'" "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
