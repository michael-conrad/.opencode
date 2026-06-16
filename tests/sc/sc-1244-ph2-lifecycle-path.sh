#!/bin/bash
# Content-Verification RED Test: Phase 2 — Lifecycle manifest relocation from .issues/ to ./tmp/ (SC-4)
#
# This is a RED-phase test: it PASSES (exits 1) if .issues/{issue-N}/lifecycle.yaml paths
# are still referenced in the specified skill files, meaning the relocation hasn't happened yet.
# It FAILS (exits 0) if all paths have been changed to ./tmp/, meaning the change was already implemented.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

OVERALL_RESULT=0

SKILL_FILES=(
    "$PROJECT_DIR/.opencode/skills/implementation-pipeline/SKILL.md"
    "$PROJECT_DIR/.opencode/skills/spec-creation/tasks/write.md"
    "$PROJECT_DIR/.opencode/skills/writing-plans/tasks/create/create-and-validate.md"
)

PATTERNS=(
    ".issues/{issue-N}/lifecycle"
    ".issues/{issue-N}/lifecycle.yaml"
    ".issues/{N}/lifecycle"
    ".issues/{[^}]*}/lifecycle"
)

echo "=== RED: SC-4 Lifecycle .issues/ Path Detection ==="

for file in "${SKILL_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        rel="${file#$PROJECT_DIR/.opencode/}"
        echo "SKIP: $rel not found"
        continue
    fi

    found=0
    for pattern in "${PATTERNS[@]}"; do
        if grep -qE "$pattern" "$file" 2>/dev/null; then
            rel="${file#$PROJECT_DIR/.opencode/}"
            echo "  FOUND: pattern '$pattern' in $rel"
            found=1
        fi
    done

    if [ "$found" -eq 1 ]; then
        rel="${file#$PROJECT_DIR/.opencode/}"
        echo "RED: .issues/ lifecycle path found in $rel"
        OVERALL_RESULT=1
    else
        rel="${file#$PROJECT_DIR/.opencode/}"
        echo "PASS: No .issues/ lifecycle path in $rel (GREEN state)"
    fi
done

# Summary
echo ""
if [ "$OVERALL_RESULT" -eq 1 ]; then
    echo "STATUS: RED — .issues/ lifecycle paths still present (relocation has not happened yet)"
else
    echo "STATUS: ALREADY_GREEN — All .issues/ lifecycle paths relocated to ./tmp/ (change already implemented)"
fi

exit $OVERALL_RESULT