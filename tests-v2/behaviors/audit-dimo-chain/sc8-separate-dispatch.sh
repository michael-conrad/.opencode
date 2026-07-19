#!/bin/bash
# Behavioral test: sc8-separate-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (behavioral): Orchestrator dispatches each DiMo role as a separate
# task() call (Investigator, Validator, Evaluator, Arbiter) when running
# an adversarial audit, rather than dispatching the entire chain as one task().
#
# Real-domain task: user asks to run an adversarial audit on a spec.
# The orchestrator should dispatch 4 separate task() calls, one per role.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc8-separate-dispatch"
SCENARIO_PROMPT="Run an adversarial audit on spec #42. Execute the dimo-dispatch task from the adversarial-audit skill, dispatching each role (Investigator, Validator, Evaluator, Arbiter) as a separate task() call."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
