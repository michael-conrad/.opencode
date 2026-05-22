#!/bin/bash
# Content-Verification Test: Submodule Sync Discipline (SC-1 through SC-6)
#
# Grep-based checks verifying the content of guideline/skill files
# correctly encodes the tag-based submodule sync discipline.
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
AGENTS_MD="$PROJECT_DIR/.opencode/AGENTS.md"

OVERALL_RESULT=0

echo "=== Content-Verification: Submodule Sync Discipline ==="

# SC-1: pre-work.md has sub-agent dispatch (no auto-commit bump)
if grep -q "sub-agent\|sub-agent\|sub\.agent" "$GIT_WORKFLOW/tasks/pre-work.md" 2>/dev/null; then
    echo "PASS: pre-work.md references sub-agent dispatch"
else
    echo "FAIL: pre-work.md does NOT reference sub-agent dispatch"
    OVERALL_RESULT=1
fi

# No auto-commit bump in pre-work.md
if grep -q -i "auto.*commit.*bump\|auto.*bump.*commit\|git.*add.*opencode.*commit.*bump" "$GIT_WORKFLOW/tasks/pre-work.md" 2>/dev/null; then
    echo "FAIL: pre-work.md contains auto-commit bump pattern"
    OVERALL_RESULT=1
else
    echo "PASS: pre-work.md has no auto-commit bump pattern"
fi

# dependency-sync.md file does NOT exist
if [ -f "$GIT_WORKFLOW/tasks/dependency-sync.md" ]; then
    echo "FAIL: dependency-sync.md exists — should have been removed"
    OVERALL_RESULT=1
else
    echo "PASS: dependency-sync.md does not exist"
fi

# push-and-cleanup.md references submodule-feature-push
if grep -q "submodule-feature-push" "$GIT_WORKFLOW/tasks/review-prep/push-and-cleanup.md" 2>/dev/null; then
    echo "PASS: push-and-cleanup.md references submodule-feature-push"
else
    echo "FAIL: push-and-cleanup.md does NOT reference submodule-feature-push"
    OVERALL_RESULT=1
fi

# branch-cleanup.md has no Step 5.6 (dep-sync)
if grep -q "Step 5\.6" "$GIT_WORKFLOW/tasks/cleanup/branch-cleanup.md" 2>/dev/null; then
    echo "FAIL: branch-cleanup.md contains Step 5.6 (dep-sync residual)"
    OVERALL_RESULT=1
else
    echo "PASS: branch-cleanup.md has no Step 5.6"
fi

# enforcement-gate.md references submodule-liveness-check
if grep -q "submodule-liveness-check" "$GIT_WORKFLOW/tasks/pr-creation/enforcement-gate.md" 2>/dev/null; then
    echo "PASS: enforcement-gate.md references submodule-liveness-check"
else
    echo "FAIL: enforcement-gate.md does NOT reference submodule-liveness-check"
    OVERALL_RESULT=1
fi

# SKILL.md has "Sub-Agent Tasks for Submodule Operations" table
if grep -q "Sub-Agent Tasks for Submodule Operations" "$SKILL_MD" 2>/dev/null; then
    echo "PASS: SKILL.md has Sub-Agent Tasks for Submodule Operations table"
else
    echo "FAIL: SKILL.md missing Sub-Agent Tasks for Submodule Operations table"
    OVERALL_RESULT=1
fi

# SKILL.md has NO "dependency-sync" task entry
if grep -q "dependency.sync" "$SKILL_MD" 2>/dev/null; then
    # Only the "no dependency-sync" references in prose are ok, not a task entry
    if grep -q "dependency-sync.*task\|dependency.sync.*task\|dependency.sync.*entry" "$SKILL_MD" 2>/dev/null; then
        echo "FAIL: SKILL.md has dependency-sync task entry"
        OVERALL_RESULT=1
    else
        echo "PASS: SKILL.md has no dependency-sync task entry (prose references only)"
    fi
else
    echo "PASS: SKILL.md has no dependency-sync references"
fi

# AGENTS.md references tag-based discipline
if grep -q "tag" "$AGENTS_MD" 2>/dev/null; then
    echo "PASS: AGENTS.md references tags (tag-based discipline context)"
else
    echo "FAIL: AGENTS.md does NOT reference tags"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: submodule-sync-discipline"
else
    echo "FAIL: submodule-sync-discipline"
fi

exit $OVERALL_RESULT
