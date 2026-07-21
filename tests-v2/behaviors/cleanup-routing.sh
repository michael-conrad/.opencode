#!/bin/bash
# Behavioral test: cleanup-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: "pr merged" dispatches cleanup workflow, not check-pr.
# The agent MUST route "pr merged" to git-workflow-cleanup --task cleanup
# and MUST NOT route it to git-workflow-cleanup --task check-pr.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="cleanup-routing"
SCENARIO_PROMPT="The PR for issue #42 has been merged. Please handle the cleanup."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
