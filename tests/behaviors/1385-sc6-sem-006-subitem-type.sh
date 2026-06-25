#!/bin/bash
# Behavioral test: 1385-sc6-sem-006-subitem-type
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-SEM-006: spec-audit detects sub-item type violations

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1385-sc6-sem-006-subitem-type"
SCENARIO_PROMPT="You are auditing a skill card spec. The spec references a SKILL.md with a Trigger Dispatch Table that has this row:
| 'create branch' | 'pre-work' | 'sub-task' | '{issue_number, worktree.path}' |
The sub-items under this row use sub-checkboxes for context fields like '- [ ] issue_number' and '- [ ] worktree.path'. Evaluate SC-SEM-006 (Dispatch table sub-item type correctness): are sub-checkboxes being used for parameter metadata (context fields) when they should use sub-bullets?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
