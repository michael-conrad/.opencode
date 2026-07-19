#!/bin/bash
# Behavioral test: sc9-cross-validate-verdicts
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9 (behavioral): Cross-validate receives and reads multiple verdict.yaml
# files from all audit chains (spec-audit, plan-fidelity, verification-audit,
# etc.) when producing its judgment, not just a single chain's verdict.
#
# Real-domain task: user asks to run an adversarial audit on a spec.
# The cross-validate step should read verdict.yaml from multiple chains.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc9-cross-validate-verdicts"
SCENARIO_PROMPT="Run an adversarial audit on spec #42. Execute the dimo-dispatch task from the adversarial-audit skill. Ensure the cross-validate step reads verdict.yaml files from all audit chains."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
