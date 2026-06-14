#!/bin/bash
# Behavioral test: 1046-sc5-z3-contract
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-5: Z3 contract verification — initial state SAT, defective state UNSAT
# Verifies the Z3 model detects the audit-before-close defect.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1046-sc5-z3-contract"
# Prompt: run solve check on both initial and defective states
SCENARIO_PROMPT="Run .opencode/tools/solve check against the cleanup ordering Z3 contract at .opencode/.issues/1046/phase-contract.yaml. First use the initial state (all false) at .opencode/.issues/1046/phase-state.yaml, then use the defective state (AUDIT_PASSED=true, ISSUE_CLOSED=false) at .opencode/.issues/1046/phase-state-defective-audit.yaml. What does each check return?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
