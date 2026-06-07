#!/bin/bash
# Behavioral test: auditor-disk-offload-cross-validate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Produces evidence for SC-3 (reads from disk), SC-4 (writes findings YAML), SC-5 (frugal contract), SC-6 (evidence_type_mismatch).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-disk-offload-cross-validate"
SCENARIO_PROMPT="Execute the cross-validate task from adversarial-audit for issue .opencode#932. spec_issue_number: 932. github.owner: michael-conrad. github.repo: .opencode. audit_phase: implementation_verification. You have two pre-resolved auditor artifact paths pointing to YAML verdict files on disk. Fetch the spec from GitHub. Read the auditor YAML verdicts from disk. Cross-reference all SCs. Include evidence_type_mismatch detection. Write your findings YAML to ./tmp/artifacts/pipeline-{issue}-cross-validate-{STATUS}-{timestamp}.yaml. Return ONLY a frugal YAML contract with status, overall_consensus, next_step, artifact_path, and summary."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
