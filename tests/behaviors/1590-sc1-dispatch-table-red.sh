#!/bin/bash
# Behavioral test: 1590-sc1-dispatch-table-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 RED: spec-creation/SKILL.md Trigger Dispatch Table has sub-step entries
# Test expects FAIL at this point (sub-step entries still present)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1590-sc1-dispatch-table-red"
SCENARIO_PROMPT="check spec-creation SKILL.md dispatch table for sub-step entries"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
