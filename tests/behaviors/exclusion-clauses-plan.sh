#!/bin/bash
# Behavioral test: exclusion-clauses-plan
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Exclusion clauses present on plan/writing-plans/plan-creation-pipeline
# RED state: ambiguous prompts dispatch to wrong skill (false positive)
# This test MUST FAIL (exit 1) when exclusion clauses are missing.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="exclusion-clauses-plan"
SCENARIO_PROMPT="create a plan for implementing the new feature"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-8: Check stderr for which skill was dispatched
STDERR_CONTENT=$(behavior_get_stderr)

echo "=== RED Phase: Exclusion Clauses Plan Group Test (SC-8) ==="
echo ""

# Check which skill was dispatched
if echo "$STDERR_CONTENT" | grep -q 'Skill "writing-plans"'; then
    echo "DISPATCHED: writing-plans (correct skill for 'create a plan')"
    echo "=== RESULT: PASS — writing-plans correctly dispatched ==="
    exit 0
elif echo "$STDERR_CONTENT" | grep -q 'Skill "plan"'; then
    echo "DISPATCHED: plan (false positive — should have dispatched writing-plans)"
    echo "=== RESULT: FAIL — RED confirmed (exclusion clauses missing) ==="
    exit 1
elif echo "$STDERR_CONTENT" | grep -q 'Skill "plan-creation-pipeline"'; then
    echo "DISPATCHED: plan-creation-pipeline (false positive — should have dispatched writing-plans)"
    echo "=== RESULT: FAIL — RED confirmed (exclusion clauses missing) ==="
    exit 1
else
    echo "No plan-related skill dispatched"
    echo "=== RESULT: FAIL — RED confirmed (no dispatch to plan group) ==="
    exit 1
fi
