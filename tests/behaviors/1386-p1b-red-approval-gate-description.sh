#!/bin/bash
# Behavioral test: 1386-p1b-red-approval-gate-description
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1386-p1b-red-approval-gate-description"
# SC-1: Verify description contains mandatory language (MUST, REQUIRED, always, not optional, mandatory).
# The current description uses "All conditions are mandatory" but does NOT contain "MUST" or "REQUIRED".
# The test MUST fail because the description hasn't been updated yet.
SCENARIO_PROMPT="Check the description in .opencode/skills/approval-gate/SKILL.md. Does it contain mandatory language (MUST, REQUIRED, always, not optional, mandatory)? Report PASS only if the description contains at least one instance of 'MUST' or 'REQUIRED' (uppercase)."

BEHAVIOR_PHASE="RED" behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
