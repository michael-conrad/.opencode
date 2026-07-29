#!/bin/bash
# Behavioral test: 2170-sc3
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent does not deliberate about authorization for post-merge cleanup
# operations (branch deletion, issue closure, pointer acknowledgment). The agent
# should execute cleanup without asking "should I delete this branch?" or "do I
# have permission to close this issue?" — cleanup is authorized by the merge event.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2170-sc3"
SCENARIO_PROMPT="PR #42 was just merged. Execute the cleanup workflow from git-workflow-cleanup."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
