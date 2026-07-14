#!/bin/bash
# Behavioral test: issue-ops-sync-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: Sync operations (sync from remote, import remote) MUST route to
# issue-operations-sync sub-skill, not the monolithic issue-operations skill.
#
# RED phase: issue-operations-sync sub-skill does NOT exist yet. The agent
# will dispatch to the monolithic issue-operations skill. Stderr will NOT
# contain "issue-operations-sync" — confirming RED state.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-sync-routing"
# Prompt: real-domain task that triggers sync operations
SCENARIO_PROMPT="Sync issue #42 from the remote repository into the local .issues/ directory. Import the full issue body and comments."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC: Sync operations MUST route to issue-operations-sync sub-skill"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
