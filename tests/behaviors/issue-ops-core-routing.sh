#!/bin/bash
# Behavioral test: issue-ops-core-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: CRUD operations (create/read/update/close issue) MUST route to
# issue-operations-core sub-skill, not the monolithic issue-operations skill.
#
# RED phase: issue-operations-core sub-skill does NOT exist yet. The agent
# will dispatch to the monolithic issue-operations skill. Stderr will NOT
# contain "issue-operations-core" — confirming RED state.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-core-routing"
# Prompt: real-domain task that triggers CRUD issue operations
SCENARIO_PROMPT="Create a new issue in the repository for adding a dark mode toggle. The issue should have title 'Add dark mode toggle' and body describing the feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC: CRUD operations MUST route to issue-operations-core sub-skill"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
