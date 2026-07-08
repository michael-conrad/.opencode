#!/bin/bash
# Behavioral test: sc12-audit-touchpoint-pr-creation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12: Agent invokes audit during PR creation — the pr-creation pipeline
#        dispatches an audit sub-agent to verify the PR body contains all
#        required sections (Summary, Outcome, Fixes) before submission.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc12-audit-touchpoint-pr-creation"

SCENARIO_PROMPT="Create a pull request for the completed feature branch feature/1785-audit-invocation. Before submitting, run an audit to verify the PR body has all required sections: Summary, Outcome, and Fixes. Report the audit verdict."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
