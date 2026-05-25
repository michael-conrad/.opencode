#!/bin/bash
# Content-Verification Tests: #849 Mandatory Co-Application Policy
#
# RED phase: All assertions FAIL because the referenced content does not
# exist yet. This confirms the tests are correct — they will PASS when
# #848, #853, and #849 are fully implemented (stacked PR order).
#
# Note: #849 is blocked by #848 and #853 (must exist first).
# This test file is created in RED phase and will fail until
# all three specs are implemented.
#
# All SCs are structural per #849's Non-Goals section.
#
# Usage:  bash .opencode/tests/test-enforcement-849-co-application.sh
#         bash .opencode/tests/test-enforcement-849-co-application.sh --scenario SC-1
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

GUIDELINES_DIR="$PROJECT_DIR/.opencode/guidelines"
INDEX_FILE="$GUIDELINES_DIR/INDEX.md"
CODE_STANDARDS="$GUIDELINES_DIR/080-code-standards.md"
CRITICAL_RULES="$GUIDELINES_DIR/000-critical-rules.md"
AGENTS_FILE="$PROJECT_DIR/AGENTS.md"
DARK_PROSE_250="$GUIDELINES_DIR/250-dark-prose-reference.md"

SCENARIO_FILTER=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --scenario) SCENARIO_FILTER+=("$2"); shift 2 ;;
        --list)
            echo "SC-1: 250-dark-prose-reference.md §9 references both 255 and 257"
            echo "SC-2: 255-distribution-shifting-reference.md §4 has co-application rules"
            echo "SC-3: 257-procedural-discipline-reference.md §4 has co-application rules"
            echo "SC-4: INDEX.md has entries for both 255 and 257"
            echo "SC-5: 080-code-standards.md has co-application section with triple table"
            echo "SC-6: 080-code-standards.md auto-detection trigger references all three cards"
            echo "SC-7: 000-critical-rules.md contains pipeline re-priming rule"
            echo "SC-8: AGENTS.md contains procedural discipline identity anchor"
            echo "SC-9: 250 §9 has dependency-order bright-line companion"
            echo "SC-10: 250 §9 has external-signal verification bright-line companion"
            echo "SC-11: 250 §9 has corrupt-success contrast bright-line companion"
            echo "SC-12: 250 §9 has verification-signal discipline bright-line companion"
            echo "SC-13: 250 §9 has over-enforcement bright-line companion"
            exit 0 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

