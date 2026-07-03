#!/bin/bash
# Behavioral test: trigger-dispatch-tables
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-B1: All 39 SKILL.md have a ## Trigger Dispatch Table section
# SC-B2: Every dispatch table has all 4 required columns
# SC-B3: No conflicting primary triggers between any two dispatch tables
# SC-B4: Every task listed in Tasks section has at least one dispatch table row
#
# RED phase: 0 dispatch tables exist, 253 tasks unregistered
# GREEN phase: all 39 SKILL.md have dispatch tables covering all tasks
#
# Authority: #1210 SC-B1 through SC-B4
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="trigger-dispatch-tables"
SCENARIO_PROMPT="Read the file .opencode/skills/git-workflow/SKILL.md and analyze its structure. Report:

1. Does the file contain a '## Trigger Dispatch Table' section?
2. If yes, does the table have columns: User says / Context, Task, Dispatch, Context passed?
3. How many rows does the dispatch table have?
4. Do all tasks listed in the '## Tasks' section have at least one dispatch table row?
5. List any tasks from the Tasks section that do NOT appear in any dispatch table row."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0