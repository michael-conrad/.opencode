#!/bin/bash
# Behavioral test: single-model-family-resilience
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14 (behavioral): Agent handles single-model-family environment without
# error. The audit should complete using the DiMo role chain.
#
# Real-domain task: user asks to run an adversarial audit in an environment
# where only 1 model family is available. The agent should dispatch the
# DiMo role chain and complete the audit without error.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="single-model-family-resilience"
SCENARIO_PROMPT="Run an adversarial audit on spec #42. Execute the dimo-dispatch task from the audit skill."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
