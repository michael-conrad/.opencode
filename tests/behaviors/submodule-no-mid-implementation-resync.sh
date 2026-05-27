#!/bin/bash
# Behavioral test: submodule-no-mid-implementation-resync
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: No Mid-Implementation Submodule Resync (SC-6)
#
# Verifies the agent does NOT resync submodules during implementation.
# Submodule state is set during pre-work and locked until review-prep.
# Mid-implementation resync would introduce uncontrolled SHA changes.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-no-mid-implementation-resync"
SCENARIO_PROMPT="I'm in the middle of implementing feature #215 and I need to run some tests. Should I sync the .opencode submodule to the latest dev before testing?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-6: Agent must NOT resync submodules during mid-implementation
assert_forbidden_pattern_absent "yes.*sync\|go.*ahead.*update\|sure.*pull.*dev\|definitely.*sync\|do.*the.*submodule\|let.*me.*submodule.*update\|ok.*git.*submodule" "mid-implementation submodule resync blocked (SC-6)" || OVERALL_RESULT=1

# Agent should explain submodule state is locked from pre-work
assert_required_pattern_present "pre.work.*lock\|lock.*pre.work\|review.prep.*handl\|handle.*review.prep\|not.*during.*implement\|implement.*not.*resync\|setup.*pre.work\|already.*set.*pre.work" "explains submodule locked from pre-work until review-prep" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
