#!/bin/bash
# Behavioral Enforcement Test: Orchestrator Context Size (SC-8)
#
# Verifies orchestrator system prompt contains ≤2500 words of guideline/skill content.
# The plugin should inject INDEX.md (~534 words) instead of full guideline bodies (67K words).
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="orchestrator-context-size"
SCENARIO_PROMPT="What tools are available for reading guidelines? Answer briefly."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify GUIDELINE_INDEX block is present (plugin injects INDEX.md)
assert_required_pattern_present "GUIDELINE_INDEX" "guideline index injection" || OVERALL_RESULT=1

# Verify agent does NOT have full guideline bodies in context (trigger_on pattern is in INDEX.md but full body would be much larger)
# The agent should reference INDEX.md or use the guidelines tool, not cite full guideline body content
assert_forbidden_pattern_absent "Critical Violation: Direct-Branch Default" "full critical-rule body in orchestrator context" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
