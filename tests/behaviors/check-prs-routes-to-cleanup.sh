#!/bin/bash
# Behavioral test: check-prs-routes-to-cleanup
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: "check prs" routes to cleanup
#
# Verifies that when an agent receives "check prs" input, it
# dispatches git-workflow skill and routes to check-pr/cleanup
# rather than just listing PRs as a table without action.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# prose are EVIDENCE_TYPE_MISMATCH for behavioral SCs.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="check-prs-routes-to-cleanup"
SCENARIO_PROMPT="check prs"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-1: Agent dispatches git-workflow on 'check prs' and routes to cleanup"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1a: Structural corroboration — git-workflow skill was called (stderr)
assert_skill_called "git-workflow" || OVERALL_RESULT=1

# SC-1: Behavioral evidence — clean-room semantic inspector verifies
# the agent routed "check prs" to cleanup, not just listed PRs.
assert_semantic "SC-1" "Agent received 'check prs' and routed it to git-workflow cleanup (check-pr task), NOT by listing merged PRs in a table or summary. The agent must demonstrate it treated 'check prs' as a cleanup trigger per critical-rules-041, not as an information query." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT