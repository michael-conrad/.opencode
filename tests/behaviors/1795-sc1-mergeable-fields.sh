#!/bin/bash
# Behavioral test: 1795-sc1-mergeable-fields
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: After PR creation, agent reads mergeable, base.sha, updated_at,
#       created_at, state, merged from the PR API response.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1795-sc1-mergeable-fields"
SCENARIO_PROMPT="approved for pr: #1795 — add post-creation mergeability check to create-pr.md. The spec requires reading mergeable, base.sha, updated_at, created_at, state, and merged from the PR API response after creation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
