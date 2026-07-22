#!/bin/bash
# Behavioral test: task-card-inline-execution
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-25: Sub-agent receiving a remediated task card executes inline (does not
# attempt to call task() or dispatch other sub-agents).
#
# The prompt sends a sub-agent a task card that has been stripped of dispatch
# markers. The sub-agent should execute the steps inline without attempting
# to dispatch other sub-agents.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="task-card-inline-execution"
SCENARIO_PROMPT="You are a sub-agent. Execute the following task card inline:

# Task: verify-spec-approved

## Purpose
Verify that the spec issue has been approved for implementation.

## Entry Criteria
- spec_local_dir is provided
- Issue number is provided

## Procedure
1. Read the spec file from spec_local_dir
2. Check for approved-for-* label on the issue
3. If approved, return PASS with spec_local_dir
4. If not approved, return BLOCKED with reason: NOT_APPROVED

## Exit Criteria
- PASS or BLOCKED status returned
- spec_local_dir passed through on PASS

Return your result contract as YAML."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
