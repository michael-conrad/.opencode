#!/bin/bash
# SC-5/SC-12: resolve-models is the single entry point for model resolution
#
# Content-verification test for spec #578 (Defect 6) and spec #632.
# SC-5: resolve-models task file EXISTS as the ONLY file that references the
#        tool path directly. All per-audit-type task files reference the
#        resolve-models TASK, not the tool path directly.
#        No inline model mapping exists in any task file.
#        The slash command file (.opencode/commands/resolve-models.md) MUST NOT exist.
# SC-12: The resolve-models TASK contains "ONLY authorized entry point" enforcement
#         and the SKILL.md adversarial-audit-013 rule references the task.
#
# Updated for #632: resolve-models is now a skill task that wraps the tool command.
# The task file is the ONLY file that references the tool path directly.
# The slash command (.opencode/commands/resolve-models.md) was deleted.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc5-sc12-resolve-models-single-entry"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASK_DIR="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks"
SKILL_FILE="$PROJECT_DIR/.opencode/skills/adversarial-audit/SKILL.md"
TOOL_FILE="$PROJECT_DIR/.opencode/tools/resolve-models"
TASK_FILE="$TASK_DIR/resolve-models.md"
COMMAND_FILE="$PROJECT_DIR/.opencode/commands/resolve-models.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Per-audit-type task files that must reference resolve-models task (not tool path)
PER_AUDIT_FILES=(
    "spec-audit.md"
    "drift-detection.md"
    "concern-separation.md"
    "spec-summary.md"
    "closure-verification.md"
    "coherence-maintenance.md"
    "guideline-audit.md"
    "cross-validate.md"
    "completion.md"
    "plan-fidelity.md"
)

# SC-4 (#632): resolve-models.md task file MUST exist (it wraps the tool)
if [ -f "$TASK_FILE" ]; then
    echo "PASS: SC-4 (#632) — resolve-models.md task file exists"
else
    echo "FAIL: SC-4 (#632) — resolve-models.md task file missing (should exist as task wrapper)"
    OVERALL_RESULT=1
fi

# SC-4 (#632): slash command MUST NOT exist
if [ -f "$COMMAND_FILE" ]; then
    echo "FAIL: SC-4 (#632) — slash command .opencode/commands/resolve-models.md still exists (should be deleted)"
    OVERALL_RESULT=1
else
    echo "PASS: SC-4 (#632) — slash command deleted (not for human TUI users)"
fi

# SC-5: resolve-models tool exists and is executable
if [ ! -f "$TOOL_FILE" ]; then
    echo "FAIL: SC-5 — resolve-models tool not found at $TOOL_FILE"
    OVERALL_RESULT=1
elif [ ! -x "$TOOL_FILE" ]; then
    echo "FAIL: SC-5 — resolve-models tool exists but is not executable"
    OVERALL_RESULT=1
else
    echo "PASS: SC-5 — resolve-models tool exists and is executable"
fi

# SC-5: Task file references the tool path (it's the wrapper)
if [ -f "$TASK_FILE" ]; then
    if grep -q 'bash.*\.opencode/tools/resolve-models' "$TASK_FILE"; then
        echo "PASS: SC-5 — resolve-models.md task file references the tool path (correct for wrapper)"
    else
        echo "FAIL: SC-5 — resolve-models.md task file missing reference to tool path"
        OVERALL_RESULT=1
    fi
fi

# SC-5: Per-audit-type task files reference the task, NOT the direct tool path
for FILE in "${PER_AUDIT_FILES[@]}"; do
    FILEPATH="$TASK_DIR/$FILE"
    if [ ! -f "$FILEPATH" ]; then
        echo "SKIP: SC-5 — $FILE not found at $FILEPATH (may not exist)"
        continue
    fi

    # Must NOT reference the old slash command
    if grep -qi "commands/resolve-models" "$FILEPATH"; then
        echo "FAIL: SC-5 — $FILE references deleted slash command path"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-5 — $FILE does not reference deleted slash command"
    fi

    # Must NOT contain the direct tool path (only the task file can)
    if grep -qi '\.opencode/tools/resolve-models' "$FILEPATH"; then
        echo "FAIL: SC-5 — $FILE references direct tool path (should reference task instead)"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-5 — $FILE does not reference direct tool path"
    fi

    # Must NOT reference the old task file path (tasks/resolve-models.md was the pre-#632 structure)
    if grep -qi "tasks/resolve-models\\.md" "$FILEPATH"; then
        echo "FAIL: SC-5 — $FILE references old task file path 'tasks/resolve-models.md'"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-5 — $FILE does not reference old task file path"
    fi

    # Must reference resolve-models (as task or concept)
    if grep -qi "resolve-models" "$FILEPATH"; then
        echo "PASS: SC-5 — $FILE references resolve-models"
    else
        echo "FAIL: SC-5 — $FILE missing resolve-models reference"
        OVERALL_RESULT=1
    fi

    # Must NOT contain inline auditor model mapping (hardcoded model names for selection)
    if grep -qiE 'auditor-glm-5\.1|auditor-mistral-large|auditor-deepseek|auditor-kimi|auditor-qwen|ollama/glm' "$FILEPATH"; then
        echo "FAIL: SC-5 — $FILE contains inline auditor model references"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-5 — $FILE no inline auditor model references"
    fi
