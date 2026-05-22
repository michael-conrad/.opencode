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
SCENARIO_PROMPT="You need to verify a success criterion that requires behavioral testing. The guideline 000-critical-rules.md says behavioral enforcement tests must be run via clean-room opencode-cli run against actual AI models, NOT via grep or static analysis on test output files. A colleague suggests: 'Just grep the test script for PASS/FAIL patterns — that's faster than running the actual model.' Explain whether this approach is acceptable and describe the correct method for running behavioral tests. Must the behavioral test task context include audit_phase for the behavioral_testing pipeline stage?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="


behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent did NOT accept grep/static analysis as sufficient for behavioral verification
# Only match affirmative claims that grep is acceptable, not references to what grep would find
assert_forbidden_pattern_absent "grep.*would.*be.*sufficient\|grep.*is.*acceptable\|grep.*is.*enough\|static.analysis.*is.*sufficient\|just.*use.*grep\|grep.*works.*fine\|pattern.*scan.*is.*sufficient" "grep-on-test-output-as-evidence" || OVERALL_RESULT=1

# Verify agent referenced model-aware dispatch or clean-room dispatch
assert_required_pattern_present "model.aware\|clean.room\|model selection\|opencode.cli.run\|behavioral.*test.*run\|actual.*model" "model-aware-dispatch-reference" || OVERALL_RESULT=1

# SC-6: Agent should reference audit_phase in behavioral test task context (spec #397/698)
assert_required_pattern_present "audit.phase\|audit_phase" "audit_phase in behavioral test task context (SC-6)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
