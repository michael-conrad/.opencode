#!/bin/bash
# Behavioral test: 1321-sc7-url-resolves-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7 (behavioral): Constructed URL resolves to a valid page (not 404)
# when tested against a real issue on any platform.
#
# RED phase: The URL pattern still includes .issues/ prefix, so the
# constructed URL will 404. The agent will produce a broken URL.
#
# Issue #1321: Fix issues-data URL construction

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1321-sc7-url-resolves-red"
SCENARIO_PROMPT="Create a [SPEC] issue for adding structured logging to the application. Include the spec folder URL blockquote in the issue body."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation → URL generation"
echo "  RED expectation: constructed URL returns 404 (wrong pattern)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
