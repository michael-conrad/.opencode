#!/bin/bash
# Behavioral Enforcement Test: Issue Operations Submodule Routing
#
# Verifies that the agent:
# (a) Routes fix-specs for .opencode/ files to the submodule repo (michael-conrad/opencode-config)
# (b) Does NOT create local .issues/ entries for submodule-targeted fix-specs
# (c) Does NOT ask the developer which repo to file against
# (d) Detects .opencode/ as a submodule with separate remote
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="issue-operations-submodule-routing"

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
    if echo "$IDENTITY_OUTPUT" | grep -q "opencode-config"; then
        echo "PASS: Sub-module maps to opencode-config repository"
    else
        echo "FAIL: Sub-module does NOT map to opencode-config repository"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: session_context_identity.py not found at expected path"
fi

# Test 2: issue-operations SKILL.md contains submodule routing section
echo "--- Test 2: issue-operations SKILL.md contains submodule routing section ---"
SKILL_FILE="$PROJECT_ROOT/.opencode/skills/issue-operations/SKILL.md"
if [ -f "$SKILL_FILE" ]; then
    if grep -q "Submodule Routing for Issue Operations" "$SKILL_FILE"; then
        echo "PASS: Submodule Routing section found in issue-operations SKILL.md"
    else
        echo "FAIL: Submodule Routing section NOT found in issue-operations SKILL.md"
        OVERALL_RESULT=1
    fi
    if grep -q "issue-ops-009" "$SKILL_FILE"; then
        echo "PASS: yaml+symbolic rule issue-ops-009 found in issue-operations SKILL.md"
    else
        echo "FAIL: yaml+symbolic rule issue-ops-009 NOT found in issue-operations SKILL.md"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: issue-operations SKILL.md not found"
fi

# Test 3: 000-critical-rules.md contains Wrong API Routing violation section
echo "--- Test 3: 000-critical-rules.md contains Wrong API Routing section ---"
CRITICAL_RULES="$PROJECT_ROOT/.opencode/guidelines/000-critical-rules.md"
if [ -f "$CRITICAL_RULES" ]; then
    if grep -q "Wrong API Routing for Submodule/Sub-folder Repos" "$CRITICAL_RULES"; then
        echo "PASS: Wrong API Routing section found in 000-critical-rules.md"
    else
        echo "FAIL: Wrong API Routing section NOT found in 000-critical-rules.md"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: 000-critical-rules.md not found"
fi

# Test 4: Behavioral test — agent routes submodule fix-specs correctly
echo "--- Test 4: agent routes submodule fix-specs correctly (no repo question, no .issues/) ---"
SCENARIO_PROMPT="File a fix-spec for .opencode/guidelines/000-critical-rules.md — the agent did not route the issue to the submodule GitHub repo. The fix should ensure issues targeting .opencode/ files are routed to michael-conrad/opencode-config on GitHub."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

assert_forbidden_pattern_absent "which repo\|which repository\|what repo\|should I file\|which owner\|what owner/repo\|local .issues" "agent asking which repo to file against or creating .issues/ entries" || OVERALL_RESULT=1

assert_required_pattern_present "opencode-config\|submodule\|sub-folder\|\.opencode/" "agent detects submodule routing" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT