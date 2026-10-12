#!/bin/bash
# Behavioral test: 2554-sc8-mechanical-fix-no-convert
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2554 SC-8: an agent making a purely mechanical fix (typo) to a
# grandfathered deck card leaves the card otherwise unconverted — no
# whole-card rewrite occurs. The fixture seeds the typo. Clean-room
# evaluation over session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2554-sc8-mechanical-fix-no-convert"
SCENARIO_PROMPT="The agent deck card at .opencode/skills/git-workflow-conflict/SKILL.md contains a spelling mistake. Fix the spelling mistake."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
