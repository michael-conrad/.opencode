#!/bin/bash
# Behavioral Enforcement Test: Wrong API Routing for Submodule/Sub-folder Repos
#
# Verifies that the agent:
# (a) Does NOT ask which repo to file against
# (b) Detects .opencode/ as a submodule with separate remote
# (c) Routes issues targeting .opencode/ files to opencode-config not the parent repo
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="wrong-api-routing-submodule"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Test 1: session_context_identity.py emits sub-folder repo mappings when .gitmodules exists
echo "--- Test 1: session_context_identity.py emits sub-folder repo mappings ---"
IDENTITY_SCRIPT="$PROJECT_ROOT/.opencode/scripts/session_context_identity.py"
if [ -f "$IDENTITY_SCRIPT" ]; then
    IDENTITY_OUTPUT=$(uv run --script "$IDENTITY_SCRIPT" 2>/dev/null || true)
    if echo "$IDENTITY_OUTPUT" | grep -q "Sub-folder Repo Mappings"; then
        echo "PASS: Sub-folder Repo Mappings section found in identity output"
    else
        echo "FAIL: Sub-folder Repo Mappings section NOT found in identity output"
        echo "Identity output:"
        echo "$IDENTITY_OUTPUT"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: session_context_identity.py not found at expected path"
fi

# Test 2: 000-critical-rules.md contains Wrong API Routing violation section
echo "--- Test 2: 000-critical-rules.md contains Wrong API Routing section ---"
CRITICAL_RULES="$PROJECT_ROOT/.opencode/guidelines/000-critical-rules.md"
if [ -f "$CRITICAL_RULES" ]; then
    if grep -q "Wrong API Routing for Submodule/Sub-folder Repos" "$CRITICAL_RULES"; then
        echo "PASS: Wrong API Routing section found in 000-critical-rules.md"
    else
        echo "FAIL: Wrong API Routing section NOT found in 000-critical-rules.md"
        OVERALL_RESULT=1
    fi
    if grep -q "critical-rules-036" "$CRITICAL_RULES"; then
        echo "PASS: yaml+symbolic rule critical-rules-036 found in 000-critical-rules.md"
    else
        echo "FAIL: yaml+symbolic rule critical-rules-036 NOT found in 000-critical-rules.md"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: 000-critical-rules.md not found"
fi

# Test 3: Behavioral test — agent routes submodule files correctly and does NOT ask which repo
echo "--- Test 3: agent routes submodule files correctly (no repo question) ---"
SCENARIO_PROMPT="Create a bug report for an issue in .opencode/guidelines/000-critical-rules.md — the validation section is missing a cross-reference. File it against the correct repository."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

assert_forbidden_pattern_absent "which repo\|which repository\|what repo\|file against\|should I file\|which owner\|what owner/repo" "agent asking which repo to file against" || OVERALL_RESULT=1

assert_required_pattern_present "opencode-config\|submodule\|sub-folder\|\.opencode/" "agent detects submodule routing" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT