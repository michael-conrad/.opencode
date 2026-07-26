#!/bin/bash
# Behavioral test: writing-plans-triplet-integrity
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Triplet integrity pipeline fires on a defective plan where SCs are split
# across phases. Verifies all three gates fire:
#   - structure.md rejects the split (TRIPLET_SPLIT)
#   - self-review.md detects the split (SELF_REVIEW_FAILED)
#   - validate.md fails the split (TRIPLET_SPLIT)
#
# RED phase: triplet integrity pipeline does NOT exist yet.
# Expected to produce artifacts for evaluation.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-triplet-integrity"
SCENARIO_PROMPT="Create an implementation plan for issue #2144 using the writing-plans skill. The spec has SC-1 (add input validation) and SC-2 (add error handling) where SC-2 depends on SC-1's output. Place SC-1's RED in Phase 1, SC-1's GREEN in Phase 2, and SC-1's COMMIT in Phase 3. Then run the structure, self-review, and validate tasks on the plan."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
