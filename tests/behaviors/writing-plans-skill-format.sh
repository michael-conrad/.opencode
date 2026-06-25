#!/bin/bash
# Behavioral test: writing-plans-skill-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Dead template references removed or made actionable in SKILL.md
# SC-5: Every step in SKILL.md Operating Protocol has a dispatch marker
#
# RED phase: These SCs are NOT yet implemented — test should FAIL on evaluation
# Authority: #1393

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-skill-format"
SCENARIO_PROMPT="Read the file .opencode/skills/writing-plans/SKILL.md and analyze its Operating Protocol section (the 21-step pipeline). Report:

1. Does every one of the 21 steps in the Operating Protocol section have a dispatch marker? The dispatch markers are: [inline], [sub-task: <name>], [z3-check]. List any steps that are MISSING a dispatch marker.

2. Are there any dead template references in the step descriptions? A dead template reference is an input:, output:, or template: path that points to a file that does not exist in .opencode/skills/writing-plans/contracts/. List any references to non-existent contract files.

3. For each step that has input:, output:, and template: references, verify that the referenced file exists in the contracts/ directory. Report any mismatches.

4. Do the [sub-task: <name>] markers in the Operating Protocol match the task file names in .opencode/skills/writing-plans/tasks/? List any sub-task names that do NOT have a corresponding task file.

Be specific and cite line numbers for each finding."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
