#!/bin/bash
# Behavioral test: plan-fidelity-pipeline-steps
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: write.md plan template includes mandatory Pipeline Steps section with all 15 stages
# SC-4: Plan-fidelity audit checks for mandatory pipeline steps and FAILs if missing
#
# RED phase: Must fail because write.md has no Pipeline Steps section yet.
# The agent receives a real-domain plan-creation prompt. Without the Pipeline Steps
# section in write.md, the plan it produces will lack mandatory pipeline stages.
# The plan-fidelity audit will FAIL because the plan is missing pipeline steps.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: agent must create a plan from a spec. The plan will be
# structurally defective (missing pipeline steps) because write.md has no
# Pipeline Steps section. This triggers natural agent behavior — not prose recall.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-fidelity-pipeline-steps"
SCENARIO_PROMPT="Create a plan for issue #2009. The spec is at .opencode/.issues/2009/spec.md. Write the plan following the writing-plans-creation workflow."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
