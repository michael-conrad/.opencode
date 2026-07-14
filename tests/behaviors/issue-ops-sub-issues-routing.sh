#!/bin/bash
# Behavioral test: issue-ops-sub-issues-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: #1881 Phase 2 — Sub-issue operations route to issue-operations-sub-issues
#
# SC: Sub-issue operations (link sub-issue, read sub-issues) MUST route to
# issue-operations-sub-issues sub-skill, not the monolithic issue-operations skill.
#
# RED phase: issue-operations-sub-issues sub-skill does NOT exist yet. The agent
# will dispatch to the monolithic issue-operations skill. Stderr will NOT
# contain "issue-operations-sub-issues" — confirming RED state.
#
# Evidence type: behavioral — verified by stderr pattern on tool dispatch.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-sub-issues-routing"
# Prompt: real-domain task that triggers sub-issue operations
# The agent should route to issue-operations-sub-issues for linking/reading sub-issues
SCENARIO_PROMPT="Link issue #43 as a sub-issue of issue #42. The sub-issue should appear after the existing sub-issues."

echo "=== Behavioral Test: $SCENARIO_NAME (RED Phase) ==="
echo "SC: Sub-issue operations MUST route to issue-operations-sub-issues sub-skill"
echo "RED: stderr should NOT contain 'issue-operations-sub-issues' (sub-skill does not exist yet)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC: Behavioral evidence — sub-issue operations dispatch to issue-operations-sub-issues
# Current codebase (Phase 2 not implemented): issue-operations-sub-issues does NOT exist,
# so this assertion SHOULD FAIL (RED).
assert_stderr_pattern_present "issue-operations-sub-issues" "sub-issues route to issue-operations-sub-issues" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (unexpected — GREEN on RED phase)"
else
    echo "FAIL: $SCENARIO_NAME (expected — RED phase confirmed)"
fi

exit $OVERALL_RESULT
