#!/bin/bash
# Behavioral Enforcement Test: Skildeck Regression Check (Issues 41/42/43/45)
#
# Verifies that skildeck tools work correctly after removing hardcoded paths
# and registry coupling. Tests that skills directory is found without git.
#
# SC-12 from spec #96
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skildeck-regression-check"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

# Test 1: Verify skildeck lint works without git metadata
# Uses git submodule to set up .opencode (mirrors real project structure).
echo "Test 1: skildeck lint without git"
TEST_DIR=$(mktemp -d "$PROJECT_DIR/tmp/skildeck-test-XXXXXX")
git init -q "$TEST_DIR"
git -C "$TEST_DIR" config user.email "test@test.dev"
git -C "$TEST_DIR" config user.name "Test"

# Add .opencode as submodule from local source (avoids network dependency)
local_submodule_url=""
if [ -f "$PROJECT_DIR/.gitmodules" ]; then
    local_submodule_url=$(git -C "$PROJECT_DIR" config --get submodule..opencode.url 2>/dev/null || true)
fi
if [ -z "$local_submodule_url" ]; then
    local_submodule_url="https://github.com/michael-conrad/.opencode.git"
fi

git -C "$TEST_DIR" submodule add -q "$PROJECT_DIR/.opencode" .opencode 2>/dev/null || {
    echo "FATAL: git submodule add failed for .opencode" >&2
    exit 1
}
git -C "$TEST_DIR" submodule update --init .opencode 2>/dev/null || true
git -C "$TEST_DIR/.opencode" remote set-url origin "$local_submodule_url" 2>/dev/null || true

# Remove .git from submodule to test git-free operation
rm -rf "$TEST_DIR/.opencode/.git"

# This should work without git
cd "$TEST_DIR/.opencode"
if tools/skildeck lint --json > /dev/null 2>&1; then
    echo "PASS: skildeck lint works without git"
    TEST1_PASS=1
else
    echo "FAIL: skildeck lint failed without git"
    TEST1_PASS=0
fi

cd - > /dev/null
rm -rf "$TEST_DIR"

# Test 2: Verify new skill is immediately available (no regeneration needed)
# Uses git submodule for .opencode setup.
echo "Test 2: New skill immediately available"
TEST_DIR=$(mktemp -d "$PROJECT_DIR/tmp/skildeck-test-XXXXXX")
git init -q "$TEST_DIR"
git -C "$TEST_DIR" config user.email "test@test.dev"
git -C "$TEST_DIR" config user.name "Test"

git -C "$TEST_DIR" submodule add -q "$PROJECT_DIR/.opencode" .opencode 2>/dev/null || {
    echo "FATAL: git submodule add failed for .opencode" >&2
    exit 1
}
git -C "$TEST_DIR" submodule update --init .opencode 2>/dev/null || true
git -C "$TEST_DIR/.opencode" remote set-url origin "$local_submodule_url" 2>/dev/null || true

# Remove .git from submodule to test git-free operation
rm -rf "$TEST_DIR/.opencode/.git"

mkdir -p "$TEST_DIR/.opencode/skills/test-skill"
echo "# Test Skill" > "$TEST_DIR/.opencode/skills/test-skill/SKILL.md"

cd "$TEST_DIR/.opencode"
# This should find the new skill without regeneration
if tools/skildeck lint --skill test-skill 2>&1 | grep -q "test-skill\|Test Skill"; then
    echo "PASS: New skill found without regeneration"
    TEST2_PASS=1
else
    echo "FAIL: New skill not found"
    TEST2_PASS=0
fi

cd - > /dev/null
rm -rf "$TEST_DIR"

# Test 3: Verify SKILDECK_SKILLS_DIR env var works
echo "Test 3: SKILDECK_SKILLS_DIR environment override"
export SKILDECK_SKILLS_DIR=".opencode/skills"
if ./.opencode/tools/skildeck lint --json > /dev/null 2>&1; then
    echo "PASS: SKILDECK_SKILLS_DIR override works"
    TEST3_PASS=1
else
    echo "FAIL: SKILDECK_SKILLS_DIR override failed"
    TEST3_PASS=0
fi
unset SKILDECK_SKILLS_DIR

echo ""
OVERALL_RESULT=0
if [ "$TEST1_PASS" -eq 1 ] && [ "$TEST2_PASS" -eq 1 ] && [ "$TEST3_PASS" -eq 1 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT
