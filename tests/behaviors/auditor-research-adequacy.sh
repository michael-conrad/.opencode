#!/bin/bash
# Behavioral test: auditor-research-adequacy
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Auditor flags claims without tool-call provenance

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-research-adequacy"
# Real-domain task: dispatch auditor with a spec where Root Cause has no tool-call provenance
SCENARIO_PROMPT="Audit this spec for research adequacy: The spec's Root Cause states 'The MeshValidator class has 14 callers across 6 modules' but provides no srclight_get_callers output, no grep results, and no tool-call evidence for this claim. Evaluate whether the research is adequate and flag any claims asserted without evidence."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
