#!/bin/bash
# Behavioral test: phase3-auditor-infra-fix
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Generated artifacts go to:
# ./tmp/behavioral-evidence-phase3-auditor-infra-fix-<phase>-<model>/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="phase3-auditor-infra-fix"
SCENARIO_PROMPT="Does the helpers.sh behavior_adversarial_eval function exist and use audit dispatch in Phase 2? Check the helpers.sh file in the project."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
