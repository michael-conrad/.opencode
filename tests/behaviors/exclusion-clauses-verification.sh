#!/bin/bash
# Behavioral test: exclusion-clauses-verification
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Exclusion clauses present on verification/verification-before-completion/verification-enforcement
# RED state: ambiguous prompts dispatch to wrong skill (false positive)
# This test MUST FAIL (exit 1) when exclusion clauses are missing.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="exclusion-clauses-verification"
SCENARIO_PROMPT="verify this claim about the system behavior"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-8: Check stderr for which skill was dispatched
STDERR_CONTENT=$(behavior_get_stderr)

echo "=== RED Phase: Exclusion Clauses Verification Group Test (SC-8) ==="
echo ""

# Check which skill was dispatched
if echo "$STDERR_CONTENT" | grep -q 'Skill "verification"'; then
    echo "DISPATCHED: verification (correct skill for 'verify this claim')"
    echo "=== RESULT: PASS — verification correctly dispatched ==="
    exit 0
elif echo "$STDERR_CONTENT" | grep -q 'Skill "verification-before-completion"'; then
    echo "DISPATCHED: verification-before-completion (false positive — should have dispatched verification)"
    echo "=== RESULT: FAIL — RED confirmed (exclusion clauses missing) ==="
    exit 1
elif echo "$STDERR_CONTENT" | grep -q 'Skill "verification-enforcement"'; then
    echo "DISPATCHED: verification-enforcement (false positive — should have dispatched verification)"
    echo "=== RESULT: FAIL — RED confirmed (exclusion clauses missing) ==="
    exit 1
else
    echo "No verification-related skill dispatched"
    echo "=== RESULT: FAIL — RED confirmed (no dispatch to verification group) ==="
    exit 1
fi
