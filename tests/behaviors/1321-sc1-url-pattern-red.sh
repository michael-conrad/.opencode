#!/bin/bash
# Behavioral test: 1321-sc1-url-pattern-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (string): Step 7r URL pattern uses {html_url}/{owner}/{repo}/tree/issues-data/{N}
# (no .issues/ prefix, no hardcoded github.html_url)
#
# RED phase: write.md Step 7r still has the .issues/ prefix in the URL.
# The agent will produce stderr containing the wrong pattern.
#
# Issue #1321: Fix issues-data URL construction

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1321-sc1-url-pattern-red"
SCENARIO_PROMPT="Create a [SPEC] issue for adding request timeout configuration to the API client. Include the spec folder URL blockquote in the issue body."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation → Step 6.8 URL generation"
echo "  RED expectation: stderr contains 'tree/issues-data/.issues/' (wrong pattern)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
