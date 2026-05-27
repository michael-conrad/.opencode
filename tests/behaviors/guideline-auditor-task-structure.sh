#!/bin/bash
# Behavioral Test: guideline-auditor-task-structure
# Verifies that guideline-auditor skill has correct task structure
# after remediation: deleted stray tasks/SKILL.md, created audit and
# completion tasks, updated SKILL.md task table.
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENDIR="$SCRIPT_DIR"
while [ "$(basename "$OPENDIR")" != ".opencode" ]; do
    OPENDIR="$(dirname "$OPENDIR")"
done
SKILL_DIR="$OPENDIR/skills/guideline-auditor"
TASKS_DIR="$SKILL_DIR/tasks"
SKILL_FILE="$SKILL_DIR/SKILL.md"
OVERALL_RESULT=0

echo "=== Behavioral Test: guideline-auditor-task-structure ==="

# Rule 1: No stray tasks/SKILL.md
if [ -f "$TASKS_DIR/SKILL.md" ]; then
    echo "FAIL: stray tasks/SKILL.md still exists in guideline-auditor"
    OVERALL_RESULT=1
else
    echo "PASS: no stray tasks/SKILL.md in guideline-auditor"
fi

# Rule 2: audit task file exists with correct frontmatter
if [ -f "$TASKS_DIR/audit.md" ]; then
    if head -5 "$TASKS_DIR/audit.md" | grep -q "task: audit"; then
        echo "PASS: audit.md exists with correct frontmatter"
    else
        echo "FAIL: audit.md missing correct frontmatter"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: audit.md does not exist"
    OVERALL_RESULT=1
fi

# Rule 3: completion task file exists with correct frontmatter
if [ -f "$TASKS_DIR/completion.md" ]; then
    if head -5 "$TASKS_DIR/completion.md" | grep -q "task: completion"; then
        echo "PASS: completion.md exists with correct frontmatter"
    else
        echo "FAIL: completion.md missing correct frontmatter"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: completion.md does not exist"
    OVERALL_RESULT=1
fi

# Rule 4: SKILL.md task table includes audit and completion
if grep -q "audit.*≈500" "$SKILL_FILE" && \
   grep -q "completion.*≈100" "$SKILL_FILE"; then
    echo "PASS: SKILL.md task table includes audit and completion"
else
    echo "FAIL: SKILL.md task table missing required rows"
    OVERALL_RESULT=1
fi

# Rule 5: Dispatch audit mentions completion dispatch
if grep -q "completion.*dispatches via.*task.*subagent.*general" "$SKILL_FILE"; then
    echo "PASS: SKILL.md dispatch audit includes completion task dispatch"
else
    echo "FAIL: SKILL.md dispatch audit missing completion task dispatch"
    OVERALL_RESULT=1
fi

# Rule 6: All task files have YAML frontmatter
for task_file in "$TASKS_DIR"/*.md; do
    if ! head -1 "$task_file" | grep -q "^---$"; then
        echo "FAIL: $(basename "$task_file") missing YAML frontmatter"
        OVERALL_RESULT=1
    fi
done
echo "PASS: all task files have YAML frontmatter"

# Rule 7: No reference to pre-analysis dispatch in dispatch audit
if grep -q "pre-analysis receives only.*issue_number.*task_description" "$SKILL_FILE"; then
    echo "FAIL: SKILL.md dispatch audit still references pre-analysis dispatch"
    OVERALL_RESULT=1
else
    echo "PASS: SKILL.md dispatch audit no longer references pre-analysis"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: guideline-auditor-task-structure"
else
    echo "FAIL: guideline-auditor-task-structure"
fi

exit $OVERALL_RESULT
