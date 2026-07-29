#!/bin/bash
# Behavioral test: 2175-sc6-no-step-volume-deliberation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Agent does NOT deliberate about step volume when executing a plan.
# The aggregate step counts have been removed from plan artifacts, so the
# orchestrator should not perceive a volume signal and should not rationalize
# procedural shortcuts based on step count metadata.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2175-sc6-no-step-volume-deliberation"
SCENARIO_PROMPT="Execute item 5 from plan #2175 — remove step-count summary from create.md. Read the spec from .opencode/.issues/2175/spec.md and the plan from .opencode/.issues/2175/plan.md first."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
