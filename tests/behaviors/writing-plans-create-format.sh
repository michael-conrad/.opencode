#!/bin/bash
# Behavioral test: writing-plans-create-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: create.md has a formal Trigger Dispatch Table covering all 10 sub-steps
# SC-2: Every - [ ] N. step in create.md uses nested sub-bullets for data
# SC-3: Dead template references removed or made actionable
# SC-5: Every step in create.md has a dispatch marker
# SC-16: Sub-agent task files instruct loading output contract from contracts/<task>-output-template.yaml
# SC-17: z3-check steps run solve check against the previous step's output contract
#
# RED phase: These SCs are NOT yet implemented — test should FAIL
# Authority: #1393 R1-R6, R10

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-create-format"
SCENARIO_PROMPT="Read the file .opencode/skills/writing-plans/tasks/create.md and analyze its structure. Report:

1. Does create.md have a Trigger Dispatch Table? How many columns does it have? List the column headers. Does it cover all 10 sub-steps (research, readiness, structure, solve, write, revisit, validate, audit-fidelity, audit-concern, completion)?

2. Do the - [ ] N. steps in the Operating Protocol section use nested sub-bullets for commands, SC references, dispatch context, and expected output? Or are they flat prose strings?

3. Are there any dead template references (input:, output:, template: paths) in the step descriptions?

4. Does every - [ ] N. step have a dispatch marker ((**inline**), (**sub-agent**), or (**clean-room**))?

5. Do any sub-agent task files instruct the agent to load an output contract from contracts/<task>-output-template.yaml and validate output against it before returning?

6. Do the z3-check steps run 'solve check' against a specific output contract template, or do they check generic conditions?

Be specific and cite line numbers for each finding."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
