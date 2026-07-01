#!/bin/bash
# Behavioral test: 1582-sc4-plan-fidelity-delegation
# SC-4: Plan-fidelity auditor detects undefined delegation targets
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers plan-fidelity audit on a plan with a vague delegation reference.
# The auditor should flag the missing concrete definitions via PF-DELEGATION.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1582-sc4-plan-fidelity-delegation"
SCENARIO_PROMPT="Check the fidelity of this plan against its spec. The spec says: 'Delegate notification sending to the notification service.' The plan says: 'Phase 2: delegate to notification service.' Verify the plan has concrete definitions for what 'delegate to notification service' means — file changes, routing updates, capability migration."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
