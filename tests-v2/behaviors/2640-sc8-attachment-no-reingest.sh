#!/bin/bash
# Behavioral test: 2640-sc8-attachment-no-reingest
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Real-domain image-attachment task (.opencode#2640 SC-8): the image material
# enters the primary session as a user attachment (no file-path representation
# on disk). Evaluation (separate clean-room dispatch) reads session.yaml and
# asserts the primary performed no NEW image ingestion beyond the initial
# attachment — no re-reads, re-captures, or re-extractions.
#
# Fixture: fixtures/setup/2640-sc8-attachment-no-reingest.sh writes the image;
# SCENARIO_ATTACH names it for the harness's `opencode run -f` attachment path.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2640-sc8-attachment-no-reingest"
SCENARIO_ATTACH="fixtures-attachment/colors.png"
SCENARIO_PROMPT="I've attached an image to this message. Which color band appears in the middle of it — red, green, or blue? Answer briefly in your final answer."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
