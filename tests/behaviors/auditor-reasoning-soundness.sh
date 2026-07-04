#!/bin/bash
# Behavioral test: auditor-reasoning-soundness
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Auditor identifies non-sequitur in plan's Fix Approach where causal chain is broken
# RED phase: test MUST FAIL because the A1 step doesn't exist yet

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-reasoning-soundness"
# Real-domain task: dispatch auditor with a spec where Fix Approach doesn't follow from Root Cause
SCENARIO_PROMPT="Run an adversarial audit on spec #1641. The spec's Root Cause is 'auditors lack structured semantic evaluation procedures' but the Fix Approach only adds mechanical checklist items without any semantic evaluation logic. Evaluate the causal chain validity and report whether the Fix Approach follows from the Root Cause."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
