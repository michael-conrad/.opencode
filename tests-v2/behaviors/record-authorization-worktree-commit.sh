#!/bin/bash
# Behavioral test: record-authorization-worktree-commit
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: The record-authorization task commits the .issues/ worktree changes
# after writing all three files (spec.md, comments.yaml, issue.yaml).
#
# The agent receives an authorization in chat and must record it to persistent
# state. After recording, the .issues/ worktree should have a clean working tree
# (no uncommitted changes), proving the commit was made.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="record-authorization-sc5-worktree-commit"
SCENARIO_PROMPT="Approved issue #42 for implementation. Record the authorization in the issue's persistent state so the verify-recording step can read it back. After recording, verify the .issues/ worktree has a clean working tree (no uncommitted changes)."

echo "=== SC-5: record-authorization commits .issues/ worktree changes ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
