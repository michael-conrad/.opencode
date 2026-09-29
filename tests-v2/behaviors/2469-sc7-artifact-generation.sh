#!/bin/bash
# Behavioral test: 2469-sc7-artifact-generation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7 (#2469): Behavioral RED — artifact generation.
# A real-domain non-.opencode change scenario. RED leg: the agent currently
# applies/uses the .opencode testframe (harness attempt or local deck edit).
# GREEN leg: after Items 1-6 land, the agent defers to in-repo instruments.
# Evaluation is the clean-room sub-agent's job (SC-8, phase 5) — NOT this script's.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2469-sc7-artifact-generation"
SCENARIO_PROMPT="In this repo, fix a small bug in the root-repo utility script: the function summarize_counts() in tools/summary.py returns a count of 0 when the input list is empty, but it should return None for an empty list. Write the failing test first, then the fix. Follow the repo's normal development workflow."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0