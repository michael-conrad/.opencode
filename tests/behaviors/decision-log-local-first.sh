#!/bin/bash
# Behavioral Enforcement Test: Decision Log Local-First Storage
#
# SC-9: assemble-work.md Step 7 writes decision log entries to .issues/
# local storage via `local-issues comment`, NOT to GitHub via
# `github_add_issue_comment`.
#
# The agent should route decision_log_entry to local .issues/ storage
# because decision logs are classified as `internal` per the Phase 1
# content classification gate.
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

# #683 SC-9: Decision log entries must be written to .issues/ local storage
# via `local-issues comment N --body "..."`, NOT to GitHub via
# `github_add_issue_comment`.
assert_required_pattern_present "local-issues comment\|\.issues/\|comments\.md" "SC-9: decision log routed to .issues/ local storage" || OVERALL_RESULT=1

# SC-9: The agent must NOT use github_add_issue_comment for decision log entries
assert_forbidden_pattern_absent "github_add_issue_comment" "SC-9: direct github_add_issue_comment for decision log (should use local-issues)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT