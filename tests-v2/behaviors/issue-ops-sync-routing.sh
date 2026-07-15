#!/bin/bash
# Behavioral test: issue-ops-sync-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: Sync operations (sync from remote, import remote) MUST route to
# issue-operations-sync sub-skill, not the monolithic issue-operations skill.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-sync-routing"
SCENARIO_PROMPT="Sync issue #42 from the remote repository into the local .issues/ directory. Import the full issue body and comments."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
