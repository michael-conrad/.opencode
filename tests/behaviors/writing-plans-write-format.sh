#!/bin/bash
# Behavioral test: writing-plans-write-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: Verifies write.md has structural defects that need fixing
# SC-5: Missing dispatch markers on steps
# SC-6: Dispatch indicator examples don't use - [ ] N. format
# SC-7: Phase sections format doesn't say "checkbox steps (- [ ] N.)"
# SC-8: Validation rule 6 doesn't say "checkbox steps (- [ ] N.)"
# SC-11: Hard-coded RED/GREEN chain exists (should be removed)
# SC-12: Line 65 ("No hardcoded gate sequences") exists (should be removed)
# SC-14: No three-tier plan structure specified
# SC-16: No output contract validation instruction
# SC-18: write-output-template.yaml not expanded with compliance fields
#
# This test MUST FAIL now (RED) and PASS after GREEN implementation
# Authority: #1393 R5, R7, R8, R9, R10

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-write-format"
SCENARIO_PROMPT="Read the file .opencode/skills/writing-plans/tasks/write.md and analyze its structure. Report:

1. Do all 6 procedure steps have dispatch markers ((**inline**), (**sub-agent**), or (**clean-room**))? List each step and whether it has a marker.

2. Do the dispatch indicator examples in the Dispatch Indicators table use \`- [ ] N.\` format? Show the exact format used.

3. Does the Phase sections format requirement (item 4 in Required Sections) explicitly say \"checkbox steps (\`- [ ] N.\`)\"? Show the exact text.

4. Does validation rule 6 explicitly say \"checkbox steps (\`- [ ] N.\`)\"? Show the exact text.

5. Is there a hard-coded RED/GREEN chain in the RED+green Item Chain Specification section? Show the exact text.

6. Is there a line saying \"No hardcoded gate sequences\"? Show the exact text.

7. Does the Plan Format Requirements specify a three-tier structure (global pre-phase, per-file RED/GREEN phases, global post-phase)?

8. Is there an instruction to load output contract from contracts/write-output-template.yaml and validate before returning?

9. Read .opencode/skills/writing-plans/contracts/write-output-template.yaml. Does it have compliance fields (checklist_step_count, phase_count, gate_sequence_source, admonishment_present, dispatch_modes_used, global_pre_steps, per_file_phases, global_post_steps)?

Be specific and cite line numbers for each finding."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
