#!/bin/bash
# Behavioral test: submodule-pointer-enforcement
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: pre-commit/pre-push gate verifies submodule pointer updates are included in commits

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-pointer-enforcement"
SCENARIO_PROMPT="Implement SC-2 from spec #2058: add a critical violation to 000-critical-rules.md stating that the pre-commit or pre-push gate MUST verify submodule pointer updates are included in commits when submodule changes are part of the PR scope."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