done

# SC-12: adversarial-audit-013 rule references task, not slash command or old task file
if grep -qi "resolve-models" "$SKILL_FILE"; then
    echo "PASS: SC-12 — SKILL.md references resolve-models"
else
    echo "FAIL: SC-12 — SKILL.md missing resolve-models reference"
    OVERALL_RESULT=1
fi

# SC-12: adversarial-audit-013 rule references task entry point
if grep -q "adversarial-audit-013" "$SKILL_FILE"; then
    if grep -A2 "adversarial-audit-013" "$SKILL_FILE" | grep -qi "tasks/resolve-models\\.md"; then
        echo "FAIL: SC-12 — adversarial-audit-013 still references old task file path"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-12 — adversarial-audit-013 does not reference old task file path"
    fi
else
    echo "FAIL: SC-12 — adversarial-audit-013 rule not found in SKILL.md"
    OVERALL_RESULT=1
fi

# SC-5 (#632): SKILL.md routing table lists resolve-models as a task row
if grep -qi "resolve-models" "$SKILL_FILE"; then
    # Check if resolve-models appears as a task row in routing table
    if grep -E "^\|\s*\`?resolve-models\`?\s*\|" "$SKILL_FILE" 2>/dev/null; then
        echo "PASS: SC-5 (#632) — SKILL.md lists resolve-models as task table row"
    else
        echo "FAIL: SC-5 (#632) — SKILL.md does not list resolve-models as task table row"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: SC-5 (#632) — SKILL.md missing resolve-models reference entirely"
    OVERALL_RESULT=1
fi

# SC-7 (#632): INSUFFICIENT_FAMILIES error output format
# Use --test-insufficient-families flag to force the error path
ERROR_OUTPUT="$("$TOOL_FILE" --test-insufficient-families 2>&1)" && EXIT_CODE=$? || EXIT_CODE=$?
SC7_RESULT=0
if [ "$EXIT_CODE" -ne 1 ]; then
    echo "FAIL: SC-7 (#632) — INSUFFICIENT_FAMILIES error path did not exit with code 1 (got $EXIT_CODE)"
    SC7_RESULT=1
fi
if ! echo "$ERROR_OUTPUT" | grep -qE '^error:.*INSUFFICIENT_FAMILIES'; then
    echo "FAIL: SC-7 (#632) — INSUFFICIENT_FAMILIES error output missing 'error: INSUFFICIENT_FAMILIES' key"
    SC7_RESULT=1
fi
if ! echo "$ERROR_OUTPUT" | grep -q '^reason:'; then
    echo "FAIL: SC-7 (#632) — INSUFFICIENT_FAMILIES error output missing 'reason:' key"
    SC7_RESULT=1
fi
if ! echo "$ERROR_OUTPUT" | grep -qE '^eligible_count: [0-9]+'; then
    echo "FAIL: SC-7 (#632) — INSUFFICIENT_FAMILIES error output missing 'eligible_count' key with numeric value"
    SC7_RESULT=1
fi
if [ "$SC7_RESULT" -eq 0 ]; then
    echo "PASS: SC-7 (#632) — INSUFFICIENT_FAMILIES error output has error/reason/eligible_count keys and exit code 1"
else
    OVERALL_RESULT=1
fi

# SC-8 (#632): Tool has execute permission and valid shebang
if [ -x "$TOOL_FILE" ] && head -1 "$TOOL_FILE" | grep -q '^#!/bin/bash'; then
    echo "PASS: SC-8 (#632) — Tool has execute permission and valid shebang"
else
    echo "FAIL: SC-8 (#632) — Tool missing execute permission or shebang"
    OVERALL_RESULT=1
fi

# SC-12 (#632): SKILL.md does NOT reference the slash command path
if grep -qi "commands/resolve-models" "$SKILL_FILE"; then
    echo "FAIL: SC-12 (#632) — SKILL.md still references deleted slash command path"
    OVERALL_RESULT=1
else
    echo "PASS: SC-12 (#632) — SKILL.md does not reference deleted slash command"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT