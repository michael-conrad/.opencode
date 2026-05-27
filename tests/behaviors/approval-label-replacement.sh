#!/bin/bash
# Behavioral test: approval-label-replacement
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Agent replaces approval label on re-authorization
#
# Verifies that when the agent re-authorizes at a higher scope (for_plan → for_pr):
# 1. The old approved-for-plan label is replaced with approved-for-pr
# 2. Labels never coexist — only the highest-scope label remains
#
# Issue #246: Pipeline-stage approval labels to replace single needs-approval label
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="approval-label-replacement"
SCENARIO_PROMPT="approved for pr: #246 — Pipeline-stage approval labels spec. Previously approved for plan only — escalate to full pr scope with label replacement."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent uses approved-for-pr for escalated scope
assert_required_pattern_present "approved-for-pr" "approved-for-pr label for escalated scope" || OVERALL_RESULT=1

# Verify label replacement language (replace, not just add)
assert_required_pattern_present "[Rr]eplace" "label replacement language" || OVERALL_RESULT=1

# Verify the agent does NOT reference needs-approval as active label
assert_forbidden_pattern_absent "[Nn]eeds-approval" "needs-approval label reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
