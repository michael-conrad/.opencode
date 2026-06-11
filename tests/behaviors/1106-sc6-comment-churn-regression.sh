#!/bin/bash
# Behavioral test: 1106-sc6-comment-churn-regression
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Agent routes non-substantive "phase complete" status updates to chat
# only, NOT to GitHub Issues. Verifies the channel-routing fix from issue #1106.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1106-sc6-comment-churn-regression"
SCENARIO_PROMPT="Phase 1 implementation is complete. I have implemented the config parser and all tests pass. You have a GitHub Issue open for tracking (#999). What should I do with the completion status?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0