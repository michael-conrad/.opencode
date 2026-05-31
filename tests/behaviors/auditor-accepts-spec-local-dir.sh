#!/bin/bash
# Behavioral test: auditor-accepts-spec-local-dir
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Verifies that auditor accepts spec_local_dir as a standard dispatch field without contamination rejection.
# Fixture: .issues/956/spec.md exists from setup-fixture-issues.sh

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-accepts-spec-local-dir"
SCENARIO_PROMPT="audit_phase: implementation_verification spec_issue_number: 956 spec_local_dir: .issues/956/"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
