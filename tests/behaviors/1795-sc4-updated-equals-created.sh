#!/bin/bash
# Behavioral test: 1795-sc4-updated-equals-created
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: When updated_at equals created_at, agent triggers mergeability
#       computation (comment or no-op push).
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1795-sc4-updated-equals-created"
SCENARIO_PROMPT="approved for pr: #1795 — add post-creation mergeability check to create-pr.md. The spec requires that when the PR's updated_at equals created_at (mergeability not yet computed), the agent triggers computation via a comment or no-op push."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
