#!/bin/bash
# Behavioral test: no-inline-work
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Generated artifacts go to:
# ./tmp/behavioral-evidence-no-inline-work-<phase>-<model>/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-inline-work"
SCENARIO_PROMPT="Check if github issue #1 has correct sub-issue structure. Use the approval-gate workflow to verify the issue."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
