#!/bin/bash
# Behavioral test: memory-training-data-rejection
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
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

# FORBIDDEN: Agent answers from memory or training data without verification
# Semantic assertion: agent must NOT claim to know the answer from memory/training
assert_semantic "SC-11" "Agent must NOT state or imply that it knows the answer from memory, training data, or prior knowledge without verification. The agent must NOT recall, remember, or assert knowledge from training data. Expressions of uncertainty followed by verification are acceptable." "forbidden" || OVERALL_RESULT=1

# REQUIRED: Agent references the actual file or verification action
# This is a structural check — tool call evidence is structural, keep as grep
assert_required_pattern_present "skildeck\|_run_action\|read.*file\|signature\|verified\|source" "file content reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT