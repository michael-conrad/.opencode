#!/bin/bash
# Behavioral test: needs-approval-remote-verification
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent verifies `needs-approval` label exists on remote issue after
# creation — if missing, agent remediates.
#
# The agent receives a real-domain task to create a GitHub issue and verify
# the needs-approval label is present on the remote issue via GitHub API.
# The agent should check the remote issue labels and add the label if it's missing.
#
# PROMPT CONSTRUCTION:
# Real-domain task: create a remote GitHub issue and verify the needs-approval
# label exists on the remote. This triggers natural agent behavior — reading
# the remote issue labels via GitHub API, checking for needs-approval, and
# remediating if missing.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="needs-approval-remote-verification"
SCENARIO_PROMPT="Create a new GitHub issue titled 'Test issue for remote needs-approval' in the current repository. Then verify the needs-approval label is present on the remote issue via the GitHub API. If the label is missing, add it to the remote issue."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0