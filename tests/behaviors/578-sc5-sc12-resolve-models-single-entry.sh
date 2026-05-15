#!/bin/bash
# SC-5/SC-12: resolve-models is the single entry point for model resolution
#
# Content-verification test for spec #578 Defect 6.
# SC-5: All per-audit-type task files reference resolve-models as Step 1
#       in their completion dependency chain, no inline model mapping.
# SC-12: resolve-models entry criteria contain goal-hijacking + forced-action language.
#
# RED: Expect FAIL against dev baseline.
# GREEN: Expect PASS after implementation.
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
RM_FILE="$TASK_DIR/resolve-models.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Per-audit-type task files that must reference resolve-models in completion chain
PER_AUDIT_FILES=(
    "spec-audit.md"
    "drift-detection.md"
    "concern-separation.md"
    "spec-summary.md"
    "closure-verification.md"
    "coherence-maintenance.md"
    "guideline-audit.md"
)

# SC-5: Each per-audit-type file has a Completion Dependency Chain referencing resolve-models
for FILE in "${PER_AUDIT_FILES[@]}"; do
    FILEPATH="$TASK_DIR/$FILE"
    if [ ! -f "$FILEPATH" ]; then
        echo "FAIL: SC-5 — $FILE not found at $FILEPATH"
        OVERALL_RESULT=1
        continue
    fi

    # Must have Completion Dependency Chain section
    if grep -qi "Completion Dependency Chain" "$FILEPATH"; then
        echo "PASS: SC-5 — $FILE has Completion Dependency Chain section"
    else
        echo "FAIL: SC-5 — $FILE missing Completion Dependency Chain section"
        OVERALL_RESULT=1
    fi

    # Must reference resolve-models in completion chain
    if grep -qi "resolve-models" "$FILEPATH"; then
        echo "PASS: SC-5 — $FILE references resolve-models in completion dependency chain"
    else
        echo "FAIL: SC-5 — $FILE missing resolve-models reference"
        OVERALL_RESULT=1
    fi

    # Must NOT contain inline auditor model mapping (hardcoded model names)
    if grep -qiE 'auditor-glm-5\.1|auditor-mistral-large|auditor-deepseek|auditor-kimi|auditor-qwen|ollama/glm' "$FILEPATH"; then
        echo "FAIL: SC-5 — $FILE contains inline auditor model references"
        OVERALL_RESULT=1
    else
        echo "PASS: SC-5 — $FILE no inline auditor model references"
    fi
done

# SC-5: resolve-models.md exists and has goal-hijacking language
if [ ! -f "$RM_FILE" ]; then
    echo "FAIL: SC-5/SC-12 — resolve-models.md not found"
    OVERALL_RESULT=1
else
    # SC-12: Entry criteria contain "ONLY authorized entry point"
    if grep -qi "ONLY authorized entry point\|only authorized entry point" "$RM_FILE"; then
        echo "PASS: SC-12 — resolve-models.md entry criteria contain 'ONLY authorized entry point'"
    else
        echo "FAIL: SC-12 — resolve-models.md missing 'ONLY authorized entry point' in entry criteria"
        OVERALL_RESULT=1
    fi

    # SC-12: Entry criteria contain "no alternative paths exist"
    if grep -qi "no alternative paths exist\|no alternative paths" "$RM_FILE"; then
        echo "PASS: SC-12 — resolve-models.md contains 'no alternative paths exist'"
    else
        echo "FAIL: SC-12 — resolve-models.md missing 'no alternative paths exist' language"
        OVERALL_RESULT=1
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT