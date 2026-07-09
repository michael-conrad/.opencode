#!/bin/bash
# Content-verification test: skill-md-procedure-content
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
#
# SC-ROUTING-4: All 39 SKILL.md files pass routing-only audit (no procedure text in body)
# SC-DG-1: audit/SKILL.md has complete DISPATCH_GATE with all 7 subsections
# SC-DG-2: playwright-cli/SKILL.md has complete DISPATCH_GATE
# SC-DG-3: solve/SKILL.md gains missing subsections; existing content preserved
# SC-DG-4: routing-only-template.md has DISPATCH_GATE section
# SC-DG-5: skill-card-spec.md documents DISPATCH_GATE structure requirements
#
# This is a content-verification test (structural/string evidence type).
# It does NOT run a model — it greps files directly.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

OVERALL_RESULT=0

echo "=== Content-Verification Test: skill-md-procedure-content ==="
echo ""

# --- SC-ROUTING-4: All 39 SKILL.md files pass routing-only audit ---
echo "--- SC-ROUTING-4: No procedure text in SKILL.md files ---"

SKILL_FILES=$(find "$PROJECT_DIR/.opencode/skills" -name 'SKILL.md' | sort)
SKILL_COUNT=$(echo "$SKILL_FILES" | wc -l)
echo "  Found $SKILL_COUNT SKILL.md files"

# Prohibited patterns
PROHIBITED_PATTERNS=(
    '- Entry/Exit Criteria'
    '- Procedure:'
    '- Operating Protocol:'
    'Step 1\.'
    'Step 2\.'
    'Step 3\.'
    'Step 4\.'
    'Step 5\.'
    'Step 6\.'
    'Step 7\.'
    'Step 8\.'
    'Step 9\.'
    '```bash'
    '```python'
    '```yaml'
)

VIOLATION_COUNT=0
for f in $SKILL_FILES; do
    # Check for opt-out comment
    if grep -q '# allow-procedure-content' "$f" 2>/dev/null; then
        continue
    fi
    for pattern in "${PROHIBITED_PATTERNS[@]}"; do
        if grep -q "$pattern" "$f" 2>/dev/null; then
            echo "  VIOLATION: $f contains prohibited pattern: $pattern"
            VIOLATION_COUNT=$((VIOLATION_COUNT + 1))
        fi
    done
done

if [ "$VIOLATION_COUNT" -eq 0 ]; then
    echo "  PASS: SC-ROUTING-4 — No prohibited procedure patterns found in any SKILL.md"
else
    echo "  FAIL: SC-ROUTING-4 — $VIOLATION_COUNT prohibited pattern(s) found"
    OVERALL_RESULT=1
fi
echo ""

# --- SC-DG-1: audit/SKILL.md has complete DISPATCH_GATE ---
echo "--- SC-DG-1: audit/SKILL.md DISPATCH_GATE completeness ---"
AUDIT_SKILL="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"
if [ -f "$AUDIT_SKILL" ]; then
    DG_SECTIONS=(
        'Dispatch Context Contract'
        'Sub-Agent Entry Criteria'
        'Orchestrator Entry Criteria'
        'Forbidden in task() Prompts'
        'Sub-Agent Task File Discovery Directive'
    )
    DG_PASS=0
    DG_FAIL=0
    for section in "${DG_SECTIONS[@]}"; do
        if grep -q "$section" "$AUDIT_SKILL" 2>/dev/null; then
            DG_PASS=$((DG_PASS + 1))
        else
            echo "  MISSING: audit/SKILL.md — $section"
            DG_FAIL=$((DG_FAIL + 1))
        fi
    done
    if [ "$DG_FAIL" -eq 0 ]; then
        echo "  PASS: SC-DG-1 — audit/SKILL.md has all DISPATCH_GATE subsections"
    else
        echo "  FAIL: SC-DG-1 — audit/SKILL.md missing $DG_FAIL DISPATCH_GATE subsection(s)"
        OVERALL_RESULT=1
    fi
else
    echo "  FAIL: SC-DG-1 — audit/SKILL.md not found at $AUDIT_SKILL"
    OVERALL_RESULT=1
fi
echo ""

