#!/bin/bash
# Behavioral test: issue-ops-core-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: CRUD operations (create/read/update/close issue) MUST route to
# issue-operations-core sub-skill, not the monolithic issue-operations skill.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-core-routing"
SCENARIO_PROMPT="Create a new issue in the repository for adding a dark mode toggle. The issue should have title 'Add dark mode toggle' and body describing the feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
