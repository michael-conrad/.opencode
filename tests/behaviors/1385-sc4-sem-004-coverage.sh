#!/bin/bash
# Behavioral test: 1385-sc4-sem-004-coverage
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-SEM-004: spec-audit detects incomplete coverage of dispatch conditions

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc4-sem-004-coverage"
SCENARIO_PROMPT="You are auditing a skill card spec. The spec references a SKILL.md with this description: 'Use when creating a branch or committing changes.' The Trigger Dispatch Table lists triggers for 'pre-work', 'implementation', 'review-prep', 'pr-creation', 'rebase', 'check-pr', 'release', 'cleanup'. Evaluate SC-SEM-004 (Full coverage of dispatch conditions): would an agent reading only the description know to invoke this skill in all conditions listed in the dispatch table?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
