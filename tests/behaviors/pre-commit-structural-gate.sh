#!/bin/bash
# Behavioral test: pre-commit-structural-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-ROUTING-5: Pre-commit hook detects prohibited procedure patterns in SKILL.md files
# SC-ROUTING-6: Pre-commit hook does NOT block commits that only modify tasks/*.md files
#
# This test creates a temporary git repo, stages files, and runs the pre-commit hook
# to verify it blocks/permits commits as expected.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

OVERALL_RESULT=0

echo "=== Behavioral Test: pre-commit-structural-gate ==="
echo ""

# Create a temporary test directory
TEST_DIR=$(mktemp -d "$PROJECT_DIR/tmp/pre-commit-test-XXXXXX")
trap "rm -rf '$TEST_DIR'" EXIT

# Copy the pre-commit hook
HOOK_SOURCE="$PROJECT_DIR/.opencode/hooks/pre-commit"
if [ ! -f "$HOOK_SOURCE" ]; then
    echo "FAIL: pre-commit hook not found at $HOOK_SOURCE"
    exit 1
fi

# Initialize a test git repo
git init -q "$TEST_DIR"
git -C "$TEST_DIR" config user.email "test@test.dev"
git -C "$TEST_DIR" config user.name "Test"
git -C "$TEST_DIR" checkout -q -b feature/test-branch

# Create a minimal .gitmodules to avoid Gate 3 issues
touch "$TEST_DIR/.gitmodules"

# Install the pre-commit hook
cp "$HOOK_SOURCE" "$TEST_DIR/.git/hooks/pre-commit"
chmod +x "$TEST_DIR/.git/hooks/pre-commit"

# Create a minimal skills directory structure
mkdir -p "$TEST_DIR/.opencode/skills/test-skill"

# --- SC-ROUTING-5: Hook blocks prohibited procedure content ---
echo "--- SC-ROUTING-5: Hook blocks SKILL.md with procedure content ---"

# Create a SKILL.md with prohibited procedure content
cat > "$TEST_DIR/.opencode/skills/test-skill/SKILL.md" << 'SKILL_EOF'
---
name: test-skill
description: Test skill for pre-commit gate
license: MIT
---

## Overview

Test skill for pre-commit gate verification.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Canonical Dispatch String |
|---------------------|------|----------|---------------------------|
| "test" | test-task | sub-task | "execute test-task from test-skill" |

## Procedure

1. **Step 1**: Do something
2. **Step 2**: Do something else
SKILL_EOF

git -C "$TEST_DIR" add .opencode/skills/test-skill/SKILL.md .gitmodules
git -C "$TEST_DIR" commit -q --allow-empty -m "init" 2>/dev/null || true

# Now stage the SKILL.md with procedure content and try to commit
git -C "$TEST_DIR" add .opencode/skills/test-skill/SKILL.md

# Run the pre-commit hook
HOOK_OUTPUT=$(cd "$TEST_DIR" && bash .git/hooks/pre-commit 2>&1 || true)

if echo "$HOOK_OUTPUT" | grep -q "Prohibited procedure content"; then
    echo "  PASS: SC-ROUTING-5 — Hook blocked SKILL.md with procedure content"
    echo "  Hook output: $(echo "$HOOK_OUTPUT" | head -5 | tr '\n' ' ')"
else
    echo "  FAIL: SC-ROUTING-5 — Hook did NOT block SKILL.md with procedure content"
    echo "  Hook output: $HOOK_OUTPUT"
    OVERALL_RESULT=1
fi
echo ""

# --- SC-ROUTING-6: Hook does NOT block tasks/*.md-only commits ---
echo "--- SC-ROUTING-6: Hook permits tasks/*.md-only commits ---"

# Create a tasks directory and a task file
mkdir -p "$TEST_DIR/.opencode/skills/test-skill/tasks"
cat > "$TEST_DIR/.opencode/skills/test-skill/tasks/test-task.md" << 'TASK_EOF'
# Test Task

## Entry Criteria
- Test repo exists

## Procedure
1. Run the test
2. Check output

## Exit Criteria
- Test passes
TASK_EOF

# Create a clean SKILL.md (no procedure content)
cat > "$TEST_DIR/.opencode/skills/test-skill/SKILL.md" << 'CLEAN_EOF'
---
name: test-skill
description: Test skill for pre-commit gate
license: MIT
---

## Overview

Test skill for pre-commit gate verification.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Canonical Dispatch String |
|---------------------|------|----------|---------------------------|
| "test" | test-task | sub-task | "execute test-task from test-skill" |
CLEAN_EOF

git -C "$TEST_DIR" add .opencode/skills/test-skill/SKILL.md .opencode/skills/test-skill/tasks/test-task.md

# Run the pre-commit hook
HOOK_OUTPUT2=$(cd "$TEST_DIR" && bash .git/hooks/pre-commit 2>&1 || true)

if echo "$HOOK_OUTPUT2" | grep -q "Prohibited procedure content"; then
    echo "  FAIL: SC-ROUTING-6 — Hook blocked tasks/*.md-only commit (false positive)"
    echo "  Hook output: $HOOK_OUTPUT2"
    OVERALL_RESULT=1
else
    echo "  PASS: SC-ROUTING-6 — Hook permitted tasks/*.md-only commit"
fi
echo ""

# --- Summary ---
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: pre-commit-structural-gate — all SCs verified"
else
    echo "FAIL: pre-commit-structural-gate — $OVERALL_RESULT SC(s) failed"
fi

exit $OVERALL_RESULT
