#!/bin/bash
# Behavioral test: auditor-scope-narrowness
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Auditor identifies symptom-only fix in spec

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-scope-narrowness"
# Real-domain task: dispatch auditor with a spec that fixes symptom rather than root cause
SCENARIO_PROMPT="Audit this spec for scope narrowness: The spec's Root Cause is 'missing input validation in the API layer' but the Fix Approach only adds error handling in the UI to catch the resulting crashes. The fix addresses the symptom, not the root cause. Evaluate whether the fix is a symptom-only patch."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
