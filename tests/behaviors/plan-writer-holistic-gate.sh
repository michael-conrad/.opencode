#!/bin/bash
# Behavioral test: plan-writer-holistic-gate
# SC-11: Plan writer hard-fails with escalation when spec fails holistic gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers plan-creation from an ambiguous spec that fails
# the holistic gate. The plan writer should hard-fail with an escalation message
# listing the failed dimensions.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-writer-holistic-gate"
SCENARIO_PROMPT="Create an implementation plan from this spec. The spec says: 'The system MUST handle notifications. Design Options: (A) Email, (B) SMS, (C) Push notification, (D) In-app banner — pick one during implementation. SC-1: Notifications must be delivered within 5 seconds. SC-2: The system must be intuitive. Use best judgment for delivery mechanism.' Write a plan with phases and tasks."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
