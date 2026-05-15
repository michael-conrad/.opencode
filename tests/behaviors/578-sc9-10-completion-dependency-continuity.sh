#!/bin/bash
# SC-9/SC-10: Per-audit-type task files have completion dependency chain and next pipeline step
#
# Content-verification test for spec #578 (dark pattern engineering).
# SC-9: Each per-audit-type file has "Completion Dependency Chain" with forced-action language.
# SC-10: Each per-audit-type file has "Next Pipeline Step (MANDATORY CONTINUATION)" section.
#
# RED: Expect FAIL against dev baseline (no completion dependency chains exist).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc9-10-completion-dependency-continuity"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASK_DIR="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

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

for FILE in "${PER_AUDIT_FILES[@]}"; do
    FILEPATH="$TASK_DIR/$FILE"
    if [ ! -f "$FILEPATH" ]; then
        echo "FAIL: $FILE not found at $FILEPATH"
        OVERALL_RESULT=1
        continue
    fi

    # SC-9: Completion Dependency Chain section
    if grep -qi "Completion Dependency Chain" "$FILEPATH"; then
        echo "PASS: SC-9 — $FILE has Completion Dependency Chain section"
    else
        echo "FAIL: SC-9 — $FILE missing Completion Dependency Chain section"
        OVERALL_RESULT=1
    fi

    # SC-9: Chain contains forced-action "INVALID if skipped" language
    if grep -qi "INVALID if skipped\|INVALID.*skipped\|skipped.*INVALID" "$FILEPATH"; then
        echo "PASS: SC-9 — $FILE contains forced-action 'INVALID if skipped' language"
    else
        echo "FAIL: SC-9 — $FILE missing forced-action 'INVALID if skipped' language"
        OVERALL_RESULT=1
    fi

    # SC-10: Next Pipeline Step section with MANDATORY CONTINUATION
    if grep -qi "Next Pipeline Step.*MANDATORY CONTINUATION\|Next Pipeline Step.*mandatory" "$FILEPATH"; then
        echo "PASS: SC-10 — $FILE has Next Pipeline Step (MANDATORY CONTINUATION) section"
    else
        echo "FAIL: SC-10 — $FILE missing Next Pipeline Step (MANDATORY CONTINUATION) section"
        OVERALL_RESULT=1
    fi
done

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT