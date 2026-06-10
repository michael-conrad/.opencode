#!/bin/bash
# Behavioral test: 1102-sc-1-init-bootstrap
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: local-issues init bootstraps orphan issues-data branch + worktree

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-1-init-bootstrap"
SCENARIO_PROMPT="Run \`local-issues init\` in a fresh repo. Report the output and whether it shows per-repo YAML with repo, qualifier, status, issues_count, and pull_result fields."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0