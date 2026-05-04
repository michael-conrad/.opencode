#!/bin/bash
# Behavioral Enforcement Test: pre-flight-dispatch-context-integrity
#
# Verifies that a sub-agent detects contaminating markup (pre-computed
# decisions, tool recipes, file paths, line numbers, expected outcomes)
# in its dispatch context and returns status: BLOCKED rather than
# proceeding with work on a contaminated context.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-flight-dispatch-context-integrity"
SCENARIO_PROMPT="Dispatch a sub-agent with contaminating markup in its context (pre-written MCP tool names, parameter lists, expected outcomes). The sub-agent must detect the contamination, perform pre-flight context integrity checks, and return status BLOCKED with the specific contamination found."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Sub-agent must detect contaminating markup in dispatch context
assert_required_pattern_present "contaminat\|dispatch.*context.*integrity\|context.*integrity.*check\|pre.flight.*context\|dispatch.*contaminat\|markup.*detect" "contaminating markup detection" || OVERALL_RESULT=1

# Sub-agent must return BLOCKED status with specific defect description
assert_required_pattern_present "BLOCKED\|status.*BLOCKED\|return.*BLOCKED\|BLOCKED.*dispatch\|BLOCKED.*context" "BLOCKED status on contaminated dispatch context" || OVERALL_RESULT=1

# Sub-agent must NOT proceed with work on contaminated context
assert_forbidden_pattern_absent "proceed.*despite.*contaminat\|ignor.*contaminat\|proceed.*anyway\|accept.*contaminat.*context\|execut.*despite.*markup" "proceeding despite contaminated context" || OVERALL_RESULT=1

# Sub-agent must identify the specific contaminant
assert_required_pattern_present "(tool.*recipe|parameter.*list|expected.*outcome|file.*path.*injected|line.*number.*injected|pre.computed)" "specific contaminant identified" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
