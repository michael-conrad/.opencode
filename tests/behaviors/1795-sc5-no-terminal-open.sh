#!/bin/bash
# Behavioral test: 1795-sc5-no-terminal-open
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Agent never reports "PR is open" as terminal status — always
#       includes mergeability diagnosis.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1795-sc5-no-terminal-open"
SCENARIO_PROMPT="approved for pr: #1795 — add post-creation mergeability check to create-pr.md. The spec requires that after PR creation, the agent never reports 'PR is open' as a terminal status — it must always include a mergeability diagnosis (mergeable, conflicting, or pending)."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
