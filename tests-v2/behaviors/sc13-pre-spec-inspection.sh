#!/bin/bash
# Behavioral test: sc13-pre-spec-inspection
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13: pre-spec-inspection.md exists.
#
# RED phase: This test MUST FAIL because pre-spec-inspection.md does not exist yet.
# When the agent processes a spec-creation request, the pipeline references
# pre-spec-inspection.md as a step. Since the file is absent, the agent's
# behavior will diverge from the expected pipeline — it cannot execute the
# pre-spec-inspection step, producing evidence of the missing file.
#
# GREEN phase: After pre-spec-inspection.md is created, the agent follows
# the pipeline correctly and the test passes.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc13-pre-spec-inspection"
SCENARIO_PROMPT="Create a spec for issue #42. The issue is about adding a new search feature to the API."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