filter_scenario() {
    local name="$1"
    if [ ${#SCENARIO_FILTER[@]} -eq 0 ]; then
        return 0
    fi
    for f in "${SCENARIO_FILTER[@]}"; do
        if [[ "$name" == *"$f"* ]]; then
            return 0
        fi
    done
    return 1
}

OVERALL_RESULT=0

echo "=== Content-Verification Tests: #849 Mandatory Co-Application Policy ==="
echo "  RED phase: All tests expected to FAIL (content does not exist yet)"
echo ""

# ============================================================
# SC-1: 250 §9 references both 255 and 257 with mandatory triple co-application
# ============================================================
if filter_scenario "SC-1"; then
    echo "--- SC-1: 250 §9 references 255 and 257 ---"
    SC1_PASS=true
    if grep -q "255-distribution-shifting\|255-" "$DARK_PROSE_250" 2>/dev/null; then
        echo "  PASS: 250 references 255 in §9"
    else
        echo "  FAIL: 250 does NOT reference 255 in §9"
        SC1_PASS=false
    fi
    if grep -q "257-procedural-discipline\|257-" "$DARK_PROSE_250" 2>/dev/null; then
        echo "  PASS: 250 references 257 in §9"
    else
        echo "  FAIL: 250 does NOT reference 257 in §9"
        SC1_PASS=false
    fi
    if $SC1_PASS; then :; else OVERALL_RESULT=1; fi
    echo ""
fi

# ============================================================
# SC-2: 255 §4 has co-application rules (file must exist)
# ============================================================
if filter_scenario "SC-2"; then
    echo "--- SC-2: 255 §4 has co-application rules ---"
    if [ -f "$GUIDELINES_DIR/255-distribution-shifting-reference.md" ]; then
        if grep -q "Co-Application\|co-application\|250-dark-prose\|257-procedural" "$GUIDELINES_DIR/255-distribution-shifting-reference.md" 2>/dev/null; then
            echo "  PASS: 255 §4 contains co-application rules"
        else
            echo "  FAIL: 255 §4 does NOT contain co-application rules"
            OVERALL_RESULT=1
        fi
    else
        echo "  FAIL: 255-distribution-shifting-reference.md does not exist yet (#848)"
        OVERALL_RESULT=1
    fi
    echo ""
fi

# ============================================================
# SC-3: 257 §4 has co-application rules (file must exist)
# ============================================================
if filter_scenario "SC-3"; then
    echo "--- SC-3: 257 §4 has co-application rules ---"
    if [ -f "$GUIDELINES_DIR/257-procedural-discipline-reference.md" ]; then
        if grep -q "Co-Application\|co-application\|250-dark-prose\|255-distribution" "$GUIDELINES_DIR/257-procedural-discipline-reference.md" 2>/dev/null; then
            echo "  PASS: 257 §4 contains co-application rules"
        else
            echo "  FAIL: 257 §4 does NOT contain co-application rules"
            OVERALL_RESULT=1
        fi
    else
        echo "  FAIL: 257-procedural-discipline-reference.md does not exist yet (#853)"
        OVERALL_RESULT=1
    fi
    echo ""
fi

# ============================================================
# SC-4: INDEX.md has entries for both 255 and 257
# ============================================================
if filter_scenario "SC-4"; then
    echo "--- SC-4: INDEX.md entries for 255 and 257 ---"
    SC4_PASS=true
    if grep -q "255" "$INDEX_FILE" 2>/dev/null; then
        echo "  PASS: INDEX.md has 255 entry"
    else
        echo "  FAIL: INDEX.md missing 255 entry"
        SC4_PASS=false
    fi
    if grep -q "257" "$INDEX_FILE" 2>/dev/null; then
        echo "  PASS: INDEX.md has 257 entry"
    else
        echo "  FAIL: INDEX.md missing 257 entry"
        SC4_PASS=false
    fi
    if $SC4_PASS; then :; else OVERALL_RESULT=1; fi
    echo ""
fi

# ============================================================
# SC-5: 080-code-standards.md has co-application section with triple table
# ============================================================
if filter_scenario "SC-5"; then
    echo "--- SC-5: 080 has co-application section ---"
    if grep -q "Mandatory Co-Application\|triple co-application\|250.*255.*257\|Card.*Layer.*Question" "$CODE_STANDARDS" 2>/dev/null; then
        echo "  PASS: 080 has co-application section"
    else
        echo "  FAIL: 080 does NOT contain co-application section"
        OVERALL_RESULT=1
    fi
    echo ""
fi

# ============================================================
# SC-6: 080 auto-detection trigger references all three cards
# ============================================================
if filter_scenario "SC-6"; then
    echo "--- SC-6: 080 auto-detection triggers reference all three cards ---"
    if grep -q "257\|255" "$CODE_STANDARDS" 2>/dev/null; then
        echo "  PASS: 080 references 255/257"
    else
        echo "  FAIL: 080 does NOT reference 255/257"
        OVERALL_RESULT=1
    fi
    echo ""
fi

# ============================================================
# SC-7: 000-critical-rules.md contains pipeline re-priming rule
# ============================================================
if filter_scenario "SC-7"; then
    echo "--- SC-7: 000 has pipeline re-priming rule ---"
    if grep -q "pipeline.reprime\|re-priming\|enforcement_block_present" "$CRITICAL_RULES" 2>/dev/null; then
        echo "  PASS: 000 has pipeline re-priming rule"
    else
        echo "  FAIL: 000 does NOT contain pipeline re-priming rule"
        OVERALL_RESULT=1
    fi
    echo ""
fi

# ============================================================
# SC-8: AGENTS.md contains procedural discipline identity anchor
# ============================================================
if filter_scenario "SC-8"; then
    echo "--- SC-8: AGENTS.md has procedural discipline anchor ---"
    if grep -q "dependency.ordering\|procedural.discipline\|sequential execution" "$AGENTS_FILE" 2>/dev/null; then
        echo "  PASS: AGENTS.md has procedural discipline anchor"
    else
        echo "  FAIL: AGENTS.md does NOT contain procedural discipline anchor"
        OVERALL_RESULT=1
    fi
    echo ""
fi

# ============================================================
# SC-9 through SC-13: 250 §9 bright-line companion rows
# ============================================================
if filter_scenario "SC-9"; then
    echo "--- SC-9: 250 §9 dependency-order bright-line companion ---"
    if grep -q "p-dis-001\|Dependency.order\|dependency.order" "$DARK_PROSE_250" 2>/dev/null; then
        echo "  PASS: 250 §9 has dependency-order companion"
    else
        echo "  FAIL: 250 §9 missing dependency-order companion"
        OVERALL_RESULT=1
    fi
    echo ""
fi

if filter_scenario "SC-10"; then
    echo "--- SC-10: 250 §9 external-signal verification bright-line companion ---"
    if grep -q "dist-shift-007\|external.signal.verification" "$DARK_PROSE_250" 2>/dev/null; then
        echo "  PASS: 250 §9 has external-signal companion"
    else
        echo "  FAIL: 250 §9 missing external-signal companion"
        OVERALL_RESULT=1
    fi
    echo ""
fi

if filter_scenario "SC-11"; then
    echo "--- SC-11: 250 §9 corrupt-success contrast bright-line companion ---"
    if grep -q "dist-shift-008\|corrupt.success" "$DARK_PROSE_250" 2>/dev/null; then
        echo "  PASS: 250 §9 has corrupt-success companion"
    else
        echo "  FAIL: 250 §9 missing corrupt-success companion"
        OVERALL_RESULT=1
    fi
    echo ""
fi

if filter_scenario "SC-12"; then
    echo "--- SC-12: 250 §9 verification-signal discipline bright-line companion ---"
    if grep -q "p-dis-006\|verification.signal.discipline" "$DARK_PROSE_250" 2>/dev/null; then
        echo "  PASS: 250 §9 has verification-signal companion"
    else
        echo "  FAIL: 250 §9 missing verification-signal companion"
        OVERALL_RESULT=1
    fi
    echo ""
fi

if filter_scenario "SC-13"; then
    echo "--- SC-13: 250 §9 over-enforcement bright-line companion ---"
    if grep -q "over.enforcement\|safety.tax" "$DARK_PROSE_250" 2>/dev/null; then
        echo "  PASS: 250 §9 has over-enforcement companion"
    else
        echo "  FAIL: 250 §9 missing over-enforcement companion"
        OVERALL_RESULT=1
    fi
    echo ""
fi

# ============================================================
# Summary
# ============================================================
echo "=== Summary ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: All #849 content-verification tests passed"
else
    echo "FAIL: One or more #849 content-verification tests failed (expected in RED phase)"
fi

exit $OVERALL_RESULT
