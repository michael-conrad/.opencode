#!/bin/bash
# Behavioral test: 2617-sc8-token-probe
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Measurement vehicle for .opencode#2617 SC-8: a trivial hello-style prompt driven
# identically against the pre-change and post-change deck commits — same scenario,
# same model (DEFAULT_TEST_MODEL), same prompt; the deck commit is the only differing
# input. The prompt-token accounting is read from the run's session export by the
# clean-room evaluator (SC-9). This script asserts nothing and produces no verdict.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2617-sc8-token-probe"
SCENARIO_PROMPT="hello world"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
