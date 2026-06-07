#!/bin/bash
# Behavioral Test: skill-dispatch-audit
# Verifies that every SKILL.md file contains a dispatch audit table
# and no SKILL.md has Inline Work? = YES.
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENDIR="$SCRIPT_DIR"
while [ "$(basename "$OPENDIR")" != ".opencode" ]; do
    OPENDIR="$(dirname "$OPENDIR")"
done
SKILLS_DIR="$OPENDIR/skills"
OVERALL_RESULT=0

echo "=== Behavioral Test: skill-dispatch-audit ==="

SKILL_FILES=$(find "$SKILLS_DIR" -maxdepth 2 -name "SKILL.md" ! -path "*/tasks/SKILL.md" | sort)

TOTAL_SKILLS=0
SKILLS_WITHOUT_TABLE=0
SKILLS_WITH_INLINE_WORK=0

for skill_file in $SKILL_FILES; do
    TOTAL_SKILLS=$((TOTAL_SKILLS + 1))
    skill_name=$(dirname "$skill_file" | sed "s|^$SKILLS_DIR/||")

    if ! grep -q "Sub-Agent Task" "$skill_file" && ! grep -q "Sub-Agent Tasks" "$skill_file"; then
        echo "FAIL: $skill_name — missing dispatch audit table (Sub-Agent Tasks section)"
        SKILLS_WITHOUT_TABLE=$((SKILLS_WITHOUT_TABLE + 1))
        OVERALL_RESULT=1
    fi

    if grep -q "Inline Work.*YES" "$skill_file"; then
        echo "FAIL: $skill_name — Inline Work? = YES found in dispatch audit table"
        SKILLS_WITH_INLINE_WORK=$((SKILLS_WITH_INLINE_WORK + 1))
        OVERALL_RESULT=1
    fi
done

echo ""
echo "Checked $TOTAL_SKILLS SKILL.md files"
echo "Skills without dispatch audit table: $SKILLS_WITHOUT_TABLE"
echo "Skills with Inline Work? = YES: $SKILLS_WITH_INLINE_WORK"

if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: skill-dispatch-audit"
else
    echo "FAIL: skill-dispatch-audit"
fi

exit $OVERALL_RESULT