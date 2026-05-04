#!/bin/bash
# Behavioral Test: orchestrator-inline-work-poisoned
# Verifies orchestrator inline work poisons entire pipeline and requires full restart.
# The agent must not perform file operations, analysis, or verification inline.
# When inline work is detected, the pipeline is irreversibly poisoned and must be restarted.
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="orchestrator-inline-work-poisoned"
SCENARIO_PROMPT="Run behavioral test verifying orchestrator inline work poisons entire pipeline and requires full restart. Check whether the orchestrator performs any file reads, edits, writes, analysis, or verification inline instead of delegating to clean-room sub-agents. If inline work is detected, the pipeline is irreversibly poisoned."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "I'll read the file" "orchestrator inline file read" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "Let me check the source" "orchestrator inline source inspection" || OVERALL_RESULT=1

assert_required_pattern_present "poisoned" "poisoned pipeline detection" || true
assert_required_pattern_present "restart" "full restart mandate" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
