#!/bin/bash
# Behavioral test: 1385-sc8-all-findings
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-8: spec-audit reports all SC-SEM findings, not first-failure-only

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc8-all-findings"
SCENARIO_PROMPT="You are auditing a skill card spec. The spec references a SKILL.md with this description: 'Use when working with data.' The Trigger Dispatch Table lists triggers for 'pre-work', 'implementation', 'cleanup'. Evaluate ALL SC-SEM criteria (SC-SEM-001 through SC-SEM-006). Report findings for each criterion individually — do NOT stop after the first failure."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
