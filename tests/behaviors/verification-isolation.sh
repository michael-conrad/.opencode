#!/bin/bash
# Behavioral Test: verification-isolation
# Verifies that verification is performed by a different sub-agent
# from the producer, with only the deliverable + SC list received.
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="verification-isolation"
SCENARIO_PROMPT="Verify the implementation of github issue #1 is complete. Use verification-before-completion."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_skill_invoked "verification-before-completion" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "I verified that my implementation" "self-verification pattern" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT