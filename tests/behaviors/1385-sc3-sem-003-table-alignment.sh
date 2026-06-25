#!/bin/bash
# Behavioral test: 1385-sc3-sem-003-table-alignment
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-SEM-003: spec-audit detects dispatch table misalignment

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc3-sem-003-table-alignment"
SCENARIO_PROMPT="You are auditing a skill card spec. The spec references a SKILL.md with this description: 'Use when creating branches and committing code.' The Trigger Dispatch Table lists triggers for 'pre-work', 'implementation', 'review-prep', 'pr-creation', 'rebase', 'check-pr', 'release', 'cleanup'. Evaluate SC-SEM-003 (Dispatch table alignment): does the description match the Trigger Dispatch Table's intent? The description only mentions branches and commits, but the table covers 8 trigger conditions."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
