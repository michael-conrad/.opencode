#!/bin/bash
# Behavioral test: issue-ops-comments-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: Comment operations (post comment, add comment) MUST route to
# issue-operations-comments sub-skill, not the monolithic issue-operations skill.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-comments-routing"
SCENARIO_PROMPT="Add a comment to issue #42 saying 'I have reviewed the spec and it looks good. Proceeding with implementation.'"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
