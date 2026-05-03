#!/bin/bash
# Behavioral Test: engineering-approach-task-structure
# Verifies that engineering-approach skill has correct task structure
# after remediation: deleted stray tasks/SKILL.md, created design-before-code,
# verify-before-complete, completion tasks, updated SKILL.md task table.
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENDIR="$SCRIPT_DIR"
while [ "$(basename "$OPENDIR")" != ".opencode" ]; do
    OPENDIR="$(dirname "$OPENDIR")"
done
SKILL_DIR="$OPENDIR/skills/engineering-approach"
TASKS_DIR="$SKILL_DIR/tasks"
SKILL_FILE="$SKILL_DIR/SKILL.md"
OVERALL_RESULT=0

echo "=== Behavioral Test: engineering-approach-task-structure ==="

# Rule 1: No stray tasks/SKILL.md
if [ -f "$TASKS_DIR/SKILL.md" ]; then
    echo "FAIL: stray tasks/SKILL.md still exists in engineering-approach"
    OVERALL_RESULT=1
else
    echo "PASS: no stray tasks/SKILL.md in engineering-approach"
fi

# Rule 2: design-before-code task file exists with correct frontmatter
if [ -f "$TASKS_DIR/design-before-code.md" ]; then
    if head -5 "$TASKS_DIR/design-before-code.md" | grep -q "task: design-before-code"; then
        echo "PASS: design-before-code.md exists with correct frontmatter"
    else
        echo "FAIL: design-before-code.md missing correct frontmatter"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: design-before-code.md does not exist"
    OVERALL_RESULT=1
fi

# Rule 3: verify-before-complete task file exists with correct frontmatter
if [ -f "$TASKS_DIR/verify-before-complete.md" ]; then
    if head -5 "$TASKS_DIR/verify-before-complete.md" | grep -q "task: verify-before-complete"; then
        echo "PASS: verify-before-complete.md exists with correct frontmatter"
    else
        echo "FAIL: verify-before-complete.md missing correct frontmatter"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: verify-before-complete.md does not exist"
    OVERALL_RESULT=1
fi

# Rule 4: completion task file exists with correct frontmatter
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

# Rule 5: verify-understanding task file still exists
if [ -f "$TASKS_DIR/verify-understanding.md" ]; then
    echo "PASS: verify-understanding.md preserved"
else
    echo "FAIL: verify-understanding.md missing"
    OVERALL_RESULT=1
fi

# Rule 6: SKILL.md task table includes all 4 tasks
if grep -q "verify-understanding.*≈300" "$SKILL_FILE" && \
   grep -q "design-before-code.*≈300" "$SKILL_FILE" && \
   grep -q "verify-before-complete.*≈300" "$SKILL_FILE" && \
   grep -q "completion.*≈100" "$SKILL_FILE"; then
    echo "PASS: SKILL.md task table includes verify-understanding, design-before-code, verify-before-complete, completion"
else
    echo "FAIL: SKILL.md task table missing required rows"
    OVERALL_RESULT=1
fi

# Rule 7: Dispatch audit mentions completion dispatch
if grep -q "completion.*receives.*github.owner.*github.repo" "$SKILL_FILE"; then
    echo "PASS: SKILL.md dispatch audit includes completion task"
else
    echo "FAIL: SKILL.md dispatch audit missing completion task"
    OVERALL_RESULT=1
fi

# Rule 8: All task files have YAML frontmatter
for task_file in "$TASKS_DIR"/*.md; do
    if ! head -1 "$task_file" | grep -q "^---$"; then
        echo "FAIL: $(basename "$task_file") missing YAML frontmatter"
        OVERALL_RESULT=1
    fi
done
echo "PASS: all task files have YAML frontmatter"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: engineering-approach-task-structure"
else
    echo "FAIL: engineering-approach-task-structure"
fi

exit $OVERALL_RESULT
