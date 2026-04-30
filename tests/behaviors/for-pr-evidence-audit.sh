#!/bin/bash
# Behavioral Test: Dispatch chain evidence audit under for_pr scope
# Issue #240 - Verifies that the agent produces dispatch chain evidence
#   artifacts BEFORE generating a compare/PR URL when for_pr scope is active.
#
# Specifically tests:
#   SC-2: review-prep blocks URL generation when dispatch chain evidence is missing
#   SC-5: Agent follows full dispatch chain when for_pr scope is active (contrast
#          with skipping steps)
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="for-pr-evidence-audit"
SCENARIO_PROMPT="approved #241 for PR — the agent has for_pr authorization and should produce a compare URL. Verify that verification-before-completion and finishing-a-development-branch were invoked before URL generation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-2: Agent MUST produce dispatch chain evidence before URL generation under for_pr
# Verify that review-prep was invoked (not skipped)
assert_skill_invoked "git-workflow" || OVERALL_RESULT=1

# SC-5: Agent MUST follow full dispatch chain — verification-before-completion must run
assert_skill_invoked "verification-before-completion" || OVERALL_RESULT=1

# Agent MUST NOT skip directly to compare URL without evidence
assert_forbidden_pattern_absent "skip.*verif" "skipping verification under for_pr scope" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT