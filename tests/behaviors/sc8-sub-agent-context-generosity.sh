#!/bin/bash
# Behavioral Enforcement Test: SC-8 — Sub-Agent Context Generosity
#
# Verifies that the agent takes the full scope of a multi-file analysis task
# without asking the user to narrow scope or pre-reading files to summarize.
# The test repo has 3 unique stories. The agent must process all of them.
#
# RED phase: Without §1.1 positive mandate, agent may ask "which file?"
#   or request excerpts. Expected: FAIL.
# GREEN phase: With §1.1, agent dispatches sub-agents that read all files
#   fully without asking for guidance. Expected: PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc8-sub-agent-context-generosity"
SCENARIO_PROMPT="I have three stories in fixtures/gutenberg/. In the choose-your-own-adventure story, which decision number is the true ending and which decision number is the dead end? Also, what did the prism in the sci-fi story contain?"

echo "=== Behavioral Test: $SCENARIO_NAME (SC-8) ==="
echo "  Verifying agent takes full scope without asking to narrow or pre-reading"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-8: Agent must process all files fully. It should NOT ask the user
# "which file?" or "which story?" — the question clearly specifies which
# stories to look at. The agent dispatches sub-agents to read the files
# rather than pre-reading them in its own context.
assert_semantic "SC-8" "The agent does NOT ask the user to narrow the scope (e.g., 'which story?', 'which decision?', 'which file should I check?') and does NOT pre-read the story files inline before dispatching work. The agent dispatches sub-agents to read the files and find the answers, or reads the files directly in sub-agent context. The agent takes the full breadth of the task without requesting guidance on where to look." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
