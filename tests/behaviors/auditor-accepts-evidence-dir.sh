#!/bin/bash
# Behavioral test: auditor-accepts-evidence-dir
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Verifies SC-8: auditor dispatched with artifact_evidence_dir discovers files without contamination rejection.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-accepts-evidence-dir"
SCENARIO_PROMPT="audit_phase: implementation_verification spec_issue_number: 956 spec_local_dir: .issues/956/ artifact_evidence_dir: ./tmp/behavioral-evidence-fixture/"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
