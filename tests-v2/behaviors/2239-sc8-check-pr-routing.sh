#!/bin/bash
# Behavioral test: 2239-sc8-check-pr-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Dispatching "check pr" routes to git-workflow-cleanup --task cleanup
# The agent must route "check pr" to the cleanup workflow, not to a non-existent
# "check-pr" task. This verifies backward compatibility after check-pr removal.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2239-sc8-check-pr-routing"
SCENARIO_PROMPT="check pr"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# SC-8: Agent routes "check pr" to git-workflow-cleanup --task cleanup
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-8" "When the user says 'check pr', the agent dispatches git-workflow-cleanup --task cleanup (or equivalent cleanup workflow). The agent does NOT look for a non-existent 'check-pr' task. The agent routes to the cleanup workflow which handles PR state checking, merged branch cleanup, and issue closure."
exit 0
