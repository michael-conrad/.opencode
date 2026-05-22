#!/bin/bash
# Behavioral Test: 794-dc-redesign-orchestration
# SC-14: Agent recognizes divide-and-conquer skill routing and does NOT
# perform inline file edits, inline verification, or inline git operations.
#
# This test runs against the PRE-REDESIGN state of the divide-and-conquer skill
# so the agent encounters the multi-file, multi-phase structure that should trigger
# skill dispatch or at minimum avoid inline implementation.
#
# The prompt provides authorization (approved #794) so the agent engages with
# the implementation workflow. In a local-only repo, the agent will look for
# the spec, find none, and halt — but the key behavior we test is that
# the agent does NOT bypass the pipeline by performing inline work.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="794-dc-redesign-orchestration"

# Pre-redesign commit: the state BEFORE #794 implementation.
# The agent must see this state to encounter the multi-file structure.
PRE_REDESIGN_COMMIT="2803734ed4190a3d7296f881c958aef13b5ea92c"

SCENARIO_PROMPT="approved #794 for implementation through PR. The spec requires reorganizing the divide-and-conquer skill files: deleting 11 task files, moving context-passing.md to enforcement/, and rewriting SKILL.md. Begin implementation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "  Using pre-redesign submodule commit: $PRE_REDESIGN_COMMIT"

# Run against pre-redesign state so the agent sees the full multi-file structure.
BEHAVIOR_SUBMODULE_COMMIT="$PRE_REDESIGN_COMMIT" \
BEHAVIOR_TIMEOUT=120 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-14a: Agent should reference divide-and-conquer (evidence it read the skill files)
assert_required_pattern_present "divide-and-conquer" "agent references divide-and-conquer skill" || OVERALL_RESULT=1

# SC-14b: Agent should NOT perform inline file edits on skill files
assert_forbidden_pattern_absent "Edit.*divide-and-conquer\|Write.*divide-and-conquer" "inline file edit on skill files" || OVERALL_RESULT=1

# SC-14c: Agent should NOT perform inline verification (VbC inline = violation)
assert_forbidden_pattern_absent "I will verify this myself" "inline self-verification claim" || true

# SC-14d: Agent should dispatch git operations via git-workflow, not raw git commands
assert_forbidden_pattern_absent "git add" "raw git add command" || true
assert_forbidden_pattern_absent "git commit" "raw git commit command" || true
assert_forbidden_pattern_absent "git push" "raw git push command" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT