#!/bin/bash
# Behavioral test: sc7-audit-touchpoint-spec-creation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Agent invokes audit during spec creation — the spec-creation pipeline
#       dispatches an audit sub-agent to verify spec completeness before
#       persisting the spec.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc7-audit-touchpoint-spec-creation"

SCENARIO_PROMPT="Create a spec for a new feature that adds dark mode support to the application. The spec should include success criteria with evidence types and verification methods. After writing the spec, run an audit to verify it is complete and correct."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0
