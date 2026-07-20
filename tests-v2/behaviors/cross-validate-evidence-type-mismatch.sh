#!/bin/bash
# Behavioral test: cross-validate-evidence-type-mismatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="cross-validate-evidence-type-mismatch"
SCENARIO_PROMPT="Read .opencode/skills/audit/tasks/cross-validate.md and verify it has EVIDENCE_TYPE_MISMATCH detection for behavioral SCs that cite only file paths. Write your findings to tmp/audit-findings.md."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
