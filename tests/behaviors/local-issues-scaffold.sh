#!/bin/bash
# Behavioral test: local-issues-scaffold
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: Verify that --help lists all 14+ required subcommands.
# Expected to FAIL on old code (missing read-comments, read-labels, read-sub-issues,
# delete, push-body, pull-body, renumber).
# SC-1: All CLI commands exist and produce YAML output

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-scaffold"
SCENARIO_PROMPT="Verify that running '.opencode/tools/local-issues --help' lists all required subcommands: create, read, read-comments, read-labels, read-sub-issues, update, comment, close, delete, push-body, pull-body, search, list, link, renumber, promote. Report the current subcommand list."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0