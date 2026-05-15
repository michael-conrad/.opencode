#!/bin/bash
# Behavioral Enforcement Test: model-aware-clean-room-dispatch
#
# Tests that behavioral enforcement tests are run via clean-room opencode-cli run
# against actual AI models, NOT via grep/pattern scanning on test output files.
#
# Verification: opencode-cli run "run behavioral test for model-aware dispatch"
# → agent must dispatch sub-agent with model selection, NOT grep/read on test output
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   Guideline lacks model-aware rule → agent greps output files instead
#   GREEN: 000-critical-rules.md §Model-Aware Clean-Room Dispatch exists → agent dispatches model
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="model-aware-clean-room-dispatch"
SCENARIO_PROMPT="run behavioral test for model-aware dispatch and verify the agent dispatches clean-room opencode-cli run instead of grepping test output files. Per spec #397 SC-6, the behavioral test task context must include audit_phase for the behavioral_testing pipeline stage."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent dispatched opencode-cli run with a model (not just grep)
assert_tool_calls_made 1 "opencode-cli" "ollama-model-resolve" "skill.*behavior" || OVERALL_RESULT=1

# Verify agent did NOT use grep on test output as the primary evidence
assert_forbidden_pattern_absent "grep.*PASS.*FAIL" "grep-on-test-output-as-evidence" || OVERALL_RESULT=1

# Verify agent referenced model-aware dispatch
assert_required_pattern_present "(model-aware|clean-room|model selection|ollama-model|model_resolution)" "model-aware-dispatch-reference" || OVERALL_RESULT=1

# SC-6: Agent should reference audit_phase in behavioral test task context (spec #397)
assert_required_pattern_present "audit.phase\|audit_phase" "audit_phase in behavioral test task context (SC-6)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
