#!/bin/bash
# Behavioral test: writing-plans-self-review-split
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: self-review.md detects and BLOCKs on any SC whose RED/GREEN/COMMIT
# steps are split across phases.
#
# RED phase: self-review.md does NOT have split-SC detection yet.
# Expected to produce artifacts for evaluation.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-self-review-split"
SCENARIO_PROMPT="Create an implementation plan for issue #2144 using the writing-plans skill. The spec has SC-1 (add input validation) and SC-2 (add error handling) where SC-2 depends on SC-1's output. Place SC-1's RED and GREEN in Phase 1 and SC-1's COMMIT in Phase 2. Then run the self-review task on the plan."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
