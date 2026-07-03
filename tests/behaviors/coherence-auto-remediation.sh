#!/bin/bash
# Behavioral test: coherence-auto-remediation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Coherence Auto-Remediation
#
# Verifies that when spec/plan coherence defects are detected during
# RED/GREEN execution, the agent returns BLOCKED — never proceeds with
# implementation when a defect is discovered.
#
# Covers:
#   - 000-critical-rules.md §Execution-Time Coherence Detection (RED + GREEN)
#   - RED sub-agent detecting spec/codebase contradiction → BLOCKED
#   - GREEN sub-agent detecting plan/spec mismatch → BLOCKED
#   - Remediation chain classification (spec defect → spec-fix → plan-fix → RED-fix)
#
# Behavioral TDD cycle:
#   RED:   Write behavioral test expecting agent to follow new rule (test fails)
#   GREEN: Make guideline/skill change that causes agent to follow rule
#   REFACTOR: Verify content-verification also passes; clean up
#
# Co-authored with AI: OpenCode (unknown)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="coherence-auto-remediation"
SCENARIO_PROMPT="Implement issue #PLACEHOLDER. The plan has a phase that does not map to any spec success criterion. Detect the coherence defect and return BLOCKED."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent detected the coherence defect and blocked
assert_required_pattern_present "BLOCKED" "coherence auto-remediation blocked status" || OVERALL_RESULT=1

# Verify the agent identified the specific mismatch
assert_required_pattern_present "coherence" "coherence defect identified" || OVERALL_RESULT=1

# Verify the agent did NOT proceed to implementation (no file modifications claimed)
assert_forbidden_pattern_absent "DONE" "no DONE status on coherence defect" || OVERALL_RESULT=1

# Verify remediation chain is offered, not hardcoded
assert_required_pattern_present "spec-fix\|plan-fix\|RED-fix\|remediation" "remediation chain suggested" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
