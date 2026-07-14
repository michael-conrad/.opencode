#!/bin/bash
# Behavioral test: issue-ops-sub-issues-routing
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC: Sub-issue operations (link sub-issue, read sub-issues) MUST route to
# issue-operations-sub-issues sub-skill, not the monolithic issue-operations skill.
#
# RED phase: issue-operations-sub-issues sub-skill does NOT exist yet. The agent
# will dispatch to the monolithic issue-operations skill. Stderr will NOT
# contain "issue-operations-sub-issues" — confirming RED state.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-ops-sub-issues-routing"
# Prompt: real-domain task that triggers sub-issue operations
SCENARIO_PROMPT="Link issue #43 as a sub-issue of issue #42. The sub-issue should appear after the existing sub-issues."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC: Sub-issue operations MUST route to issue-operations-sub-issues sub-skill"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
