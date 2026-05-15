#!/bin/bash
# SC-3: Per-audit-type task files are reference docs, not inline dispatchers
#
# Content-verification test for spec #578 Defect 4.
# Each per-audit-type task file must NOT contain inline task(subagent_type="general")
# dispatch to cross-validate — they define criteria as reference tables.
#
# RED: Expect FAIL against dev baseline (files still contain inline dispatches).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc3-per-audit-type-reference-tables"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASK_DIR="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Per-audit-type task files that should NOT contain inline cross-validate dispatch
PER_AUDIT_FILES=(
    "spec-audit.md"
    "drift-detection.md"
    "concern-separation.md"
    "spec-summary.md"
    "closure-verification.md"
    "coherence-maintenance.md"
    "guideline-audit.md"
    "plan-fidelity.md"
)

INLINE_COUNT=0
for FILE in "${PER_AUDIT_FILES[@]}"; do
    FILEPATH="$TASK_DIR/$FILE"
    if [ ! -f "$FILEPATH" ]; then
        echo "FAIL: $SCENARIO_NAME — $FILE not found"
        OVERALL_RESULT=1
        continue
    fi

    # Check for inline task(subagent_type="general") dispatch to cross-validate
    MATCH=$(grep -c 'task(subagent_type="general")' "$FILEPATH" 2>/dev/null || true)
    MATCH=${MATCH:-0}
    if [ "$MATCH" -gt 0 ] 2>/dev/null; then
        echo "FAIL: $SCENARIO_NAME — $FILE contains $MATCH inline task(subagent_type) dispatch(es)"
        INLINE_COUNT=$((INLINE_COUNT + MATCH))
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — $FILE does not contain inline cross-validate dispatch"
    fi
done

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME — $INLINE_COUNT total inline dispatch(es) found"
fi

exit $OVERALL_RESULT