#!/bin/bash
# Behavioral test: 2203-sc7-delete-not-strip
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: skills/implementation-pipeline/ directory is deleted entirely (not stripped).
# The test verifies the directory is absent.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2203-sc7-delete-not-strip"
SCENARIO_PROMPT="Check whether the implementation-pipeline skill directory exists at skills/implementation-pipeline/. Report whether it is present or absent."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
