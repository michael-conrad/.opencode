#!/bin/bash
# Behavioral test: 1112-sc8-full-resolved-url
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (behavioral): issue body contains a full resolved URL (not shortcut)
# to the local spec artifact. Verifies the agent uses
# https://github.com/{owner}/{repo}/tree/issues-data/{N} rather than bare #NNN
# or owner/repo#NNN shortcuts.
#
# RED phase: the changes haven't been made yet — write.md Step 6.8 exists but
# the Remote Issue Body Format section with full URL requirement is not yet
# enforced in creation.md.
#
# Issue #1112: Define exec summary requirements for remote issue tickets
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1112-sc8-full-resolved-url"
SCENARIO_PROMPT="Create a [SPEC] issue for implementing API request logging. Include a reference URL to the full spec artifact in the issue body."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation → issue-operations creation task"
echo "  Expectation (GREEN): issue body contains full GitHub URL (not #NNN)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0