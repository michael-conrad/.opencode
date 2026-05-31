#!/bin/bash
# Behavioral test: auditor-absent-evidence-dir
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Verifies SC-9: auditor dispatched without artifact_evidence_dir handles gracefully.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-absent-evidence-dir"
SCENARIO_PROMPT="audit_phase: implementation_verification spec_issue_number: 956 spec_local_dir: /home/muksihs/git/opencode-config/.opencode/.issues/956/"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
