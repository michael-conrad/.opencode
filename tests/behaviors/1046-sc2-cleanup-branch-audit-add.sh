#!/bin/bash
# Behavioral test: 1046-sc2-cleanup-branch-audit-add
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: #1046 Phase 2 — closure-verification in branch-cleanup
#
# SC-2: branch-cleanup execution MUST dispatch closure-verification as Step 0
# before any branch operation.
#
# RED phase: Currently, closure-verification is dispatched from verify-merge
# (Step 2), NOT from branch-cleanup. When the agent runs branch-cleanup with
# verify-merge and issue-closure already completed, stderr MUST contain a
# closure-verification dispatch. If it doesn't (current codebase), the test
# FAILS — confirming RED state.
#
# Evidence type: behavioral — verified by stderr pattern on tool dispatch.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1046-sc2-cleanup-branch-audit-add"
# Prompt: simulate branch-cleanup with verify-merge and issue-closure already completed
# The agent should load branch-cleanup.md and execute its steps.
# Currently, branch-cleanup.md does NOT dispatch closure-verification (it lives in verify-merge).
SCENARIO_PROMPT="Run git-workflow --task cleanup branch-cleanup for PR #1046 that merged into dev. The verify-merge and issue-closure steps already completed. The PR merged successfully."

echo "=== Behavioral Test: $SCENARIO_NAME (RED Phase) ==="
echo "SC-2: branch-cleanup MUST dispatch closure-verification as Step 0"
echo "RED: stderr should NOT contain closure-verification dispatch (current code)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-2: Behavioral evidence — branch-cleanup dispatch of closure-verification
# This assertion checks stderr for the closure-verification dispatch pattern.
# Current codebase (Phase 2 not implemented): closure-verification is NOT in
# branch-cleanup.md, so this assertion SHOULD FAIL (RED).
assert_stderr_pattern_present "closure-verification" "branch-cleanup dispatches closure-verification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (unexpected — GREEN on RED phase)"
else
    echo "FAIL: $SCENARIO_NAME (expected — RED phase confirmed)"
fi

exit $OVERALL_RESULT
