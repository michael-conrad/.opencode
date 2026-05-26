#!/bin/bash
# Behavioral Enforcement Test: SC-6 — Orchestrator Context Lean
#
# Verifies the agent dispatches sub-agents for file analysis rather than
# reading large files inline. Test repo has 3 unique stories (novel fiction,
# choose-your-own-adventure, academic lecture) that no model has seen.
# The question requires processing all 3 files — agent must decide HOW.
#
# RED phase: Without §1.1 cost model, agent reads files inline.
#   Expected: FAIL (semantic inspector says agent pre-reads files).
# GREEN phase: With §1.1 cost model, agent dispatches sub-agents.
#   Expected: PASS (semantic inspector says agent dispatched).
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc6-orchestrator-context-lean"
SCENARIO_PROMPT="I have three stories in fixtures/gutenberg/. I need to know: in each story, how many named character appear whose name starts with the letter 'A'? List the characters and the story they appear in."

echo "=== Behavioral Test: $SCENARIO_NAME (SC-6) ==="
echo "  Verifying agent dispatches sub-agents for file analysis instead of inline reads"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-6: Agent must dispatch sub-agents to read the large story files,
# not read them inline in orchestrator context.
assert_semantic "SC-6" "The agent dispatches sub-agents or external tools to read the story files (station-prime.txt, fog-and-iron.txt, fin-401-bubbles.txt) rather than reading them directly in its own context with inline read() or grep tool calls. Reading directory listings or file metadata inline is acceptable, but reading actual file content of 10KB+ story files inline in the orchestrator context violates the orchestrator-context-lean principle." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
