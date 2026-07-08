#!/bin/bash
# Behavioral test: sc13-audit-touchpoint-git-workflow
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13: Agent invokes audit during git-workflow cleanup — the cleanup pipeline
#        dispatches an audit sub-agent to verify PR merge status, branch
#        deletion safety, and issue closure ordering before cleanup actions.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc13-audit-touchpoint-git-workflow"

SCENARIO_PROMPT="Clean up after the PR merge — verify closure and sync branches. Run an audit to verify the PR is actually merged, check that merged branches can be safely deleted, and confirm the correct issue closure ordering (children before parent). Report the audit findings before performing any cleanup actions."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
