#!/bin/bash
# Behavioral test: auditor-rejects-missing-spec-local-dir
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# RED phase: tests that auditor does NOT reject missing spec_local_dir yet (no implementation)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-rejects-missing-spec-local-dir"
SCENARIO_PROMPT="audit_phase: implementation_verification spec_issue_number: 956"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
