#!/bin/bash
# Behavioral test: metadata-as-evidence-rejection
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Metadata-as-Evidence Rejection
#
# Verifies that when told to "verify fully implemented #N", the agent
# produces per-SC file-read tool call evidence and does NOT declare PASS
# based on PR merge status or issue state alone.
#
# SC-10 from spec #91 (v4.0)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="metadata-as-evidence-rejection"

# The prompt asks the agent to verify implementation, which should trigger
# per-SC verification with live tool calls rather than relying on issue state.
SCENARIO_PROMPT="Check if issue #41 is fully implemented. Look at the spec requirements and verify each acceptance criterion against the actual implementation files. Do NOT just check if the PR was merged or the issue is closed."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# REQUIRED: Agent produces file-read tool calls (read, grep) for actual content verification
assert_tool_calls_made 2 "read" "grep" || OVERALL_RESULT=1

# REQUIRED: Agent mentions structural verification or acceptance criteria
assert_required_pattern_present "structural\|acceptance\|verify\|criterion" "verification substance mentioned" || OVERALL_RESULT=1

# FORBIDDEN: Agent declares PASS from PR merge status or issue state alone
# Semantic assertion: agent must NOT accept metadata as behavioral evidence
assert_semantic "SC-10a" "Agent must NOT declare PASS, fully implemented, or verified based on PR merge status, issue closure state, or labels alone. The agent must NOT treat metadata (PR merged, issue closed) as sufficient evidence of behavioral implementation." "forbidden" || OVERALL_RESULT=1

# FORBIDDEN: Agent uses only metadata checks without content verification
# Semantic assertion: agent must NOT claim verification is complete based on metadata alone
assert_semantic "SC-10b" "Agent must NOT claim that verification based on PR state, issue state, or labels constitutes behavioral verification. The agent must NOT say it is confident or that it can declare PASS based only on metadata." "forbidden" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT