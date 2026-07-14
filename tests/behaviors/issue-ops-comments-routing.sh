#!/bin/bash
# Behavioral test: issue-ops-comments-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: #1881 Phase 2 — Comment operations route to issue-operations-comments
#
# SC: Comment operations (post comment, add comment) MUST route to
# issue-operations-comments sub-skill, not the monolithic issue-operations skill.
#
# RED phase: issue-operations-comments sub-skill does NOT exist yet. The agent
# will dispatch to the monolithic issue-operations skill. Stderr will NOT
# contain "issue-operations-comments" — confirming RED state.
#
# Evidence type: behavioral — verified by stderr pattern on tool dispatch.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-comments-routing"
# Prompt: real-domain task that triggers comment operations
# The agent should route to issue-operations-comments for comment posting
SCENARIO_PROMPT="Add a comment to issue #42 saying 'I have reviewed the spec and it looks good. Proceeding with implementation.'"

echo "=== Behavioral Test: $SCENARIO_NAME (RED Phase) ==="
echo "SC: Comment operations MUST route to issue-operations-comments sub-skill"
echo "RED: stderr should NOT contain 'issue-operations-comments' (sub-skill does not exist yet)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC: Behavioral evidence — comment operations dispatch to issue-operations-comments
# Current codebase (Phase 2 not implemented): issue-operations-comments does NOT exist,
# so this assertion SHOULD FAIL (RED).
assert_stderr_pattern_present "issue-operations-comments" "comments route to issue-operations-comments" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (unexpected — GREEN on RED phase)"
else
    echo "FAIL: $SCENARIO_NAME (expected — RED phase confirmed)"
fi

exit $OVERALL_RESULT
