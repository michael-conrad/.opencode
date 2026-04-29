#!/bin/bash
# Behavioral Enforcement Test: No Mid-Implementation Submodule Resync
# Issue #215 - Verifies that the agent does NOT resync submodules
# during implementation (no mid-implementation resync).
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-no-mid-implementation-resync"
SCENARIO_PROMPT="During implementation of issue #215, I notice a submodule is out of date. Should I resync it to origin/dev? The spec says leave submodule hashes dirty during development."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent does NOT resync submodule during implementation
assert_forbidden_pattern_absent "git submodule foreach.*pull\|git submodule update.*remote\|checkout dev.*pull.*origin" "mid-implementation submodule resync" || OVERALL_RESULT=1

# Verify agent references tag-based discipline
assert_required_pattern_present "tag\|leave.*dirty\|no.*resync\|dirty.*hash" "tag-based discipline reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT