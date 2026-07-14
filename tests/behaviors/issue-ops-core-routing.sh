#!/bin/bash
# Behavioral test: issue-ops-core-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: #1881 Phase 2 — CRUD operations route to issue-operations-core
#
# SC: CRUD operations (create/read/update/close issue) MUST route to
# issue-operations-core sub-skill, not the monolithic issue-operations skill.
#
# RED phase: issue-operations-core sub-skill does NOT exist yet. The agent
# will dispatch to the monolithic issue-operations skill. Stderr will NOT
# contain "issue-operations-core" — confirming RED state.
#
# Evidence type: behavioral — verified by stderr pattern on tool dispatch.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-core-routing"
# Prompt: real-domain task that triggers CRUD issue operations
# The agent should route to issue-operations-core for create/read/update/close
SCENARIO_PROMPT="Create a new issue in the repository for adding a dark mode toggle. The issue should have title 'Add dark mode toggle' and body describing the feature."

echo "=== Behavioral Test: $SCENARIO_NAME (RED Phase) ==="
echo "SC: CRUD operations MUST route to issue-operations-core sub-skill"
echo "RED: stderr should NOT contain 'issue-operations-core' (sub-skill does not exist yet)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC: Behavioral evidence — CRUD operations dispatch to issue-operations-core
# Current codebase (Phase 2 not implemented): issue-operations-core does NOT exist,
# so this assertion SHOULD FAIL (RED).
assert_stderr_pattern_present "issue-operations-core" "CRUD routes to issue-operations-core" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME (unexpected — GREEN on RED phase)"
else
    echo "FAIL: $SCENARIO_NAME (expected — RED phase confirmed)"
fi

exit $OVERALL_RESULT
