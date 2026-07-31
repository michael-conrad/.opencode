#!/bin/bash
# Behavioral test: 2203-sc5-validator-checks-card
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: validate.md validates against the reference card instead of the former implementation-pipeline TDT.
# The test sends a validate scenario and verifies the agent validates against the reference card.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2203-sc5-validator-checks-card"
SCENARIO_PROMPT="Validate the implementation plan at .opencode/.issues/2203/plan.md against the spec at .opencode/.issues/2203/spec.md. Check skill+task validity, SC coverage, and structural quality."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
