#!/bin/bash
# Content-Verification RED Test: Phase 1 Unit 3 — Remove STATUS markers from implementation-pipeline files (SC-3)
#
# This is a RED-phase test: it PASSES (exits 1) if Plan STATUS patterns are found in
# implementation-pipeline task/enforcement files, meaning the change hasn't happened yet.
# It FAILS (exits 0) if patterns are absent, meaning the change was already implemented.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

PIPELINE_TASKS_DIR="$PROJECT_DIR/.opencode/skills/implementation-pipeline/tasks"
PIPELINE_ENFORCEMENT_DIR="$PROJECT_DIR/.opencode/skills/implementation-pipeline/enforcement"

OVERALL_RESULT=0

echo "=== RED: SC-3 Plan STATUS Pattern Detection in implementation-pipeline files ==="

# Search tasks directory
if [ -d "$PIPELINE_TASKS_DIR" ]; then
    found=0
    while IFS= read -r -d '' file; do
        for pattern in "Plan STATUS" "plan body STATUS" "Plan STATUS marker" "STATUS marker" "plan issue STATUS"; do
            if grep -q "$pattern" "$file" 2>/dev/null; then
                rel="${file#$PROJECT_DIR/.opencode/}"
                echo "  FOUND: '$pattern' in $rel"
                found=1
            fi
        done
    done < <(find "$PIPELINE_TASKS_DIR" -name "*.md" -print0 2>/dev/null || true)
    if [ "$found" -eq 1 ]; then
        echo "RED: Plan STATUS patterns found in pipeline tasks/"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: pipeline tasks/ directory not found at $PIPELINE_TASKS_DIR"
fi

# Search enforcement directory
if [ -d "$PIPELINE_ENFORCEMENT_DIR" ]; then
    found=0
    while IFS= read -r -d '' file; do
        for pattern in "Plan STATUS" "plan body STATUS" "Plan STATUS marker" "STATUS marker" "plan issue STATUS"; do
            if grep -q "$pattern" "$file" 2>/dev/null; then
                rel="${file#$PROJECT_DIR/.opencode/}"
                echo "  FOUND: '$pattern' in $rel"
                found=1
            fi
        done
    done < <(find "$PIPELINE_ENFORCEMENT_DIR" -name "*.md" -print0 2>/dev/null || true)
    if [ "$found" -eq 1 ]; then
        echo "RED: Plan STATUS patterns found in pipeline enforcement/"
        OVERALL_RESULT=1
    fi
else
    echo "SKIP: pipeline enforcement/ directory not found at $PIPELINE_ENFORCEMENT_DIR"
fi

# Summary
echo ""
if [ "$OVERALL_RESULT" -eq 1 ]; then
    echo "STATUS: RED — Plan STATUS patterns found in implementation-pipeline files (change has not happened yet)"
else
    echo "STATUS: ALREADY_GREEN — No Plan STATUS patterns found (change appears already implemented)"
fi

exit $OVERALL_RESULT