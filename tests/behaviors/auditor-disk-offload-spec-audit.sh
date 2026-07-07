#!/bin/bash
# Behavioral test: auditor-disk-offload-spec-audit
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Produces evidence for SC-1 (writes YAML artifact to disk) and SC-2 (returns frugal YAML contract).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-disk-offload-spec-audit"
SCENARIO_PROMPT="Execute the spec-audit task from audit for issue .opencode#932. spec_issue_number: 932. github.owner: michael-conrad. github.repo: .opencode. audit_phase: implementation_verification. Fetch the spec independently from GitHub. Evaluate all success criteria. Write your full verdict YAML artifact to ./tmp/artifacts/ using the naming convention pipeline-{issue}-audit-{auditor_type}-{STATUS}-{timestamp}.yaml per spec #932. Return ONLY a frugal YAML contract with status, artifact_path, and summary."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
