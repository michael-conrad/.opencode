#!/bin/bash
# Behavioral test: 1321-sc2-no-hardcoded-url-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (string): Step 6.8 URL pattern matches Step 7r (both use
# {html_url}/{owner}/{repo}/tree/issues-data/{N}). No hardcoded github.html_url.
#
# RED phase: write.md Step 6.8 still uses hardcoded github.html_url pattern.
# The agent will produce stderr containing the hardcoded pattern.
#
# Issue #1321: Fix issues-data URL construction

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1321-sc2-no-hardcoded-url-red"
SCENARIO_PROMPT="Create a [SPEC] issue for implementing retry logic with exponential backoff. Include the spec folder URL blockquote in the issue body."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation → Step 6.8 URL generation"
echo "  RED expectation: stderr contains 'github.html_url' (hardcoded, wrong)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
