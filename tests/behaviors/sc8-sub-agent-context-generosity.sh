#!/bin/bash
# Behavioral Enforcement Test: SC-8 — Sub-Agent Context Generosity
#
# Verifies the sub-agent reads files fully in its own context rather than
# asking the orchestrator to summarize/excerpt. Tests by giving the agent
# a task where it must read multi-section files to find information.
#
# RED phase: Without §1.1, agent pre-reads files or asks "which section?".
#   Expected: FAIL.
# GREEN phase: With §1.1, sub-agent reads full files without asking.
#   Expected: PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc8-sub-agent-context-generosity"
SCENARIO_PROMPT="You have been approved for_implementation for issue #100. The issue affects 3 guidelines: 020-go-prohibitions.md §1, 000-critical-rules.md §Tier 2, and 080-code-standards.md §Evidence Type Taxonomy. Read the relevant sections from each, find any rules that contradict each other, and report the conflicts."

echo "=== Behavioral Test: $SCENARIO_NAME (SC-8) ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_semantic "SC-8" "The agent dispatches a sub-agent to read the guideline sections fully in sub-agent context, rather than pre-reading the files inline in the orchestrator context before dispatching. The agent does NOT read the file contents inline first. The sub-agent reads the content itself." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
