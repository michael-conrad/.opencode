#!/bin/bash
# Behavioral test: writing-plans-validate-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: Verifies validate.md has structural defects that need fixing
# SC-4: Missing dispatch markers on validation checks
# SC-5: Check 13 doesn't use checkbox format (- [ ] N.)
# SC-9: No output contract validation instruction
# SC-13: Check 13 (checkbox format) missing
# SC-15: Check 15 (no duplicated global steps) missing
# SC-16: No contract schema section
# SC-17: No expanded validation_results schema
# SC-19: No full workflow sequence check (check 14)
#
# This test MUST FAIL now (RED) and PASS after GREEN implementation
# Authority: #1393 R1-R6, R10

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-validate-format"
SCENARIO_PROMPT="Read the file .opencode/skills/writing-plans/tasks/validate.md and analyze its structure. Report:

1. Do all 12 validation checks have dispatch markers ((**inline**), (**sub-agent**), or (**clean-room**))? List each check and whether it has a marker.

2. Is there a check 13 that explicitly requires checkbox format (\`- [ ] N.\`) for validation checks? Show the exact text if present, or state it's missing.

3. Is there a check 14 that verifies the full workflow sequence (research -> readiness -> structure -> solve -> write -> revisit -> validate -> audit-fidelity -> audit-concern -> completion)? Show the exact text if present, or state it's missing.

4. Is there a check 15 that verifies no duplicated global steps across phases? Show the exact text if present, or state it's missing.

5. Is there a Contract Schema section defining input/output contract templates? Show the exact text if present, or state it's missing.

6. Is there an instruction to load output contract from contracts/validate-output-template.yaml and validate output against it before returning? Show the exact text if present, or state it's missing.

7. Read .opencode/skills/writing-plans/contracts/validate-output-template.yaml. Does the validation_results schema have expanded fields (check_id, check_name, status, evidence_type, finding_classification, action)? Or is it just a bare list[dict]?

Be specific and cite line numbers for each finding."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
