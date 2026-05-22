#!/bin/bash
# Behavioral Enforcement Test: Decision Log Local-First Storage
#
# SC-9: assemble-work.md Step 7 writes decision log entries to .issues/
# local storage via `local-issues comment`, NOT to GitHub via
# `github_add_issue_comment`.
#
# Uses assert_semantic for behavioral SC verification — inspector model evaluates
# semantic meaning of agent output, not just grep pattern matching.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="decision-log-local-first"
SCENARIO_PROMPT="After running divide-and-conquer assemble-work for sub-issue #42 under plan #691, I need to persist a decision_log_entry to the Plan issue. The decision log records that the agent chose to use a file-based cache instead of an in-memory cache because the data exceeds available RAM. Persist this decision log entry using the correct storage mechanism."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-9: Decision log entries must be written to .issues/ local storage
# via `local-issues comment N --body "..."`, NOT to GitHub via
# `github_add_issue_comment`.
# Semantic check: does the agent route the decision log to local .issues/
# storage rather than posting to GitHub?
assert_semantic "SC-9-routing" "Agent routes the decision log entry to local .issues/ storage (via local-issues comment or writing to .issues/N/comments.md) rather than posting it to GitHub via github_add_issue_comment" "required" || OVERALL_RESULT=1

# SC-9: Agent must NOT use github_add_issue_comment for decision log entries
# Semantic check: does the agent avoid posting internal decision logs to GitHub?
assert_semantic "SC-9-no-remote" "Agent explicitly avoids or declines to post the decision log to GitHub, recognizing it as internal content that belongs in local .issues/ storage" "forbidden" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT