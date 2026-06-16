#!/bin/bash
# Content-Verification RED Test: Phase 1 Unit 1 — Remove STATUS markers from executing-plans task files (SC-1)
#
# This is a RED-phase test: it PASSES if STATUS patterns are found (test is in RED state,
# meaning the implementation hasn't happened yet). It FAILS if patterns are absent
# (meaning the implementation was already done, so no RED phase needed).
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_DIR="$PROJECT_DIR/.opencode/skills/executing-plans/tasks"

OVERALL_RESULT=0

echo "=== RED: SC-1 STATUS Pattern Detection in executing-plans task files ==="

# SC-1: STATUS patterns must exist in the 3 files (RED = test fails because patterns exist)
for file in "step.md" "start.md" "completion.md"; do
    full_path="$SKILL_DIR/$file"
    if [ ! -f "$full_path" ]; then
        echo "SKIP: $file not found at $full_path"
        continue
    fi

    patterns_found=0
    for pattern in "Update STATUS in plan issue body" "Read Plan STATUS" "Verify plan issue STATUS" "plan issue STATUS" "Plan STATUS marker" "STATUS marker"; do
        if grep -q "$pattern" "$full_path" 2>/dev/null; then
            echo "  FOUND: '$pattern' in $file"
            patterns_found=1
        fi
    done

    if [ "$patterns_found" -eq 1 ]; then
        echo "RED: STATUS patterns found in $file"
        OVERALL_RESULT=1
    else
        echo "PASS: No STATUS patterns found in $file (GREEN state)"
    fi
done

# Summary
echo ""
if [ "$OVERALL_RESULT" -eq 1 ]; then
    echo "STATUS: RED — STATUS patterns found in executing-plans task files (change has not happened yet)"
else
    echo "STATUS: ALREADY_GREEN — No STATUS patterns found (change appears already implemented)"
fi

exit $OVERALL_RESULT