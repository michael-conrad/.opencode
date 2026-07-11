#!/bin/bash
# Behavioral test: comment-churn-regression
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent does NOT post non-substantive progress updates to GitHub Issues
# SC-4: Agent DOES post substantive comments (blockers, completions) to GitHub Issues
#
# Two runs: one with non-substantive prompt, one with substantive prompt.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-3: Non-substantive progress update — agent should NOT post to GitHub Issues
SCENARIO_NAME_3="comment-churn-regression-non-substantive"
SCENARIO_PROMPT_3="Phase 1 is complete, posting update to issue #1. The config parsing module has been implemented and all unit tests pass."

behavior_run "$SCENARIO_NAME_3" "$SCENARIO_PROMPT_3"

# SC-4: Substantive blocker report — agent SHOULD post to GitHub Issues
SCENARIO_NAME_4="comment-churn-regression-substantive"
SCENARIO_PROMPT_4="Found a blocker: the config parser crashes on empty input files with a KeyError. I need to report this bug on issue #1 so the team is aware before the next release."

behavior_run "$SCENARIO_NAME_4" "$SCENARIO_PROMPT_4"

exit 0
