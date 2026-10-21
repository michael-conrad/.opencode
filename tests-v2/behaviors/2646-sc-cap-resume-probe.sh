#!/bin/bash
# Behavioral test: 2646-sc-cap-resume-probe
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2646 SC-5 (behavioral half): the resume-on-cap-hit composition.
# The per-turn output cap is overridden LOW for this probe only (R-1's
# env-default form; every ordinary run executes at 4000) so the first turn
# deterministically hits the cap; the session then ends with finish=length
# and behavior_run's resume-on-cap-hit step (R-4) resumes it via the §10.7
# machinery in the same session store. The clean-room evaluation (separate
# dispatch, two-SC pattern) asserts from session.yaml that the capped turn
# is followed by a resumed exchange.
#
# TIER 3 (host): the parent-env override only reaches with-test-home on the
# host path (the tier-2 docker_env passes the literal 4000 by spec).
# BEHAVIOR_SEMANTIC_MONITOR=1: the monitored-run flag gates the resume path.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="2646-sc-cap-resume-probe"
SCENARIO_PROMPT="Create a file named NOTES.md in this repo containing a short paragraph (3-4 sentences) about what this project is, based on its README. Then tell me the first sentence you wrote."

echo "=== Behavioral Test: $SCENARIO_NAME (cap override 150, monitored) ==="
OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=150 BEHAVIOR_SEMANTIC_MONITOR=1 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
