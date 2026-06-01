#!/bin/bash
# Behavioral test: auditor-spec-phase-evidence-type-mismatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-6 (#972): During `spec_creation` phase, auditor still evaluates SC evidence
# type correctness. Spec has a behavioral SC declared as `structural` — auditor
# flags EVIDENCE_TYPE_MISMATCH.
# RED:   Auditor unconditionally BLOCKs on missing evidence dir, never reaches SC evaluation
# GREEN: Auditor skips evidence dir requirement, proceeds to SC evaluation,
#        detects EVIDENCE_TYPE_MISMATCH

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-spec-phase-evidence-type-mismatch"

SCENARIO_PROMPT="I'm an adversarial auditor evaluating a spec during spec_creation phase (audit_phase: spec_creation). The spec declares SC-1 with evidence_type: 'structural' but the SC prose says 'Agent must dispatch the correct sub-agent and route through the pipeline' — clearly a runtime behavioral action. There is no artifact_evidence_dir because this is spec-phase. Should I flag this as EVIDENCE_TYPE_MISMATCH?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: auditor detects SC evidence type mismatch during spec phase"
echo "  RED: auditor BLOCKs on missing evidence dir before reaching SC eval"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0