#!/usr/bin/env bash
# GREEN test: verify checklist generation EXISTS on plan creation
# Expected: EXIT 0 (GREEN) — checklist generation step + checklist file present

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
OVERALL_RESULT=0

echo "=== SC-1244 PH4: Checklist generation on plan creation (SC-7, SC-8, SC-9) ==="
echo "GREEN phase: expecting checklist generation to be PRESENT (test PASSES = EXIT 0)"
echo ""

# Check 1: ./tmp/1244/checklist.md should exist (GREEN phase)
echo "--- Check 1: ./tmp/1244/checklist.md exists? ---"
if [ -f "./tmp/1244/checklist.md" ]; then
    echo "  FOUND: ./tmp/1244/checklist.md exists (expected GREEN)"
else
    echo "  MISSING: ./tmp/1244/checklist.md does not exist"
    OVERALL_RESULT=1
fi

# Check 2: create-and-validate.md should have a checklist generation step producing ./tmp/{N}/checklist.md
echo ""
echo "--- Check 2: checklist generation step in writing-plans/create-and-validate.md ---"
if grep -qE "\./tmp/\{N\}/checklist\.md|generate.*checklist|checklist.*generat" ".opencode/skills/writing-plans/tasks/create/create-and-validate.md"; then
    echo "  FOUND: checklist generation step exists in create-and-validate.md (expected GREEN)"
else
    echo "  MISSING: no checklist generation step in create-and-validate.md"
    OVERALL_RESULT=1
fi

echo ""
echo "=== RESULT ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "Checklist generation implemented — test passes with EXIT 0"
    exit 0
else
    echo "Checklist generation NOT fully implemented — test fails with EXIT 1"
    exit 1
fi