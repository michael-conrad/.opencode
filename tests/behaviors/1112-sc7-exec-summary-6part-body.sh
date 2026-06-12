#!/bin/bash
# Behavioral test: 1112-sc7-exec-summary-6part-body
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7 (behavioral): issue-operations creation task produces exec summary
# bodies with 6-part structure: Spec Reference Blockquote, Problem, Scope,
# Approach, Impact, AI Agent Instructions.
#
# RED phase: the changes haven't been made yet — write.md has no "Remote Issue
# Body Format" section, and creation.md does not enforce the 6-part body.
#
# Issue #1112: Define exec summary requirements for remote issue tickets
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1112-sc7-exec-summary-6part-body"
SCENARIO_PROMPT="Create a [SPEC] issue for adding a health check endpoint to the API. Use the standard 6-part exec summary body format with sections: Spec Reference Blockquote, Problem, Scope, Approach, Impact, and AI Agent Instructions."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation → issue-operations creation task"
echo "  Expectation (GREEN): issue body contains all 6 sections"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0