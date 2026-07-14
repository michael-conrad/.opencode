#!/bin/bash
# Behavioral test: issue-ops-sync-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: #1881 Phase 2 — Sync operations route to issue-operations-sync
#
# SC: Sync operations (sync from remote, import remote) MUST route to
# issue-operations-sync sub-skill, not the monolithic issue-operations skill.
#
# RED phase: issue-operations-sync sub-skill does NOT exist yet. The agent
# will dispatch to the monolithic issue-operations skill. Stderr will NOT
# contain "issue-operations-sync" — confirming RED state.
#
# Evidence type: behavioral — verified by stderr pattern on tool dispatch.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-sync-routing"
# Prompt: real-domain task that triggers sync operations
# The agent should route to issue-operations-sync for sync-from-remote/import-remote
SCENARIO_PROMPT="Sync issue #42 from the remote repository into the local .issues/ directory. Import the full issue body and comments."

echo "=== Behavioral Test: $SCENARIO_NAME (RED Phase) ==="
echo "SC: Sync operations MUST route to issue-operations-sync sub-skill"
echo "RED: stderr should NOT contain 'issue-operations-sync' (sub-skill does not exist yet)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC: Behavioral evidence — sync operations dispatch to issue-operations-sync
# Current codebase (Phase 2 not implemented): issue-operations-sync does NOT exist,
# so this assertion SHOULD FAIL (RED).
assert_stderr_pattern_present "issue-operations-sync" "sync routes to issue-operations-sync" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (unexpected — GREEN on RED phase)"
else
    echo "FAIL: $SCENARIO_NAME (expected — RED phase confirmed)"
fi

exit $OVERALL_RESULT
