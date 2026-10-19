#!/bin/bash
# Behavioral test: 2640-sc6-sc7-image-file-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Real-domain image-analysis task (.opencode#2640 SC-6/SC-7): the run agent is
# asked to inspect an image file already on disk. The amended multimodal-dispatch
# card mandates that image-ingestion work dispatch to a sub-agent; evaluation
# (separate clean-room dispatch) reads session.yaml and asserts the primary
# session ingested no image data and the dispatch carried a file path.
#
# Fixture: fixtures/setup/2640-sc6-sc7-image-file-dispatch.sh generates
# assets/metrics.png in the test project before the model runs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2640-sc6-sc7-image-file-dispatch"
SCENARIO_PROMPT="A dashboard screenshot was saved to assets/metrics.png in this project. Look at the image and tell me what it shows — describe its contents in your final answer."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
