#!/bin/bash
# Behavioral test: per-sc-decomposition
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Verifies the plan writer produces per-SC items (one item per SC-ID)
# rather than per-file or per-concern items.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="per-sc-decomposition"
SCENARIO_PROMPT="Create an implementation plan for issue #2104. The spec has 13 success criteria (SC-1 through SC-13). Each SC must map to exactly one implementation item with its own RED/GREEN/verify/commit cycle."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
