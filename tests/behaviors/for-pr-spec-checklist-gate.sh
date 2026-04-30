#!/bin/bash
# Behavioral Test: for_pr scope with uncommitted changes and spec checklist items
# Issue #240 - Verifies that the agent:
#   SC-3/SC-4: Stashes uncommitted/untracked changes before implementation
#   SC-1: Parses spec body - [ ] items and requires evidence for each
#   SC-2: Blocks URL generation when dispatch chain evidence is missing under for_pr scope
#
# RED Phase: This test enforces the three enforcement gaps from #240.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="for-pr-spec-checklist-gate"
SCENARIO_PROMPT="approved #240 for PR — implement the spec-checklist gate, for_pr evidence audit, and uncommitted-work protocol enforcement gaps"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent MUST parse spec body for - [ ] checklist items and require evidence
# The prompt references enforcement gaps that have explicit checklist items in the spec
assert_required_pattern_present "checklist" "spec checklist item verification" || OVERALL_RESULT=1

# SC-3/SC-4: Agent MUST NOT commit uncommitted changes without stashing
# Agent should stash first, then implement from clean state
assert_forbidden_pattern_absent "committing existing changes" "committing uncommitted changes without stashing" || OVERALL_RESULT=1

# SC-2/SC-5: Agent MUST follow full dispatch chain under for_pr scope
# for_pr does NOT skip verification steps
assert_skill_invoked "verification-before-completion" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT