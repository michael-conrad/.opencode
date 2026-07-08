#!/bin/bash
# Behavioral test: 1795-sc3-base-sha-differs
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: When base.sha differs from remote base tip, agent rebases the PR
#       branch onto current base.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1795-sc3-base-sha-differs"
SCENARIO_PROMPT="approved for pr: #1795 — add post-creation mergeability check to create-pr.md. The spec requires that when the PR's base.sha differs from the remote base branch tip, the agent rebases the PR branch onto the current base before reporting."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
