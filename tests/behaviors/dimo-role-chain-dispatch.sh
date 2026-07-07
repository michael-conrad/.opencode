#!/bin/bash
# Behavioral test: dimo-role-chain-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13 (behavioral): Agent dispatches DiMo role chain (Knowledge Supporter,
# Path Provider, Evaluator, Judger) during adversarial audit, not cross-model
# auditors via resolve-models.
#
# Real-domain task: user asks to run an adversarial audit — agent should
# dispatch the DiMo role chain, not resolve-models.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dimo-role-chain-dispatch"
SCENARIO_PROMPT="Run an adversarial audit on spec #42. Execute the dimo-dispatch task from the adversarial-audit skill."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
