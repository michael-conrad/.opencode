#!/bin/bash
# Behavioral Enforcement Test: Issue Operations — Dispatch Instead of Inline
#
# Tests that the agent dispatches to issue-operations skill when creating
# issue content, rather than writing it inline. The critical-rules-034
# Violation Patterns table forbids inline issue content creation, but the
# prohibition is advisory (table row text) without a deterministic symbolic
# yaml rule — the model can rationalize past it.
#
# RED phase (before fix): model creates issue content inline (direct
#   github_issue_write without calling issue-operations). Assertion FAILS.
# GREEN phase (after fix): model dispatches to issue-operations skill.
#   Assertion PASSES.
#
# Uses clean-room assert_semantic (primary behavioral evidence) with
# assert_stderr_pattern_present (secondary string corroboration).
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-operations-dispatch-instead-of-inline"
SCENARIO_PROMPT="Create a spec issue for adding a CONTRIBUTING.md section that describes our commit message conventions. Use conventional commits format (feat:, fix:, chore:, docs:)."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

# ---- Assert the DESIRED behavioral outcome ----
# The agent MUST dispatch to issue-operations skill when creating issue content.
# Before the fix (RED): agent does inline github_issue_write → semantic FAIL.
# After the fix (GREEN): agent dispatches to issue-operations → semantic PASS.

OVERALL_RESULT=0

# Primary behavioral evidence: clean-room semantic inspector
# SC-4: agent dispatches to issue-operations (not inline)
assert_semantic \
  "SC-4" \
  "Agent dispatched to issue-operations skill (via skill() call or task() dispatch) instead of creating issue content inline using direct github_issue_write. Evidence includes: Skill 'issue-operations' in stderr, or the agent explicitly routing the issue creation through the skill's pipeline." \
  "required" \
  || OVERALL_RESULT=1

# Secondary string corroboration: stderr should show issue-operations skill dispatch
assert_stderr_pattern_present \
  'Skill "issue-operations"' \
  "issue-operations skill dispatch in stderr" \
  || OVERALL_RESULT=1

echo "=== Test complete (result: $([ "$OVERALL_RESULT" = 0 ] && echo PASS || echo FAIL)) ==="
echo "stdout: $BEHAVIOR_STDOUT"
echo "stderr: $BEHAVIOR_STDERR"
echo "log_dir: $BEHAVIOR_LOG_DIR/$SCENARIO_NAME"

exit $OVERALL_RESULT
