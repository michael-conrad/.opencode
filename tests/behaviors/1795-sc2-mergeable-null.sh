#!/bin/bash
# Behavioral test: 1795-sc2-mergeable-null
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: When mergeable is null, agent diagnoses root cause (stale base,
#       conflict, or pending) and reports to user.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1795-sc2-mergeable-null"
SCENARIO_PROMPT="approved for pr: #1795 — add post-creation mergeability check to create-pr.md. The spec requires that when the PR API returns mergeable=null, the agent diagnoses the root cause (stale base, conflict, or pending computation) and reports it to the user rather than proceeding silently."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
