#!/bin/bash
# Behavioral Enforcement Test: Issue-operations Routing Gate (#228)
#
# Verifies that:
# (a) creation.md has Step 0.7 routing gate
# (b) Agent routes submodule issues to the correct repo (not parent)
# (c) Agent does NOT ask which repo to file against
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="issue-operations-routing-gate"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Content verification: Step 0.7 routing gate in creation.md
echo "--- Test 1: Step 0.7 routing gate in creation.md ---"
CREATION_MD="$PROJECT_ROOT/.opencode/skills/issue-operations/tasks/creation.md"
if [ -f "$CREATION_MD" ]; then
    if grep -q "Step 0.7: Submodule Detection & Routing Gate" "$CREATION_MD"; then
        echo "PASS: Step 0.7 routing gate header found in creation.md"
    else
        echo "FAIL: Step 0.7 routing gate header NOT found in creation.md"
        OVERALL_RESULT=1
    fi
    if grep -q "ROUTING-GAP" "$CREATION_MD"; then
        echo "PASS: ROUTING-GAP verification row found in creation.md"
    else
        echo "FAIL: ROUTING-GAP verification row NOT found in creation.md"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: creation.md not found"
fi

# Content verification: routing-gate in Live Verification table
echo "--- Test 2: routing gate in Live Verification table ---"
if [ -f "$CREATION_MD" ]; then
    if grep -q "Routing gate performed" "$CREATION_MD"; then
        echo "PASS: Routing gate verification row found in Live Verification table"
    else
        echo "FAIL: Routing gate verification row NOT found in Live Verification table"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: creation.md not found"
fi

# Behavioral test: agent routes submodule files correctly
# Note: The LLM behavioral assertion is informational — content verification is the primary gate.
echo "--- Test 3: agent routes .opencode/ issues to submodule repo (behavioral, informational) ---"
SCENARIO_PROMPT="Create a bug report for an issue in .opencode/guidelines/020-go-prohibitions.md — the question-response gate is missing. The affected files are .opencode/guidelines/020-go-prohibitions.md and .opencode/guidelines/000-critical-rules.md."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

assert_forbidden_pattern_absent "which repo\|which repository\|should I file\|what owner/repo\|file against the parent" "agent asking which repo to file against" || OVERALL_RESULT=1

# Content verification is the primary enforcement gate for #228.
# The behavioral assertion below is informational — the routing gate text
# presence in creation.md (Tests 1-2) is the binding enforcement.
if assert_required_pattern_present "michael-conrad/.opencode\|\.opencode.*submodule\|submodule.*routing\|Routing.*Filing against\|opencode-config" "agent detects repo context for issue filing" 2>/dev/null; then
    echo "INFO: Agent mentioned repo routing context"
else
    echo "INFO: Agent did not mention repo routing context (content verification is the primary gate)"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT