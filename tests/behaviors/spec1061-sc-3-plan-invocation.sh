#!/bin/bash
# Content-verification test (RED phase): spec1061 SC-3 - plan utility invoked during writing-plans
# Checks that the `.opencode/tools/plan` utility invocation for phase solvability
# validation is NOT yet present in writing-plans task files (RED confirmed if absent)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/../../.."

OVERALL_RESULT=0
echo "SC-3: plan utility invoked during writing-plans"

# SC-3: plan utility at writing-plans after phase structure defined, validating phase solvability
# Looks for: ./.opencode/tools/plan plan --problem and phase-plan-validated artifact path

for f in \
    ".opencode/skills/writing-plans/tasks/create/plan-structure.md" \
    ".opencode/skills/writing-plans/tasks/create/create-and-validate.md" \
    ".opencode/skills/writing-plans/tasks/create.md"
do
    if [ -f "$f" ]; then
        FOUND=0
        if grep -q "\.opencode/tools/plan " "$f" 2>/dev/null; then
            FOUND=1
        fi
        if grep -q "phase-plan-validated" "$f" 2>/dev/null; then
            FOUND=1
        fi
        if grep -q "phase.*solvab" "$f" 2>/dev/null; then
            FOUND=1
        fi
        if [ "$FOUND" -eq 1 ]; then
            echo "  FAIL: plan utility pattern found in $f (GREEN would be no-op)" >&2
            OVERALL_RESULT=1
        else
            echo "  PASS: no plan utility pattern in $f (RED confirmed)"
        fi
    fi
done

exit $OVERALL_RESULT