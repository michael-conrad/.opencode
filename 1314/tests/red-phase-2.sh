#!/usr/bin/env bash
set -euo pipefail

# RED Phase 2: playwright-cli skill creation
# SC-2: New playwright-cli skill exists with valid YAML frontmatter, dispatch tables, and provenance attribution
# This test MUST FAIL because the skill doesn't exist yet (RED phase)

OVERALL_RESULT=0

echo "=== RED Phase 2: playwright-cli skill creation ==="
echo "SC-2: Verify playwright-cli skill does NOT exist yet (RED condition)"
echo ""

# Test 1: Skill directory must NOT exist (RED condition)
if test -d ".opencode/skills/playwright-cli"; then
    echo "FAIL: playwright-cli directory already exists (RED condition not met)"
    OVERALL_RESULT=1
else
    echo "PASS: playwright-cli directory does not exist (RED condition confirmed)"
fi

# Test 2: SKILL.md must NOT exist (RED condition)
if test -f ".opencode/skills/playwright-cli/SKILL.md"; then
    echo "FAIL: playwright-cli/SKILL.md already exists (RED condition not met)"
    OVERALL_RESULT=1
else
    echo "PASS: playwright-cli/SKILL.md does not exist (RED condition confirmed)"
fi

# Test 3: references/ directory must NOT exist (RED condition)
if test -d ".opencode/skills/playwright-cli/references"; then
    echo "FAIL: playwright-cli/references/ already exists (RED condition not met)"
    OVERALL_RESULT=1
else
    echo "PASS: playwright-cli/references/ does not exist (RED condition confirmed)"
fi

echo ""
echo "=== RED Phase 2 Result ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "OVERALL: FAIL (expected) — RED condition confirmed: skill does not exist"
    exit 1
else
    echo "OVERALL: UNEXPECTED PASS — skill already exists, RED condition not met"
    exit 0
fi