# --- SC-DG-2: playwright-cli/SKILL.md has complete DISPATCH_GATE ---
echo "--- SC-DG-2: playwright-cli/SKILL.md DISPATCH_GATE completeness ---"
PLAYWRIGHT_SKILL="$PROJECT_DIR/.opencode/skills/playwright-cli/SKILL.md"
if [ -f "$PLAYWRIGHT_SKILL" ]; then
    PW_PASS=0
    PW_FAIL=0
    for section in "${DG_SECTIONS[@]}"; do
        if grep -q "$section" "$PLAYWRIGHT_SKILL" 2>/dev/null; then
            PW_PASS=$((PW_PASS + 1))
        else
            echo "  MISSING: playwright-cli/SKILL.md — $section"
            PW_FAIL=$((PW_FAIL + 1))
        fi
    done
    if [ "$PW_FAIL" -eq 0 ]; then
        echo "  PASS: SC-DG-2 — playwright-cli/SKILL.md has all DISPATCH_GATE subsections"
    else
        echo "  FAIL: SC-DG-2 — playwright-cli/SKILL.md missing $PW_FAIL DISPATCH_GATE subsection(s)"
        OVERALL_RESULT=1
    fi
else
    echo "  FAIL: SC-DG-2 — playwright-cli/SKILL.md not found"
    OVERALL_RESULT=1
fi
echo ""

# --- SC-DG-3: solve/SKILL.md has missing subsections ---
echo "--- SC-DG-3: solve/SKILL.md DISPATCH_GATE completeness ---"
SOLVE_SKILL="$PROJECT_DIR/.opencode/skills/solve/SKILL.md"
if [ -f "$SOLVE_SKILL" ]; then
    SOLVE_PASS=0
    SOLVE_FAIL=0
    for section in "${DG_SECTIONS[@]}"; do
        if grep -q "$section" "$SOLVE_SKILL" 2>/dev/null; then
            SOLVE_PASS=$((SOLVE_PASS + 1))
        else
            echo "  MISSING: solve/SKILL.md — $section"
            SOLVE_FAIL=$((SOLVE_FAIL + 1))
        fi
    done
    if [ "$SOLVE_FAIL" -eq 0 ]; then
        echo "  PASS: SC-DG-3 — solve/SKILL.md has all DISPATCH_GATE subsections"
    else
        echo "  FAIL: SC-DG-3 — solve/SKILL.md missing $SOLVE_FAIL DISPATCH_GATE subsection(s)"
        OVERALL_RESULT=1
    fi
else
    echo "  FAIL: SC-DG-3 — solve/SKILL.md not found"
    OVERALL_RESULT=1
fi
echo ""

# --- SC-DG-4: routing-only-template.md has DISPATCH_GATE ---
echo "--- SC-DG-4: routing-only-template.md DISPATCH_GATE presence ---"
TEMPLATE_FILE="$PROJECT_DIR/.opencode/skills/skill-creator/reference/routing-only-template.md"
if [ -f "$TEMPLATE_FILE" ]; then
    if grep -q 'DISPATCH_GATE' "$TEMPLATE_FILE" 2>/dev/null; then
        echo "  PASS: SC-DG-4 — routing-only-template.md has DISPATCH_GATE section"
    else
        echo "  FAIL: SC-DG-4 — routing-only-template.md missing DISPATCH_GATE section"
        OVERALL_RESULT=1
    fi
else
    echo "  FAIL: SC-DG-4 — routing-only-template.md not found"
    OVERALL_RESULT=1
fi
echo ""

# --- SC-DG-5: skill-card-spec.md documents DISPATCH_GATE ---
echo "--- SC-DG-5: skill-card-spec.md DISPATCH_GATE documentation ---"
CARD_SPEC="$PROJECT_DIR/.opencode/skills/skill-creator/reference/skill-card-spec.md"
if [ -f "$CARD_SPEC" ]; then
    if grep -q 'DISPATCH_GATE' "$CARD_SPEC" 2>/dev/null; then
        echo "  PASS: SC-DG-5 — skill-card-spec.md documents DISPATCH_GATE"
    else
        echo "  FAIL: SC-DG-5 — skill-card-spec.md missing DISPATCH_GATE documentation"
        OVERALL_RESULT=1
    fi
else
    echo "  FAIL: SC-DG-5 — skill-card-spec.md not found"
    OVERALL_RESULT=1
fi
echo ""

# --- Summary ---
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: skill-md-procedure-content — all SCs verified"
else
    echo "FAIL: skill-md-procedure-content — $OVERALL_RESULT SC(s) failed"
fi

exit $OVERALL_RESULT
