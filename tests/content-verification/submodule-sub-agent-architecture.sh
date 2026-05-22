#!/bin/bash
# Content-Verification Test: Submodule Sub-Agent Architecture (SC-7, SC-10)
#
# Grep-based checks verifying that rewritten task files correctly
# encode clean-room sub-agent dispatch patterns:
# - must_receive / must_not_receive declarations
# - Result contract schemas with status: DONE | BLOCKED
# - SKILL.md dispatch audit table with submodule sub-agent entries
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

GIT_WORKFLOW="$PROJECT_DIR/.opencode/skills/git-workflow"
SKILL_MD="$GIT_WORKFLOW/SKILL.md"

OVERALL_RESULT=0

echo "=== Content-Verification: Submodule Sub-Agent Architecture ==="

# SC-7: pre-work.md has must_receive declarations
if grep -q "must_receive" "$GIT_WORKFLOW/tasks/pre-work.md" 2>/dev/null; then
    echo "PASS: pre-work.md has must_receive declarations"
else
    echo "FAIL: pre-work.md missing must_receive declarations"
    OVERALL_RESULT=1
fi

if grep -q "must_not_receive" "$GIT_WORKFLOW/tasks/pre-work.md" 2>/dev/null; then
    echo "PASS: pre-work.md has must_not_receive declarations"
else
    echo "FAIL: pre-work.md missing must_not_receive declarations"
    OVERALL_RESULT=1
fi

# branch-cleanup.md has must_receive/must_not_receive
if grep -q "must_receive" "$GIT_WORKFLOW/tasks/cleanup/branch-cleanup.md" 2>/dev/null; then
    echo "PASS: branch-cleanup.md has must_receive declarations"
else
    echo "FAIL: branch-cleanup.md missing must_receive declarations"
    OVERALL_RESULT=1
fi

# Result contract schemas present (status: DONE | BLOCKED)
if grep -q "status: DONE | BLOCKED" "$GIT_WORKFLOW/tasks/pre-work.md" 2>/dev/null; then
    echo "PASS: pre-work.md has result contract schema (status: DONE | BLOCKED)"
else
    echo "FAIL: pre-work.md missing result contract schema"
    OVERALL_RESULT=1
fi

if grep -q "status: DONE | BLOCKED" "$GIT_WORKFLOW/tasks/cleanup/branch-cleanup.md" 2>/dev/null; then
    echo "PASS: branch-cleanup.md has result contract schema"
else
    echo "FAIL: branch-cleanup.md missing result contract schema"
    OVERALL_RESULT=1
fi

if grep -q "status: DONE | BLOCKED" "$GIT_WORKFLOW/tasks/pr-creation/enforcement-gate.md" 2>/dev/null; then
    echo "PASS: enforcement-gate.md has result contract schema"
else
    echo "FAIL: enforcement-gate.md missing result contract schema"
    OVERALL_RESULT=1
fi

# push-and-cleanup.md has must_receive/must_not_receive
if grep -q "must_receive" "$GIT_WORKFLOW/tasks/review-prep/push-and-cleanup.md" 2>/dev/null; then
    echo "PASS: push-and-cleanup.md has must_receive declarations"
else
    echo "FAIL: push-and-cleanup.md missing must_receive declarations"
    OVERALL_RESULT=1
fi

# SKILL.md dispatch audit table has submodule sub-agent entries
if grep -q "submodule-tag-prework" "$SKILL_MD" 2>/dev/null; then
    echo "PASS: SKILL.md dispatch audit table includes submodule-tag-prework"
else
    echo "FAIL: SKILL.md missing submodule-tag-prework in dispatch audit table"
    OVERALL_RESULT=1
fi

if grep -q "submodule-feature-push" "$SKILL_MD" 2>/dev/null; then
    echo "PASS: SKILL.md dispatch audit table includes submodule-feature-push"
else
    echo "FAIL: SKILL.md missing submodule-feature-push in dispatch audit table"
    OVERALL_RESULT=1
fi

if grep -q "submodule-liveness-check" "$SKILL_MD" 2>/dev/null; then
    echo "PASS: SKILL.md dispatch audit table includes submodule-liveness-check"
else
    echo "FAIL: SKILL.md missing submodule-liveness-check in dispatch audit table"
    OVERALL_RESULT=1
fi

if grep -q "submodule-dev-restore" "$SKILL_MD" 2>/dev/null; then
    echo "PASS: SKILL.md dispatch audit table includes submodule-dev-restore"
else
    echo "FAIL: SKILL.md missing submodule-dev-restore in dispatch audit table"
    OVERALL_RESULT=1
fi

# enforcement-gate.md has must_receive/must_not_receive
if grep -q "must_receive" "$GIT_WORKFLOW/tasks/pr-creation/enforcement-gate.md" 2>/dev/null; then
    echo "PASS: enforcement-gate.md has must_receive declarations"
else
    echo "FAIL: enforcement-gate.md missing must_receive declarations"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: submodule-sub-agent-architecture"
else
    echo "FAIL: submodule-sub-agent-architecture"
fi

exit $OVERALL_RESULT
