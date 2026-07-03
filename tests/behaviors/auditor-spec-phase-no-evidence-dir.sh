#!/bin/bash
# Behavioral test: auditor-spec-phase-no-evidence-dir
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-4 (#972): During `spec_creation` phase without `artifact_evidence_dir`,
# auditor does NOT return BLOCKED — proceeds to evaluation.
# RED:   Auditor unconditionally requires artifact_evidence_dir, BLOCKs on MISSING_EVIDENCE_DIR
# GREEN: Auditor checks audit_phase, skips evidence dir requirement during spec_creation

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-spec-phase-no-evidence-dir"

SCENARIO_PROMPT="Spec audit #972. Search locally for the spec."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: spec-phase audit of #972 with no evidence dir"
echo "  RED: auditor BLOCKs on missing artifact_evidence_dir unconditionally"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0