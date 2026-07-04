#!/bin/bash
# Behavioral test: auditor-claim-accuracy
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Auditor catches fabricated numerical claim in spec
# RED phase: test MUST FAIL because the A2 step doesn't exist yet

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-claim-accuracy"
# Real-domain task: dispatch auditor with a spec containing a fabricated numerical claim
SCENARIO_PROMPT="Audit this spec for claim accuracy: The spec states 'Our analysis of 1,247 PubMed articles shows 89.3% of MeSH terms are incorrectly assigned.' No source URL, no methodology section, no tool-call evidence is provided for this claim. Evaluate whether this claim should receive a FABRICATED verdict."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
