#!/bin/bash
# Behavioral Enforcement Test: Session-Init Sub-folder Repo Mappings (SC-1)
#
# Verifies that session-init emits a ## Sub-folder Repo Mappings section
# containing submodule path mappings when .gitmodules exists.
#
# RED state: session-init does NOT yet emit Sub-folder Repo Mappings.
# After Item A implementation, this test should PASS.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PROJECT_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$PROJECT_ROOT")" != ".opencode" ]; do
    PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"
done
PROJECT_ROOT="$(dirname "$PROJECT_ROOT")"

SCENARIO_NAME="630-sc1-session-init-subfolder-mappings"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# SC-1: session-init emits ## Sub-folder Repo Mappings section when .gitmodules exists
echo "--- Test 1: session-init emits Sub-folder Repo Mappings section ---"
SESSION_INIT="$PROJECT_ROOT/.opencode/tools/session-init"
if [ -f "$SESSION_INIT" ]; then
    # Run session-init from the project root (where .gitmodules exists)
    SESSION_OUTPUT=$(cd "$PROJECT_ROOT" && uv run --script "$SESSION_INIT" 2>/dev/null) || true

    if echo "$SESSION_OUTPUT" | grep -q "## Sub-folder Repo Mappings"; then
        echo "PASS: ## Sub-folder Repo Mappings section found in session-init output"
    else
        echo "FAIL: ## Sub-folder Repo Mappings section NOT found in session-init output"
        echo "Session-init output (first 40 lines):"
        echo "$SESSION_OUTPUT" | head -40
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: session-init not found at expected path"
fi

# SC-1: session-init emits submodules: line with submodule paths
echo "--- Test 2: session-init emits submodules: line ---"
if [ -f "$SESSION_INIT" ] && [ -n "${SESSION_OUTPUT:-}" ]; then
    if echo "$SESSION_OUTPUT" | grep -q "submodules:"; then
        echo "PASS: submodules: line found in session-init output"
    else
        echo "FAIL: submodules: line NOT found in session-init output"
        echo "Session-init output (first 40 lines):"
        echo "$SESSION_OUTPUT" | head -40
        OVERALL_RESULT=1
    fi
elif [ -f "$SESSION_INIT" ]; then
    echo "SKIP: SESSION_OUTPUT not captured (previous test may have failed)"
else
    echo "SKIP: session-init not found"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
