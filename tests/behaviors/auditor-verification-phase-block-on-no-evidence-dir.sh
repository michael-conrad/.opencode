#!/bin/bash
# Behavioral test: auditor-verification-phase-block-on-no-evidence-dir
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-5 (#972): During `verification` phase without `artifact_evidence_dir`,
# auditor returns BLOCKED with MISSING_EVIDENCE_DIR.
# RED:   No phase guard exists — behavior may or may not block
# GREEN: Auditor BLOCKs on missing artifact_evidence_dir during verification phase

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-verification-phase-block-on-no-evidence-dir"

SCENARIO_PROMPT="Verification audit #972. The implementation is done. Search locally for the spec."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: dispatch auditor with audit_phase=verification, no evidence dir"
echo "  RED: no phase guard — may not block correctly"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0