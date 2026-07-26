#!/bin/bash
# Behavioral test: writing-plans-validate-split
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: validate.md detects and FAILs on any SC whose RED/GREEN/COMMIT steps
# are split across phases.
#
# RED phase: validate.md does NOT have split-SC detection yet.
# The prompt asks the agent to run the validate task on a plan where SC-1's RED
# is in Phase 1 and GREEN/COMMIT are in Phase 2 — a split that validate.md
# should reject with BLOCKED once the feature exists.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-validate-split"
SCENARIO_PROMPT="Run the validate task from the writing-plans skill on this plan. \
Phase 1: SC-1 RED (implement SC-1 test). \
Phase 2: SC-1 GREEN (implement SC-1), SC-1 COMMIT (commit SC-1). \
The validate task should detect that SC-1's RED is split from its GREEN/COMMIT across phases and return BLOCKED."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
