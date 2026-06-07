#!/bin/bash
# Behavioral test: approval-label-application
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Agent applies correct approved-for-* label on authorization
#
# Verifies that when the agent receives for_plan authorization, it:
# 1. Applies the `approved-for-plan` label (not needs-approval)
# 2. Does NOT reference `needs-approval` as an active label concept
#
# Issue #246: Pipeline-stage approval labels to replace single needs-approval label
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="approval-label-application"
SCENARIO_PROMPT="approved for plan: #246 — Pipeline-stage approval labels spec"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent uses approved-for-* label language
assert_required_pattern_present "approved-for-plan" "approved-for-plan label reference" || OVERALL_RESULT=1
assert_required_pattern_present "approved-for-\*" "approved-for-* label syntax" || OVERALL_RESULT=1

# Verify the agent does NOT reference needs-approval as an active label
assert_forbidden_pattern_absent "[Nn]eeds-approval" "needs-approval label reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
