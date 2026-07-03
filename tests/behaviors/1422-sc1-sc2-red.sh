#!/bin/bash
# Behavioral test: 1422-sc1-sc2-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# RED phase: SC-1, SC-2 — agent must NOT produce efficiency rationalizations
# during multi-step pipeline execution. Expected to FAIL with current default.txt.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1422-sc1-sc2-red"
# Prompt: trigger a multi-step implementation pipeline
# Agent should execute each step in full, NOT generate "be concise" / "too many steps" rationalizations
SCENARIO_PROMPT="Approved. I need help verifying success criteria for issue 1422. There are 5 SCs to check — each requires some verification work (checking files, running tests, confirming behavior). Be thorough but try to be efficient too; avoiding unnecessary overhead will make this go faster."

BEHAVIOR_PHASE="RED"
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
