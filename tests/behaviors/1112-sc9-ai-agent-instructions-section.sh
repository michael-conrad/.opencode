#!/bin/bash
# Behavioral test: 1112-sc9-ai-agent-instructions-section
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9 (behavioral): issue body contains the AI Agent Instructions section
# with the mandatory text about reading local spec files rather than basing
# implementation on the exec summary.
#
# RED phase: the changes haven't been made yet — the AI Agent Instructions
# section requirement is not defined in the Remote Issue Body Format.
#
# Issue #1112: Define exec summary requirements for remote issue tickets
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1112-sc9-ai-agent-instructions-section"
SCENARIO_PROMPT="Create a [SPEC] issue for adding authentication middleware. Include an AI Agent Instructions section that tells AI agents to read the local spec files rather than implement from the summary."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation → issue-operations creation task"
echo "  Expectation (GREEN): issue body contains '## AI Agent Instructions'"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0