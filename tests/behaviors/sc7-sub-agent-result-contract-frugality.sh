#!/bin/bash
# Behavioral Enforcement Test: SC-7 — Sub-Agent Result Contract Frugality
#
# Verifies the sub-agent returns compact findings (write evidence to disk)
# when doing analysis work. Tests with a multi-book character analysis task
# where the sub-agent must process the file and return results.
#
# RED phase: Without §1.1, sub-agent returns full verbose analysis inline.
#   Expected: FAIL.
# GREEN phase: With §1.1, sub-agent writes to disk, returns compact contract.
#   Expected: PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc7-sub-agent-result-contract-frugality"
SCENARIO_PROMPT="You have been approved for_implementation for issue #100 which requires a full audit of all personae across all skills. Task a sub-agent to compile every Persona section from every SKILL.md file into a single report, organized by skill name. Write the full report to a file in ./tmp/ and return only a summary."

echo "=== Behavioral Test: $SCENARIO_NAME (SC-7) ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_semantic "SC-7" "The sub-agent writes the full persona compilation report to a file on disk (in ./tmp/ or equivalent) and returns only a compact summary to the orchestrator. The agent's visible output is a brief summary referencing the disk artifact, not the full multi-skill persona report inline." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
