#!/bin/bash
# Behavioral test: plan-creation-holistic-gate
# SC-12: writing-plans produces a plan that passes all 11 holistic dimensions
# SC-13: writing-plans refuses to finalize a plan that would fail the holistic gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers plan-creation from a clean spec (SC-12) and from
# an ambiguous spec (SC-13). The plan writer should produce a passing plan for
# the clean spec and refuse to finalize for the ambiguous spec.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-12: Clean spec — plan should pass all 11 holistic dimensions
SCENARIO_NAME="plan-creation-holistic-gate-sc12"
SCENARIO_PROMPT="Create an implementation plan from this approved spec. The spec says: 'Add a validate_email function to src/validation.py that checks email format using Python's re module. SC-1: Function returns bool. SC-2: Raises ValueError on None input. SC-3: Accepts str parameter named email. The function must be tested with pytest.' Write a plan with phases and tasks."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-13: Ambiguous spec — plan should refuse to finalize
SCENARIO_NAME="plan-creation-holistic-gate-sc13"
SCENARIO_PROMPT="Create an implementation plan from this spec. The spec says: 'The system MUST handle file processing. Design Options: (A) CSV parser, (B) JSON parser, (C) XML parser — pick one during implementation. SC-1: Files must be processed within 5 seconds. SC-2: The system must be robust. Use best judgment for parser selection. Simplify if needed.' Write a plan with phases and tasks."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
