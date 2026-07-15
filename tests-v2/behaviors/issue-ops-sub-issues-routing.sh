#!/bin/bash
# Behavioral test: issue-ops-sub-issues-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: Sub-issue operations (link sub-issue, read sub-issues) MUST route to
# issue-operations-sub-issues sub-skill, not the monolithic issue-operations skill.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-sub-issues-routing"
SCENARIO_PROMPT="Link issue #43 as a sub-issue of issue #42. The sub-issue should appear after the existing sub-issues."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
