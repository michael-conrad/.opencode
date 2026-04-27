#!/bin/bash
# Behavioral Enforcement Test: Memory/Training Data Rejection
#
# Verifies that when asked a factual code/API question, the agent
# produces srclight_get_signature or file-read tool call evidence
# and does NOT answer from memory or training data alone.
#
# SC-11 from spec #91 (v4.0)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="memory-training-data-rejection"

# The prompt asks about code behavior, forcing the agent to verify
# against live sources rather than recalling from training data.
SCENARIO_PROMPT="What does the _run_action function in .opencode/tools/skildeck do? What are its parameters and return type? Verify your answer against the actual source code."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# REQUIRED: Agent produces verification tool calls (file read, signature lookup, grep)
assert_tool_calls_made 1 "read\|get_signature\|grep\|srclight" "verification tool calls" || OVERALL_RESULT=1

# FORBIDDEN: Agent answers without any tool call evidence
# Check that the output is NOT purely from memory (no tool call evidence)
assert_forbidden_pattern_absent "I recall\|from my training\|I remember\|as far as I know\|based on my knowledge" "memory/training data as evidence" || OVERALL_RESULT=1

# REQUIRED: Agent references the actual file or verification action
assert_required_pattern_present "skildeck\|_run_action\|read.*file\|signature\|verified\|source" "file content reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT