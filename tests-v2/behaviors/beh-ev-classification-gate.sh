#!/bin/bash
# Behavioral test: beh-ev-classification-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="beh-ev-classification-gate"
SCENARIO_PROMPT="Create a spec for adding a new guideline that enforces mandatory code review for all PRs. The spec should include success criteria with evidence types. Follow the spec-creation workflow."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
